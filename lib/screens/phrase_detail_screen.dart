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
  // null=정지, 'normal'=보통속도 재생중, 'slow'=느린속도 재생중
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
    } catch (_) {}
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

    final category = phraseProvider.categories
        .where((c) => c.id == phrase.categoryId)
        .firstOrNull;
    final catColor = category?.color ?? AppColors.primaryColor(context);
    final catName = category?.nameEn ?? '';

    final allPhrases = phraseProvider.getPhrasesByCategory(phrase.categoryId);
    final currentIndex = allPhrases.indexWhere((p) => p.id == phrase.id);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < allPhrases.length - 1;
    final isFavorite = progressProvider.isFavorite(phrase.id);
    final isLearned = progressProvider.isLearned(phrase.id);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.paddingSM,
                vertical: AppLayout.paddingSM,
              ),
              child: Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.paddingMD,
                      vertical: AppLayout.paddingSM,
                    ),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppLayout.radiusCircle),
                    ),
                    child: Text(
                      catName,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: catColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppLayout.gapSM),
                  _buildPhraseCard(context, phrase),
                  const SizedBox(height: AppLayout.gapXL),
                  _buildAudioControls(
                      context, phrase, settings, isFavorite, progressProvider),
                  const SizedBox(height: AppLayout.gapXL),
                  _buildSpeedSlider(context, settings),
                  if (hasPrev) ...[
                    const SizedBox(height: AppLayout.gapXL),
                    _buildPrevButton(context, allPhrases, currentIndex),
                  ],
                  const SizedBox(height: AppLayout.paddingMD),
                ],
              ),
            ),
          ),

          // Fixed bottom bar
          _buildBottomBar(context, phrase, isLearned, hasNext,
              allPhrases, currentIndex, progressProvider),
        ],
      ),
    );
  }

  // ─── Phrase Card ───────────────────────────────────────────────

  Widget _buildPhraseCard(BuildContext context, Phrase phrase) {
    final difficultyColor = switch (phrase.difficulty) {
      Difficulty.beginner => AppColors.secondaryColor(context),
      Difficulty.intermediate => AppColors.primaryColor(context),
      Difficulty.advanced => AppColors.accentColor(context),
    };
    final difficultyLabel = switch (phrase.difficulty) {
      Difficulty.beginner => '초급',
      Difficulty.intermediate => '중급',
      Difficulty.advanced => '고급',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusLG),
        border: Border.all(color: AppColors.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppLayout.elevationSM,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.paddingSM + 2,
              vertical: AppLayout.paddingXS,
            ),
            decoration: BoxDecoration(
              color: difficultyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
            ),
            child: Text(
              difficultyLabel,
              style: AppTextStyles.caption.copyWith(
                color: difficultyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppLayout.paddingMD),

          // English phrase
          Text(
            phrase.english,
            style: AppTextStyles.phraseDisplay.copyWith(
              color: AppColors.textPrimaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppLayout.gapSM),

          // Korean translation (tap to reveal)
          GestureDetector(
            onTap: () => setState(() => _showKorean = !_showKorean),
            child: AnimatedCrossFade(
              firstChild: Text(
                phrase.korean,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondaryColor(context),
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              secondChild: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_outlined,
                      color: AppColors.textSecondaryColor(context),
                      size: AppLayout.iconSM),
                  const SizedBox(width: AppLayout.gapXS),
                  Text(
                    '한국어 뜻 보기',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondaryColor(context),
                    ),
                  ),
                ],
              ),
              crossFadeState: _showKorean
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
          ),

          // Divider + Examples
          if (phrase.examples.isNotEmpty) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: AppLayout.paddingMD),
              child: Divider(
                color: AppColors.borderColor(context),
                height: 1,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'EXAMPLE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondaryColor(context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: AppLayout.gapSM),
            ...phrase.examples.map(
              (ex) => Padding(
                padding: const EdgeInsets.only(bottom: AppLayout.gapSM),
                child: _HighlightedExample(
                  example: ex.english,
                  phraseEnglish: phrase.english,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Audio Controls ────────────────────────────────────────────

  Widget _buildAudioControls(
    BuildContext context,
    Phrase phrase,
    SettingsProvider settings,
    bool isFavorite,
    ProgressProvider progressProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppLayout.paddingSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Slow
          _CircleControlButton(
            icon: _speakingMode == 'slow' ? Icons.stop_rounded : Icons.speed,
            label: 'Slow',
            isActive: _speakingMode == 'slow',
            onTap: () => _speak(
              phrase.english,
              SherpaTtsService.slowSpeed,
              'slow',
              settings.ttsSpeakerId,
            ),
          ),
          const SizedBox(width: AppLayout.gapXL),
          // Main play
          GestureDetector(
            onTap: () => _speak(
              phrase.english,
              SherpaTtsService.mapUiRateToSpeed(settings.speechRate),
              'normal',
              settings.ttsSpeakerId,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.primaryColor(context).withValues(alpha: 0.3),
                    blurRadius: AppLayout.paddingMD,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _speakingMode == 'normal'
                    ? Icons.stop_rounded
                    : Icons.volume_up,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: AppLayout.gapXL),
          // Favorite
          _CircleControlButton(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            label: 'Save',
            isActive: isFavorite,
            activeColor: Colors.pinkAccent,
            onTap: () => progressProvider.toggleFavorite(phrase.id),
          ),
        ],
      ),
    );
  }

  // ─── Speed Slider ──────────────────────────────────────────────

  Widget _buildSpeedSlider(BuildContext context, SettingsProvider settings) {
    final displaySpeed =
        SherpaTtsService.mapUiRateToSpeed(settings.speechRate);

    return Container(
      padding: const EdgeInsets.all(AppLayout.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusLG),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '속도 조절 (Speed)',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${displaySpeed.toStringAsFixed(1)}x',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor(context),
              inactiveTrackColor: AppColors.borderColor(context),
              thumbColor: Colors.white,
              overlayColor:
                  AppColors.primaryColor(context).withValues(alpha: 0.1),
              thumbShape: _SliderThumb(
                borderColor: AppColors.primaryColor(context),
              ),
              trackHeight: 4,
            ),
            child: Slider(
              value: settings.speechRate,
              min: 0.2,
              max: 0.7,
              divisions: 10,
              onChanged: (val) => settings.setSpeechRate(val),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppLayout.paddingXS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0.8x',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabledColor(context))),
                Text('1.1x',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabledColor(context))),
                Text('1.4x',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabledColor(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Prev Button ────────────────────────────────────────────────

  Widget _buildPrevButton(
    BuildContext context,
    List<Phrase> allPhrases,
    int currentIndex,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.arrow_back_ios_new, size: 14),
        label: const Text('이전'),
        onPressed: () => context.pushReplacement(
            '/phrase/${allPhrases[currentIndex - 1].id}'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondaryColor(context),
          side: BorderSide(color: AppColors.borderColor(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.radiusMD),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: AppLayout.paddingMD),
        ),
      ),
    );
  }

  // ─── Bottom Bar ────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    Phrase phrase,
    bool isLearned,
    bool hasNext,
    List<Phrase> allPhrases,
    int currentIndex,
    ProgressProvider progressProvider,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenPadding,
        AppLayout.paddingMD,
        AppLayout.screenPadding,
        MediaQuery.of(context).padding.bottom + AppLayout.paddingMD,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        border: Border(
          top: BorderSide(color: AppColors.borderColor(context)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mark as Learned
          SizedBox(
            width: double.infinity,
            height: 56,
            child: isLearned
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor(context)
                          .withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppLayout.radiusMD),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.secondaryColor(context)),
                          const SizedBox(width: AppLayout.gapSM),
                          Text(
                            '학습 완료됨',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.secondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('학습 완료'),
                    onPressed: () {
                      progressProvider.markPhraseAsLearned(phrase.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('학습 완료!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      textStyle: AppTextStyles.titleLarge,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppLayout.radiusMD),
                      ),
                      elevation: 0,
                    ),
                  ),
          ),
          if (hasNext) ...[
            const SizedBox(height: AppLayout.gapMD),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.pushReplacement(
                    '/phrase/${allPhrases[currentIndex + 1].id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor(context),
                  foregroundColor: Colors.white,
                  textStyle: AppTextStyles.titleLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppLayout.radiusMD),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('다음'),
                    SizedBox(width: AppLayout.gapXS),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Highlighted Example ───────────────────────────────────────

class _HighlightedExample extends StatelessWidget {
  final String example;
  final String phraseEnglish;

  const _HighlightedExample({
    required this.example,
    required this.phraseEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final lowerExample = example.toLowerCase();
    final cleanPhrase = phraseEnglish
        .toLowerCase()
        .replaceAll(RegExp(r'[?!.]'), '')
        .trim();

    final startIdx = lowerExample.indexOf(cleanPhrase);

    if (startIdx == -1) {
      return Text(
        '"$example"',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryColor(context),
          fontWeight: FontWeight.w500,
        ),
      );
    }

    int endIdx = startIdx + cleanPhrase.length;
    if (endIdx < example.length && '?!.,'.contains(example[endIdx])) {
      endIdx++;
    }

    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimaryColor(context),
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: '"${example.substring(0, startIdx)}'),
          TextSpan(
            text: example.substring(startIdx, endIdx),
            style: TextStyle(
              color: AppColors.primaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: '${example.substring(endIdx)}"'),
        ],
      ),
    );
  }
}

// ─── Circle Control Button ─────────────────────────────────────

class _CircleControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _CircleControlButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppColors.primaryColor(context))
        : AppColors.textSecondaryColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: AppLayout.iconXL,
            height: AppLayout.iconXL,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceColor(context),
              border: Border.all(
                color: isActive ? color : AppColors.borderColor(context),
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: AppLayout.iconMD),
          ),
          const SizedBox(height: AppLayout.gapSM),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header Icon Button ────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.paddingSM),
          child: Icon(
            icon,
            color: AppColors.textPrimaryColor(context),
            size: AppLayout.iconMD,
          ),
        ),
      ),
    );
  }
}

// ─── Custom Slider Thumb ───────────────────────────────────────

class _SliderThumb extends SliderComponentShape {
  final Color borderColor;

  const _SliderThumb({required this.borderColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(18, 18);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // White fill
    canvas.drawCircle(
      center,
      9,
      Paint()..color = Colors.white,
    );
    // Color border
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
