import 'dart:typed_data';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

class SherpaTtsService {
  SherpaTtsService._();

  static final SherpaTtsService instance = SherpaTtsService._();

  static const String _modelArchiveUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-libritts_r-medium.tar.bz2';
  static const String _modelFolder = 'vits-piper-en_US-libritts_r-medium';
  static const String _onnxFile = 'en_US-libritts_r-medium.onnx';
  static const String _tokensFile = 'tokens.txt';
  static const String _dataDir = 'espeak-ng-data';
  static const int maxSpeakerId = 903;
  static const List<int> recommendedSpeakerIds = [109, 200, 500, 700, 900];

  final AudioPlayer _player = AudioPlayer();
  sherpa_onnx.OfflineTts? _tts;
  Future<void>? _initFuture;
  bool _bindingsInitialized = false;

  Future<void> initialize() {
    _initFuture ??= _initializeInternal();
    return _initFuture!;
  }

  Future<void> _initializeInternal() async {
    if (!_bindingsInitialized) {
      sherpa_onnx.initBindings();
      _bindingsInitialized = true;
    }

    final appSupportDir = await getApplicationSupportDirectory();
    await _ensureModelAvailable(appSupportDir);

    _tts?.free();
    _tts = _createTts(appSupportDir.path);
  }

  sherpa_onnx.OfflineTts _createTts(String supportPath) {
    final modelRoot = p.join(supportPath, _modelFolder);
    final config = sherpa_onnx.OfflineTtsConfig(
      model: sherpa_onnx.OfflineTtsModelConfig(
        vits: sherpa_onnx.OfflineTtsVitsModelConfig(
          model: p.join(modelRoot, _onnxFile),
          tokens: p.join(modelRoot, _tokensFile),
          dataDir: p.join(modelRoot, _dataDir),
        ),
        numThreads: 2,
        debug: false,
        provider: 'cpu',
      ),
      maxNumSenetences: 1,
    );

    return sherpa_onnx.OfflineTts(config);
  }

  Future<void> _ensureModelAvailable(Directory appSupportDir) async {
    final modelDir = Directory(p.join(appSupportDir.path, _modelFolder));
    final modelFile = File(p.join(modelDir.path, _onnxFile));
    final tokensFile = File(p.join(modelDir.path, _tokensFile));
    final dataDir = Directory(p.join(modelDir.path, _dataDir));

    if (await modelFile.exists() &&
        await tokensFile.exists() &&
        await dataDir.exists()) {
      return;
    }

    final archiveBytes = await _downloadModelArchive();
    await _extractTarBz2(archiveBytes, appSupportDir);
  }

  Future<Uint8List> _downloadModelArchive() async {
    final resp = await http.get(Uri.parse(_modelArchiveUrl));
    if (resp.statusCode != 200) {
      throw Exception('TTS 모델 다운로드 실패: HTTP ${resp.statusCode}');
    }

    return resp.bodyBytes;
  }

  Future<void> _extractTarBz2(Uint8List archiveBytes, Directory target) async {
    final tarBytes = BZip2Decoder().decodeBytes(archiveBytes);
    final archive = TarDecoder().decodeBytes(tarBytes);

    for (final entry in archive) {
      final normalized = p.normalize(entry.name);
      if (normalized.isEmpty ||
          p.isAbsolute(normalized) ||
          normalized.startsWith('..')) {
        continue;
      }

      final outputPath = p.join(target.path, normalized);
      if (!entry.isFile) {
        await Directory(outputPath).create(recursive: true);
        continue;
      }

      final file = File(outputPath);
      await file.create(recursive: true);
      await file.writeAsBytes(entry.content, flush: true);
    }
  }

  Future<Duration> speak(
    String text, {
    double speed = 1.0,
    int sid = 0,
  }) async {
    final content = text.trim();
    if (content.isEmpty) return Duration.zero;

    await initialize();
    await stop();

    final tts = _tts;
    if (tts == null) {
      throw StateError('TTS 초기화에 실패했습니다.');
    }

    final safeSid = _resolveSpeakerId(tts, sid);
    final audio = tts.generate(text: content, sid: safeSid, speed: speed);
    if (audio.sampleRate <= 0 || audio.samples.isEmpty) {
      throw Exception('TTS 오디오 생성 실패');
    }

    final filePath = await _nextWavePath();
    final ok = sherpa_onnx.writeWave(
      filename: filePath,
      samples: audio.samples,
      sampleRate: audio.sampleRate,
    );
    if (!ok) {
      throw Exception('생성된 오디오 파일 저장 실패');
    }

    await _player.play(DeviceFileSource(filePath));

    final millis = (audio.samples.length * 1000 / audio.sampleRate).round();
    return Duration(milliseconds: millis);
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<String> _nextWavePath() async {
    final tempDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return p.join(tempDir.path, 'sherpa_tts_$ts.wav');
  }

  static double mapUiRateToSpeed(double uiRate) {
    final normalized = ((uiRate - 0.2) / 0.5).clamp(0.0, 1.0);
    return 0.8 + (normalized * 0.6); // 0.8x ~ 1.4x
  }

  static double get slowSpeed => 0.7;

  int _resolveSpeakerId(sherpa_onnx.OfflineTts tts, int requestedSid) {
    final count = tts.numSpeakers;
    if (count <= 0) return 0;
    if (requestedSid < 0) return 0;
    if (requestedSid >= count) return count - 1;
    return requestedSid;
  }
}
