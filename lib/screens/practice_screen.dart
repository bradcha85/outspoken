import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../models/phrase.dart';
import '../providers/phrase_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/sherpa_tts_service.dart';

class PracticeScreen extends StatefulWidget {
  final String categoryId;

  const PracticeScreen({super.key, required this.categoryId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  List<Phrase> _phrases = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  final SherpaTtsService _ttsService = SherpaTtsService.instance;
  int _knownCount = 0;
  int _unknownCount = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _warmUpTts();
  }

  Future<void> _warmUpTts() async {
    try {
      await _ttsService.initialize();
    } catch (_) {
      // lazy initialize on first playback if pre-warm fails
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_phrases.isEmpty) {
      final provider = context.read<PhraseProvider>();
      _phrases = provider.getPhrasesByCategory(widget.categoryId);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _next(bool isKnown) {
    if (isKnown) {
      _knownCount++;
      context
          .read<ProgressProvider>()
          .markPhraseAsLearned(_phrases[_currentIndex].id);
    } else {
      _unknownCount++;
    }

    if (_currentIndex < _phrases.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
      _flipController.reset();
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.radiusLG)),
        title: const Text('연습 완료! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResultRow(
                label: '✅ 알아요', count: _knownCount, color: AppColors.secondary),
            const SizedBox(height: AppLayout.gapSM),
            _ResultRow(
                label: '❓ 모르겠어요', count: _unknownCount, color: AppColors.error),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('완료'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentIndex = 0;
                _isFlipped = false;
                _knownCount = 0;
                _unknownCount = 0;
              });
              _flipController.reset();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('다시 연습'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_phrases.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('연습')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final phrase = _phrases[_currentIndex];
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${_phrases.length}',
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          children: [
            // 진행 바
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _phrases.length,
              backgroundColor: AppColors.surfaceAltColor(context),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
            ),
            const SizedBox(height: AppLayout.paddingXL),

            // 플래시카드
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * 3.14159;
                    final isBack = angle > 1.5708;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _CardBack(phrase: phrase),
                            )
                          : _CardFront(phrase: phrase),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: AppLayout.paddingLG),

            // TTS 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded),
                  color: AppColors.primary,
                  iconSize: AppLayout.iconLG,
                  onPressed: () => _playTts(
                    phrase.english,
                    settings.speechRate,
                    settings.ttsSpeakerId,
                  ),
                ),
                const SizedBox(width: AppLayout.gapMD),
                Text(
                  '탭하여 뒤집기',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondaryColor(context)),
                ),
              ],
            ),

            const SizedBox(height: AppLayout.paddingLG),

            // 알았어요 / 모르겠어요
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, color: AppColors.error),
                    label: Text('모르겠어요',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.error)),
                    onPressed: () => _next(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppLayout.gapMD),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('알았어요'),
                    onPressed: () => _next(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.paddingMD),
          ],
        ),
      ),
    );
  }

  Future<void> _playTts(String text, double uiRate, int sid) async {
    final speed = SherpaTtsService.mapUiRateToSpeed(uiRate);
    try {
      await _ttsService.speak(text, speed: speed, sid: sid);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음성 재생에 실패했어요: $e')),
      );
    }
  }
}

class _CardFront extends StatelessWidget {
  final Phrase phrase;

  const _CardFront({required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            phrase.english,
            style: AppTextStyles.phraseDisplay,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppLayout.gapMD),
          Text(
            phrase.pronunciation,
            style: AppTextStyles.pronunciation,
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final Phrase phrase;

  const _CardBack({required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppLayout.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            phrase.korean,
            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (phrase.examples.isNotEmpty) ...[
            const SizedBox(height: AppLayout.paddingMD),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppLayout.paddingLG),
              child: Text(
                phrase.examples.first.english,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ResultRow(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyLarge),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
          ),
          child: Text(
            '$count개',
            style: AppTextStyles.labelLarge.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
