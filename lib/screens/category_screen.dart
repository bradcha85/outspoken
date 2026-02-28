import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../providers/phrase_provider.dart';
import '../providers/progress_provider.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _query = '';
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final phraseProvider = context.watch<PhraseProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final categories = phraseProvider.categories
        .where((c) =>
            _query.isEmpty ||
            c.name.contains(_query) ||
            c.nameEn.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── 헤더 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.screenPadding,
                AppLayout.paddingMD,
                AppLayout.screenPadding,
                AppLayout.paddingSM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '카테고리',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showSearch = !_showSearch),
                    child: Semantics(
                      button: true,
                      label: '검색',
                      child: Container(
                        width: AppLayout.buttonHeightSM,
                        height: AppLayout.buttonHeightSM,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceColor(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: AppLayout.elevationSM,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          _showSearch ? Icons.close : Icons.search,
                          color: AppColors.textSecondaryColor(context),
                          size: AppLayout.iconMD,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 검색 바 (토글) ──
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenPadding,
                  AppLayout.paddingXS,
                  AppLayout.screenPadding,
                  AppLayout.paddingSM,
                ),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: '카테고리 검색...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDisabledColor(context),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondaryColor(context),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAltColor(context),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppLayout.gapMD,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // ── 본문 ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenPadding,
                  AppLayout.paddingSM,
                  AppLayout.screenPadding,
                  AppLayout.paddingLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 카테고리 그리드 ──
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppLayout.gapLG,
                        mainAxisSpacing: AppLayout.gapLG,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final phrases = phraseProvider.getPhrasesByCategory(cat.id);
                        final learnedCount = phrases
                            .where((p) => progressProvider.isLearned(p.id))
                            .length;
                        final completion =
                            phrases.isEmpty ? 0.0 : learnedCount / phrases.length;
                        return _CategoryCard(
                          category: cat,
                          completion: completion,
                          onTap: () => context.push('/phrase-list/${cat.id}'),
                        );
                      },
                    ),

                    const SizedBox(height: AppLayout.paddingXL),

                    // ── 추천 학습 섹션 ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '추천 학습',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.textPrimaryColor(context),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/quiz'),
                          child: Text(
                            '모두 보기',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primaryColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppLayout.gapLG),

                    // 일일 퀴즈 도전 카드
                    Semantics(
                      button: true,
                      label: '일일 퀴즈 도전, 오늘 배운 표현을 복습해보세요',
                      child: GestureDetector(
                        onTap: () => context.push('/quiz'),
                        child: Container(
                          padding: const EdgeInsets.all(AppLayout.paddingMD),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor(context),
                            borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: AppLayout.elevationSM,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // 아이콘
                              Container(
                                width: AppLayout.iconXL,
                                height: AppLayout.iconXL,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor(context).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.trending_up_rounded,
                                  color: AppColors.primaryColor(context),
                                  size: AppLayout.iconMD,
                                ),
                              ),
                              const SizedBox(width: AppLayout.gapLG),
                              // 텍스트
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '일일 퀴즈 도전',
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: AppColors.textPrimaryColor(context),
                                      ),
                                    ),
                                    const SizedBox(height: AppLayout.gapXS),
                                    Text(
                                      '오늘 배운 표현을 복습해보세요.',
                                      style: AppTextStyles.bodySmall.copyWith(
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final double completion;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.completion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.name} 카테고리, ${category.phraseCount}개 표현, ${(completion * 100).round()}% 완료',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(AppLayout.radiusMD),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: AppLayout.elevationMD,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 카드 콘텐츠
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.paddingMD,
                    AppLayout.paddingLG,
                    AppLayout.paddingMD,
                    AppLayout.paddingSM,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 원형 아이콘 (솔리드 카테고리 색상)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.3),
                              blurRadius: AppLayout.elevationLG,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: AppLayout.iconLG - 4,
                        ),
                      ),
                      const SizedBox(height: AppLayout.gapLG),
                      // 한국어 이름
                      Text(
                        category.name,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimaryColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppLayout.gapXS),
                      // 영어 이름 (카테고리 색상)
                      Text(
                        category.nameEn,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppLayout.gapMD),
                      // 표현 수 pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppLayout.paddingSM,
                          vertical: AppLayout.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAltColor(context),
                          borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                        ),
                        child: Text(
                          '${category.phraseCount} 표현',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 하단 진행률 바 (카드 하단에 밀착)
              SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: completion.clamp(0.0, 1.0),
                  backgroundColor: AppColors.surfaceAltColor(context),
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
