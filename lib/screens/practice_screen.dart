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
    } catch (_) {}
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
                label: '✅ 알아요',
                count: _knownCount,
                color: AppColors.secondary),
            const SizedBox(height: AppLayout.gapSM),
            _ResultRow(
                label: '❓ 모르겠어요',
                count: _unknownCount,
                color: AppColors.error),
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.paddingSM,
                vertical: AppLayout.paddingSM,
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius:
                          BorderRadius.circular(AppLayout.radiusCircle),
                      child: Padding(
                        padding: const EdgeInsets.all(AppLayout.paddingSM),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.textSecondaryColor(context),
                          size: AppLayout.iconMD,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '연습 모드',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.paddingMD,
                      vertical: AppLayout.paddingSM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAltColor(context),
                      borderRadius:
                          BorderRadius.circular(AppLayout.radiusCircle),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${_phrases.length}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPadding,
                vertical: AppLayout.paddingSM,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppLayout.radiusCircle),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _phrases.length,
                  backgroundColor: AppColors.surfaceAltColor(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor(context)),
                  minHeight: 6,
                ),
              ),
            ),

            // ── Flashcard ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPadding,
                  vertical: AppLayout.paddingMD,
                ),
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
                                transform: Matrix4.identity()
                                  ..rotateY(3.14159),
                                child: _CardBack(phrase: phrase),
                              )
                            : _CardFront(
                                phrase: phrase,
                                onPlayTts: () => _playTts(
                                  phrase.english,
                                  settings.speechRate,
                                  settings.ttsSpeakerId,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Action Buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenPadding,
                AppLayout.paddingSM,
                AppLayout.screenPadding,
                AppLayout.paddingMD,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.close,
                      label: '모르겠어요',
                      iconBgColor: AppColors.errorColor(context)
                          .withValues(alpha: 0.1),
                      iconColor: AppColors.errorColor(context),
                      onTap: () => _next(false),
                    ),
                  ),
                  const SizedBox(width: AppLayout.gapMD),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.check,
                      label: '알았어요',
                      filled: true,
                      fillColor: AppColors.secondary,
                      iconColor: Colors.white,
                      onTap: () => _next(true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card Front ───────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  final Phrase phrase;
  final VoidCallback onPlayTts;

  const _CardFront({required this.phrase, required this.onPlayTts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusXL),
        border: Border.all(color: AppColors.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blue left accent stripe
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppLayout.radiusXL),
                  bottomLeft: Radius.circular(AppLayout.radiusXL),
                ),
              ),
            ),
          ),
          // Volume icon (top-right)
          Positioned(
            top: AppLayout.paddingMD,
            right: AppLayout.paddingMD,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onPlayTts,
              child: Padding(
                padding: const EdgeInsets.all(AppLayout.paddingSM),
                child: Icon(
                  Icons.volume_up,
                  color: AppColors.textDisabledColor(context),
                  size: AppLayout.iconMD,
                ),
              ),
            ),
          ),
          // Card content
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppLayout.paddingXL,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PHRASE',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primaryColor(context)
                                .withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppLayout.gapSM),
                        Text(
                          phrase.english,
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textPrimaryColor(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppLayout.gapSM),
                        Text(
                          phrase.pronunciation,
                          style: AppTextStyles.pronunciation.copyWith(
                            color: AppColors.textSecondaryColor(context),
                          ),
                        ),
                        const SizedBox(height: AppLayout.gapXL),
                        Container(
                          width: 64,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderColor(context),
                            borderRadius: BorderRadius.circular(
                                AppLayout.radiusCircle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // "탭하여 뒤집기" hint
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppLayout.paddingXL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: AppColors.textDisabledColor(context),
                      size: AppLayout.iconSM,
                    ),
                    const SizedBox(width: AppLayout.gapSM),
                    Text(
                      '탭하여 뒤집기',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textDisabledColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Card Back ────────────────────────────────────────────────────

class _CardBack extends StatelessWidget {
  final Phrase phrase;

  const _CardBack({required this.phrase});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusXL),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.primaryColor(context).withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            phrase.korean,
            style: AppTextStyles.headlineMedium
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          if (phrase.examples.isNotEmpty) ...[
            const SizedBox(height: AppLayout.paddingMD),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.paddingLG),
              child: Text(
                phrase.examples.first.english,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color? iconBgColor;
  final bool filled;
  final Color? fillColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.iconBgColor,
    this.filled = false,
    this.fillColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.radiusLG),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: AppLayout.paddingMD),
          decoration: BoxDecoration(
            color: filled
                ? fillColor
                : AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(AppLayout.radiusLG),
            border: filled
                ? null
                : Border.all(
                    color: AppColors.borderColor(context),
                    width: 2,
                  ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: (fillColor ?? Colors.transparent)
                          .withValues(alpha: 0.3),
                      blurRadius: AppLayout.elevationLG,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppLayout.iconLG,
                height: AppLayout.iconLG,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withValues(alpha: 0.2)
                      : iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: AppLayout.gapSM),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: filled
                      ? Colors.white
                      : AppColors.textSecondaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Result Row ───────────────────────────────────────────────────

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.paddingMD - 4,
            vertical: AppLayout.paddingXS,
          ),
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
