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
import '../widgets/phrase/phrase_list_item.dart';

class PhraseListScreen extends StatefulWidget {
  final String categoryId;

  const PhraseListScreen({super.key, required this.categoryId});

  @override
  State<PhraseListScreen> createState() => _PhraseListScreenState();
}

enum _LearnFilter { all, learned, notLearned }

class _PhraseListScreenState extends State<PhraseListScreen> {
  _LearnFilter _learnFilter = _LearnFilter.all;
  Difficulty? _difficultyFilter;
  final SherpaTtsService _ttsService = SherpaTtsService.instance;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _ttsService.initialize();
    } catch (_) {
      // lazy initialize on first playback if pre-warm fails
    }
  }

  Future<void> _speak(String text) async {
    final settings = context.read<SettingsProvider>();
    final rate = settings.speechRate;
    final speed = SherpaTtsService.mapUiRateToSpeed(rate);

    try {
      await _ttsService.speak(
        text,
        speed: speed,
        sid: settings.ttsSpeakerId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('음성 재생에 실패했어요: $e')),
      );
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phraseProvider = context.watch<PhraseProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final category = phraseProvider.getCategoryById(widget.categoryId);
    var phrases = phraseProvider.getPhrasesByCategory(widget.categoryId);

    // 학습 상태 필터
    if (_learnFilter == _LearnFilter.learned) {
      phrases = phrases.where((p) => progressProvider.isLearned(p.id)).toList();
    } else if (_learnFilter == _LearnFilter.notLearned) {
      phrases =
          phrases.where((p) => !progressProvider.isLearned(p.id)).toList();
    }

    // 난이도 필터
    if (_difficultyFilter != null) {
      phrases =
          phrases.where((p) => p.difficulty == _difficultyFilter).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더 ──
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.paddingXS,
                AppLayout.paddingSM,
                AppLayout.screenPadding,
                AppLayout.paddingSM,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: AppLayout.elevationSM,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${category?.name ?? ''} ${category?.nameEn ?? ''}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimaryColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 오른쪽 공간 밸런스용
                  const SizedBox(width: AppLayout.iconXL),
                ],
              ),
            ),

            // ── 필터 영역 ──
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenPadding,
                AppLayout.gapMD,
                AppLayout.screenPadding,
                AppLayout.gapMD,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderColor(context),
                  ),
                ),
              ),
              child: Column(
                children: [
                  // 1행: 학습 상태 필터
                  Row(
                    children: [
                      _FilterChip(
                        label: '전체',
                        isSelected: _learnFilter == _LearnFilter.all,
                        onTap: () =>
                            setState(() => _learnFilter = _LearnFilter.all),
                      ),
                      const SizedBox(width: AppLayout.gapSM),
                      _FilterChip(
                        label: '학습완료',
                        isSelected: _learnFilter == _LearnFilter.learned,
                        onTap: () =>
                            setState(() => _learnFilter = _LearnFilter.learned),
                      ),
                      const SizedBox(width: AppLayout.gapSM),
                      _FilterChip(
                        label: '미학습',
                        isSelected: _learnFilter == _LearnFilter.notLearned,
                        onTap: () => setState(
                            () => _learnFilter = _LearnFilter.notLearned),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppLayout.gapSM),
                  // 2행: 난이도 필터
                  Row(
                    children: [
                      _FilterChip(
                        label: '전체 난이도',
                        isSelected: _difficultyFilter == null,
                        onTap: () => setState(() => _difficultyFilter = null),
                        color: AppColors.textSecondaryColor(context),
                      ),
                      const SizedBox(width: AppLayout.gapSM),
                      _FilterChip(
                        label: '초급',
                        isSelected: _difficultyFilter == Difficulty.beginner,
                        onTap: () => setState(
                            () => _difficultyFilter = Difficulty.beginner),
                        color: AppColors.secondaryColor(context),
                      ),
                      const SizedBox(width: AppLayout.gapSM),
                      _FilterChip(
                        label: '중급',
                        isSelected:
                            _difficultyFilter == Difficulty.intermediate,
                        onTap: () => setState(
                            () => _difficultyFilter = Difficulty.intermediate),
                        color: AppColors.primaryColor(context),
                      ),
                      const SizedBox(width: AppLayout.gapSM),
                      _FilterChip(
                        label: '고급',
                        isSelected: _difficultyFilter == Difficulty.advanced,
                        onTap: () => setState(
                            () => _difficultyFilter = Difficulty.advanced),
                        color: AppColors.accentColor(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 표현 리스트 ──
            Expanded(
              child: phrases.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _learnFilter == _LearnFilter.learned
                                ? Icons.school_outlined
                                : _learnFilter == _LearnFilter.notLearned
                                    ? Icons.check_circle_outline
                                    : Icons.search_off_rounded,
                            size: AppLayout.iconXL,
                            color: AppColors.textDisabledColor(context),
                          ),
                          const SizedBox(height: AppLayout.gapLG),
                          Text(
                            _learnFilter == _LearnFilter.learned
                                ? '아직 학습한 표현이 없어요.'
                                : _learnFilter == _LearnFilter.notLearned
                                    ? '모든 표현을 학습했어요! 🎉'
                                    : '조건에 맞는 표현이 없어요.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppLayout.paddingSM,
                      ),
                      itemCount: phrases.length,
                      itemBuilder: (context, i) {
                        final phrase = phrases[i];
                        return PhraseListItem(
                          phrase: phrase,
                          onTap: () => context.push('/phrase/${phrase.id}'),
                          onFavoriteToggle: () =>
                              progressProvider.toggleFavorite(phrase.id),
                          onTtsPlay: () => _speak(phrase.english),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // ── FAB (연습 모드) ──
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/practice/${widget.categoryId}'),
        backgroundColor: AppColors.primaryColor(context),
        elevation: AppLayout.elevationLG,
        child: const Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: AppLayout.iconLG - 4,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryColor(context);

    return Semantics(
      button: true,
      label: '$label 필터${isSelected ? ', 선택됨' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.gapMD,
            vertical: AppLayout.paddingSM - 2,
          ),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
            border: Border.all(
              color: isSelected ? chipColor : AppColors.borderColor(context),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: chipColor.withValues(alpha: 0.2),
                      blurRadius: AppLayout.elevationSM,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondaryColor(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
