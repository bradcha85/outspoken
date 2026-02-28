import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../models/phrase.dart';
import '../providers/phrase_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/sherpa_tts_service.dart';

class PhraseDetailScreen extends StatefulWidget {
  final String phraseId;

  const PhraseDetailScreen({super.key, required this.phraseId});

  @override
  State<PhraseDetailScreen> createState() => _PhraseDetailScreenState();
}

class _PhraseDetailScreenState extends State<PhraseDetailScreen> {
  final SherpaTtsService _ttsService = SherpaTtsService.instance;
  // null=停止中, 'normal'=보통속도 재생중, 'slow'=느린속도 재생중
  String? _speakingMode;
  bool _showKorean = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _playbackTimer?.cancel();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _speak(String text, double rate, String mode, int sid) async {
    if (_speakingMode != null) {
      final wasSameMode = _speakingMode == mode;
      _playbackTimer?.cancel();
      await _ttsService.stop();
      setState(() => _speakingMode = null);
      if (wasSameMode) return;
    }

    setState(() => _speakingMode = mode);

    try {
      final duration = await _ttsService.speak(text, speed: rate, sid: sid);
      _playbackTimer?.cancel();
      _playbackTimer = Timer(duration + const Duration(milliseconds: 120), () {
        if (mounted) {
          setState(() => _speakingMode = null);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _speakingMode = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음성 재생에 실패했어요: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phraseProvider = context.watch<PhraseProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final settings = context.watch<SettingsProvider>();
    final phrase = phraseProvider.getPhraseById(widget.phraseId);

    if (phrase == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('표현을 찾을 수 없습니다.')),
      );
    }

    final allPhrases = phraseProvider.getPhrasesByCategory(phrase.categoryId);
    final currentIndex = allPhrases.indexWhere((p) => p.id == phrase.id);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < allPhrases.length - 1;
    final isFavorite = progressProvider.isFavorite(phrase.id);
    final isLearned = progressProvider.isLearned(phrase.id);

    final difficultyColor = switch (phrase.difficulty) {
      Difficulty.beginner => AppColors.secondary,
      Difficulty.intermediate => AppColors.primary,
      Difficulty.advanced => AppColors.accent,
    };
    final difficultyLabel = switch (phrase.difficulty) {
      Difficulty.beginner => '초급',
      Difficulty.intermediate => '중급',
      Difficulty.advanced => '고급',
    };

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Colors.pinkAccent
                  : AppColors.textSecondaryColor(context),
            ),
            onPressed: () => progressProvider.toggleFavorite(phrase.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 난이도 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
              ),
              child: Text(
                difficultyLabel,
                style: AppTextStyles.caption.copyWith(
                    color: difficultyColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppLayout.paddingMD),

            // 영어 표현
            Text(phrase.english, style: AppTextStyles.phraseDisplay),
            const SizedBox(height: AppLayout.gapSM),

            // 발음 기호
            Text(phrase.pronunciation, style: AppTextStyles.pronunciation),
            const SizedBox(height: AppLayout.paddingMD),

            // 한국어 (탭으로 보기/숨기기)
            GestureDetector(
              onTap: () => setState(() => _showKorean = !_showKorean),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppLayout.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAltColor(context),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                ),
                child: _showKorean
                    ? Text(phrase.korean, style: AppTextStyles.bodyLarge)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined,
                              color: AppColors.textSecondaryColor(context),
                              size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '한국어 뜻 보기',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondaryColor(context)),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppLayout.paddingMD),

            // TTS 버튼들
            Row(
              children: [
                Expanded(
                  child: _TtsButton(
                    icon: _speakingMode == 'normal'
                        ? Icons.stop_rounded
                        : Icons.volume_up_rounded,
                    label: '보통 속도',
                    color: AppColors.primary,
                    onTap: () => _speak(
                      phrase.english,
                      SherpaTtsService.mapUiRateToSpeed(settings.speechRate),
                      'normal',
                      settings.ttsSpeakerId,
                    ),
                  ),
                ),
                const SizedBox(width: AppLayout.gapMD),
                Expanded(
                  child: _TtsButton(
                    icon: _speakingMode == 'slow'
                        ? Icons.stop_rounded
                        : Icons.slow_motion_video_rounded,
                    label: '느린 속도',
                    color: AppColors.secondary,
                    onTap: () => _speak(
                      phrase.english,
                      SherpaTtsService.slowSpeed,
                      'slow',
                      settings.ttsSpeakerId,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.paddingXL),

            // 예문
            if (phrase.examples.isNotEmpty) ...[
              Text('예문', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppLayout.gapMD),
              ...phrase.examples.map((ex) => _ExampleCard(example: ex)),
            ],

            const SizedBox(height: AppLayout.paddingXL),

            // 학습 완료 버튼
            if (!isLearned)
              SizedBox(
                width: double.infinity,
                height: AppLayout.buttonHeight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('학습 완료'),
                  onPressed: () {
                    progressProvider.markPhraseAsLearned(phrase.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ 학습 완료!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                    ),
                    elevation: 0,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: AppLayout.buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text('학습 완료됨',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.secondary)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppLayout.paddingLG),

            // 이전/다음 네비게이션
            Row(
              children: [
                if (hasPrev)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                      label: const Text('이전'),
                      onPressed: () => context.pushReplacement(
                          '/phrase/${allPhrases[currentIndex - 1].id}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondaryColor(context),
                        side: BorderSide(color: AppColors.borderColor(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppLayout.radiusMD),
                        ),
                      ),
                    ),
                  ),
                if (hasPrev && hasNext) const SizedBox(width: AppLayout.gapMD),
                if (hasNext)
                  Expanded(
                    child: ElevatedButton.icon(
                      label: const Text('다음'),
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      onPressed: () => context.pushReplacement(
                          '/phrase/${allPhrases[currentIndex + 1].id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppLayout.radiusMD),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppLayout.paddingLG),
          ],
        ),
      ),
    );
  }
}

class _TtsButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TtsButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppLayout.paddingMD),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppLayout.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppLayout.iconMD),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final dynamic example;

  const _ExampleCard({required this.example});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppLayout.gapMD),
      padding: const EdgeInsets.all(AppLayout.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(example.english, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 4),
          Text(
            example.korean,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondaryColor(context)),
          ),
        ],
      ),
    );
  }
}
