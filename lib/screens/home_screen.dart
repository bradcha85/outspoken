import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../providers/phrase_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/common/progress_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phraseProvider = context.watch<PhraseProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final progress = progressProvider.progress;
    final todayPhrase = phraseProvider.todayPhrase;

    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단 헤더 (그라디언트 + 라운드 바텀) ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor(context),
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppLayout.radiusXL),
                  bottomRight: Radius.circular(AppLayout.radiusXL),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenPadding,
                    AppLayout.paddingMD,
                    AppLayout.screenPadding,
                    AppLayout.paddingXL,
                  ),
                  child: Column(
                    children: [
                      // 인사 + 스트릭
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: AppLayout.buttonHeightSM,
                                height: AppLayout.buttonHeightSM,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: AppLayout.iconMD,
                                ),
                              ),
                              const SizedBox(width: AppLayout.gapMD),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Text(
                                    '안녕하세요! 👋',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // 스트릭 배지
                          Semantics(
                            label: '연속 학습 ${progress.streakDays}일',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppLayout.paddingMD,
                                vertical: AppLayout.paddingSM,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ExcludeSemantics(
                                    child: Text('🔥', style: TextStyle(fontSize: 16)),
                                  ),
                                  const SizedBox(width: AppLayout.gapXS),
                                  Text(
                                    '${progress.streakDays} Days',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppLayout.gapXL),
                      // 검색 바
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: AppLayout.elevationSM,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: '표현 검색하기...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDisabled,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: AppLayout.iconMD,
                            ),
                            suffixIcon: isSearching
                                ? GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      _searchFocus.unfocus();
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.textSecondary,
                                      size: AppLayout.iconMD,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: AppLayout.gapMD,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 검색 결과 또는 본문 ──
            if (isSearching)
              _SearchResults(
                query: _searchQuery,
                phraseProvider: phraseProvider,
                progressProvider: progressProvider,
              )
            else ...[
            // ── 본문 영역 (카드가 헤더를 살짝 덮도록 네거티브 마진) ──
            Transform.translate(
              offset: const Offset(0, -AppLayout.paddingMD),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppLayout.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 오늘의 표현 카드 ──
                    Semantics(
                      button: true,
                      label: '오늘의 표현: ${todayPhrase.english}, ${todayPhrase.korean}. 자세히 보기',
                      child: GestureDetector(
                        onTap: () => context.push('/phrase/${todayPhrase.id}'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppLayout.paddingLG),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor(context),
                            borderRadius: BorderRadius.circular(AppLayout.radiusLG),
                            border: Border.all(color: AppColors.borderColor(context)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: AppLayout.elevationMD,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // TODAY'S PHRASE 배지
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppLayout.paddingSM + 2,
                                      vertical: AppLayout.paddingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor(context).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(AppLayout.radiusSM),
                                    ),
                                    child: Text(
                                      "TODAY'S PHRASE",
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.primaryColor(context),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  // TTS 버튼
                                  Container(
                                    width: AppLayout.buttonHeightSM,
                                    height: AppLayout.buttonHeightSM,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor(context).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.volume_up_rounded,
                                      color: AppColors.primaryColor(context),
                                      size: AppLayout.iconMD,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppLayout.gapLG),
                              // 영어 표현
                              Text(
                                todayPhrase.english,
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: AppColors.textPrimaryColor(context),
                                ),
                              ),
                              const SizedBox(height: AppLayout.gapLG),
                              // 한국어 번역 박스
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppLayout.paddingMD),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAltColor(context),
                                  borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                                  border: Border.all(
                                    color: AppColors.borderColor(context),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todayPhrase.korean,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.textSecondaryColor(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (todayPhrase.pronunciation.isNotEmpty) ...[
                                      const SizedBox(height: AppLayout.gapXS),
                                      Text(
                                        todayPhrase.pronunciation,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textDisabledColor(context),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppLayout.gapLG),
                              // Save / Practice 버튼
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        context.read<ProgressProvider>().toggleFavorite(todayPhrase.id);
                                      },
                                      child: Container(
                                        height: AppLayout.buttonHeightSM,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceColor(context),
                                          borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                                          border: Border.all(
                                            color: AppColors.borderColor(context),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '저장',
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: AppColors.textSecondaryColor(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppLayout.gapSM),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => context.push('/phrase/${todayPhrase.id}'),
                                      child: Container(
                                        height: AppLayout.buttonHeightSM,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor(context),
                                          borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryColor(context).withValues(alpha: 0.3),
                                              blurRadius: AppLayout.elevationSM,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '연습하기',
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppLayout.gapXL),

                    // ── Daily Progress ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '오늘의 학습',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimaryColor(context),
                          ),
                        ),
                        Text(
                          '${(progressProvider.todayProgress * 100).toInt()}% 달성',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppLayout.gapMD),
                    Semantics(
                      label: '오늘의 목표 ${(progressProvider.todayProgress * 100).toInt()}% 달성',
                      child: ProgressBarWidget(
                        value: progressProvider.todayProgress,
                        color: AppColors.secondaryColor(context),
                        height: 10,
                      ),
                    ),
                    const SizedBox(height: AppLayout.gapSM),
                    Text(
                      progressProvider.isGoalCompleted
                          ? '오늘의 목표를 달성했어요! 🎉'
                          : '목표까지 ${progress.dailyGoal - progressProvider.todayLearned}개 남았어요. 화이팅!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textDisabledColor(context),
                      ),
                    ),

                    const SizedBox(height: AppLayout.paddingXL),

                    // ── Quick Actions (Practice / Quiz) ──
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.school_rounded,
                            label: '연습',
                            description: '학습한 표현 복습',
                            color: AppColors.primaryColor(context),
                            bgColor: AppColors.primaryColor(context).withValues(alpha: 0.08),
                            borderColor: AppColors.primaryColor(context).withValues(alpha: 0.15),
                            onTap: () {
                              final cats = phraseProvider.categories;
                              if (cats.isNotEmpty) {
                                context.push('/practice/${cats.first.id}');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppLayout.gapLG),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.quiz_rounded,
                            label: '퀴즈',
                            description: '실력을 테스트',
                            color: AppColors.secondaryColor(context),
                            bgColor: AppColors.secondaryColor(context).withValues(alpha: 0.08),
                            borderColor: AppColors.secondaryColor(context).withValues(alpha: 0.15),
                            onTap: () => context.push('/quiz'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppLayout.paddingXL),

                    // ── Continue Learning (가로 스크롤 카테고리) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '이어서 학습하기',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimaryColor(context),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/categories'),
                          child: Text(
                            '전체 보기',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primaryColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppLayout.gapMD),
                  ],
                ),
              ),
            ),

            // 가로 스크롤 카테고리 카드 (좌우 패딩 포함)
            Transform.translate(
              offset: const Offset(0, -AppLayout.paddingMD),
              child: SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppLayout.screenPadding,
                  ),
                  itemCount: phraseProvider.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppLayout.gapMD),
                  itemBuilder: (context, i) {
                    final cat = phraseProvider.categories[i];
                    final catPhraseIds = phraseProvider
                        .getPhrasesByCategory(cat.id)
                        .map((p) => p.id)
                        .toList();
                    final catProgress = progressProvider.categoryProgress(
                      {cat.id: catPhraseIds},
                    );
                    final progressVal = catProgress[cat.id] ?? 0.0;

                    return Semantics(
                      button: true,
                      label: '${cat.name} 카테고리, ${cat.phraseCount}개 표현, ${(progressVal * 100).toInt()}% 완료',
                      child: GestureDetector(
                        onTap: () => context.push('/phrase-list/${cat.id}'),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(AppLayout.paddingMD),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor(context),
                            borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                            border: Border.all(
                              color: AppColors.borderColor(context),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: AppLayout.elevationSM,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 카테고리 아이콘
                              Container(
                                width: AppLayout.buttonHeightSM,
                                height: AppLayout.buttonHeightSM,
                                decoration: BoxDecoration(
                                  color: cat.color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: cat.color,
                                  size: AppLayout.iconMD,
                                ),
                              ),
                              const SizedBox(height: AppLayout.gapMD),
                              // 카테고리명
                              Text(
                                cat.name,
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: AppColors.textPrimaryColor(context),
                                ),
                              ),
                              const SizedBox(height: AppLayout.gapXS),
                              Text(
                                '${cat.phraseCount}개 표현',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondaryColor(context),
                                ),
                              ),
                              const Spacer(),
                              // 카테고리 진행률 바
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                                child: LinearProgressIndicator(
                                  value: progressVal.clamp(0.0, 1.0),
                                  backgroundColor: AppColors.surfaceAltColor(context),
                                  valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: AppLayout.paddingLG),
            ], // else (not searching)
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label 바로가기, $description',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppLayout.paddingMD),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppLayout.radiusLG),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppLayout.buttonHeightSM,
                height: AppLayout.buttonHeightSM,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                ),
                child: Icon(icon, color: color, size: AppLayout.iconMD),
              ),
              const SizedBox(height: AppLayout.gapMD),
              Text(
                label,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimaryColor(context),
                ),
              ),
              const SizedBox(height: AppLayout.gapXS),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final PhraseProvider phraseProvider;
  final ProgressProvider progressProvider;

  const _SearchResults({
    required this.query,
    required this.phraseProvider,
    required this.progressProvider,
  });

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();
    final results = phraseProvider.categories
        .expand((cat) => phraseProvider.getPhrasesByCategory(cat.id))
        .where((p) =>
            p.english.toLowerCase().contains(q) ||
            p.korean.contains(query))
        .take(20)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.screenPadding,
        vertical: AppLayout.paddingSM,
      ),
      child: results.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppLayout.paddingXXL),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: AppLayout.iconXL,
                      color: AppColors.textDisabledColor(context),
                    ),
                    const SizedBox(height: AppLayout.gapLG),
                    Text(
                      "'$query'에 대한 결과가 없어요.",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '검색 결과 ${results.length}개',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: AppLayout.gapMD),
                ...results.map((phrase) {
                  final isLearned = progressProvider.isLearned(phrase.id);
                  final cat = phraseProvider.getCategoryById(phrase.categoryId);
                  return GestureDetector(
                    onTap: () => context.push('/phrase/${phrase.id}'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppLayout.gapSM),
                      padding: const EdgeInsets.all(AppLayout.paddingMD),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor(context),
                        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                        border: Border.all(
                          color: AppColors.borderColor(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 카테고리 + 학습 상태
                                Row(
                                  children: [
                                    if (cat != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppLayout.paddingSM - 2,
                                          vertical: AppLayout.paddingXS - 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cat.color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                                        ),
                                        child: Text(
                                          cat.name,
                                          style: AppTextStyles.caption.copyWith(
                                            color: cat.color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    if (isLearned) ...[
                                      const SizedBox(width: AppLayout.gapSM),
                                      Icon(
                                        Icons.check_circle,
                                        size: AppLayout.iconSM - 4,
                                        color: AppColors.secondaryColor(context),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: AppLayout.gapSM),
                                Text(
                                  phrase.english,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.textPrimaryColor(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppLayout.gapXS),
                                Text(
                                  phrase.korean,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondaryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textDisabledColor(context),
                            size: AppLayout.iconMD,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
