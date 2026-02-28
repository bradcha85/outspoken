import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../providers/scenario_provider.dart';
import '../models/scenario.dart';

class ScenarioListScreen extends StatelessWidget {
  const ScenarioListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenarioProvider = context.watch<ScenarioProvider>();
    final scenarios = scenarioProvider.scenarios;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimaryColor(context),
            size: AppLayout.iconMD,
          ),
        ),
        title: Text(
          '대화 서바이벌',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimaryColor(context),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenPadding,
          AppLayout.paddingSM,
          AppLayout.screenPadding,
          AppLayout.paddingLG,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Header section --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppLayout.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppLayout.radiusMD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '실전 대화에 도전하세요!',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: AppLayout.gapXS),
                  Text(
                    '상황에 맞는 표현을 골라 대화를 이어가 보세요.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppLayout.gapXL),

            // -- Scenario cards --
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scenarios.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppLayout.gapMD),
              itemBuilder: (context, index) {
                final scenario = scenarios[index];
                final bestGrade = scenarioProvider.bestGrade(scenario.id);
                return _ScenarioCard(
                  scenario: scenario,
                  bestGrade: bestGrade,
                  onTap: () => context.push('/scenario-play/${scenario.id}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final Scenario scenario;
  final ScenarioGrade? bestGrade;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.bestGrade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        AppColors.categoryColors[scenario.categoryId] ?? AppColors.primary;

    return Semantics(
      button: true,
      label: '${scenario.title} 시나리오, ${bestGrade != null ? '최고 등급 ${bestGrade!.name}' : '새로운 시나리오'}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppLayout.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(AppLayout.radiusMD),
            border: Border.all(color: AppColors.borderColor(context)),
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
              // Category color circle
              Container(
                width: AppLayout.iconXL,
                height: AppLayout.iconXL,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: AppLayout.iconMD,
                    height: AppLayout.iconMD,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppLayout.gapLG),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: AppLayout.gapXS),
                    Text(
                      scenario.titleEn,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppLayout.gapSM),
                    Text(
                      scenario.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryColor(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppLayout.gapMD),

              // Grade badge or NEW
              _GradeBadge(grade: bestGrade),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final ScenarioGrade? grade;

  const _GradeBadge({required this.grade});

  @override
  Widget build(BuildContext context) {
    if (grade == null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.paddingSM,
          vertical: AppLayout.paddingXS,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryColor(context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppLayout.radiusSM),
        ),
        child: Text(
          'NEW',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final (Color bgColor, Color textColor) = _gradeColors(grade!);

    return Container(
      width: AppLayout.iconLG + AppLayout.gapSM,
      height: AppLayout.iconLG + AppLayout.gapSM,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          grade!.name,
          style: AppTextStyles.titleLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  (Color, Color) _gradeColors(ScenarioGrade grade) {
    return switch (grade) {
      ScenarioGrade.S => (const Color(0xFFF59E0B), const Color(0xFFB45309)),
      ScenarioGrade.A => (const Color(0xFF10B981), const Color(0xFF047857)),
      ScenarioGrade.B => (const Color(0xFF3B82F6), const Color(0xFF1D4ED8)),
      ScenarioGrade.C => (const Color(0xFF94A3B8), const Color(0xFF64748B)),
      ScenarioGrade.F => (const Color(0xFFEF4444), const Color(0xFFB91C1C)),
    };
  }
}
