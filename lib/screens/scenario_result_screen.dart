import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../models/scenario.dart';
import '../providers/scenario_provider.dart';
import '../providers/phrase_provider.dart';
import '../widgets/common/custom_button.dart';

class ScenarioResultScreen extends StatelessWidget {
  final String scenarioId;

  const ScenarioResultScreen({super.key, required this.scenarioId});

  @override
  Widget build(BuildContext context) {
    final scenarioProvider = context.watch<ScenarioProvider>();
    final phraseProvider = context.read<PhraseProvider>();

    final scenario = scenarioProvider.scenarios
        .where((s) => s.id == scenarioId)
        .firstOrNull;
    final result = scenarioProvider.results
        .where((r) => r.scenarioId == scenarioId)
        .lastOrNull;

    if (scenario == null || result == null) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          title: const Text('결과'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/scenario-list'),
          ),
        ),
        body: Center(
          child: Text(
            '결과를 찾을 수 없습니다.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(context),
            ),
          ),
        ),
      );
    }

    final gradeColor = _gradeColor(result.grade, context);
    final gradeLabel = _gradeLabel(result.grade);

    // Collect related phrase IDs from perfect choices
    final relatedPhraseIds = <String>[];
    for (var i = 0; i < result.choiceHistory.length && i < scenario.turns.length; i++) {
      if (result.choiceHistory[i] == ChoiceResult.perfect) {
        final turn = scenario.turns[i];
        final perfectChoice = turn.choices
            .where((c) => c.result == ChoiceResult.perfect)
            .firstOrNull;
        if (perfectChoice?.relatedPhraseId != null) {
          relatedPhraseIds.add(perfectChoice!.relatedPhraseId!);
        }
      }
    }

    final relatedPhrases = relatedPhraseIds
        .map((id) => phraseProvider.getPhraseById(id))
        .where((p) => p != null)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '결과',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimaryColor(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimaryColor(context)),
          onPressed: () => context.go('/scenario-list'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.screenPadding,
          vertical: AppLayout.paddingLG,
        ),
        child: Column(
          children: [
            // Grade circle badge
            _buildGradeBadge(context, result.grade, gradeColor, gradeLabel),
            const SizedBox(height: AppLayout.gapLG),

            // Summary stats
            Text(
              '${result.perfectCount}/${result.turnsCompleted} Perfect · ${result.awkwardCount} Awkward',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryColor(context),
              ),
            ),
            const SizedBox(height: AppLayout.paddingXL),

            // Turn-by-turn review section
            _buildSectionHeader(context, '턴별 리뷰'),
            const SizedBox(height: AppLayout.gapMD),
            _buildTurnReviewList(context, scenario, result),

            // Related phrases section
            if (relatedPhrases.isNotEmpty) ...[
              const SizedBox(height: AppLayout.paddingXL),
              _buildSectionHeader(context, '이 시나리오에서 배운 표현'),
              const SizedBox(height: AppLayout.gapMD),
              ...relatedPhrases.map((phrase) =>
                  _buildPhraseCard(context, phrase!)),
            ],

            const SizedBox(height: AppLayout.paddingXL),

            // Action buttons
            CustomButton(
              label: '다시 도전하기',
              variant: ButtonVariant.primary,
              onPressed: () =>
                  context.pushReplacement('/scenario-play/$scenarioId'),
            ),
            const SizedBox(height: AppLayout.gapMD),
            CustomButton(
              label: '목록으로 돌아가기',
              variant: ButtonVariant.outline,
              onPressed: () => context.go('/scenario-list'),
            ),
            const SizedBox(height: AppLayout.paddingLG),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeBadge(
    BuildContext context,
    ScenarioGrade grade,
    Color gradeColor,
    String gradeLabel,
  ) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gradeColor.withValues(alpha: 0.1),
        border: Border.all(color: gradeColor.withValues(alpha: 0.3), width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            grade.name,
            style: AppTextStyles.displayLarge.copyWith(
              color: gradeColor,
            ),
          ),
          Text(
            gradeLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: gradeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.borderColor(context)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.paddingMD),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondaryColor(context),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.borderColor(context)),
        ),
      ],
    );
  }

  Widget _buildTurnReviewList(
    BuildContext context,
    Scenario scenario,
    ScenarioResult result,
  ) {
    return Column(
      children: List.generate(
        result.choiceHistory.length,
        (i) {
          if (i >= scenario.turns.length) return const SizedBox.shrink();
          final turn = scenario.turns[i];
          final choiceResult = result.choiceHistory[i];
          final selectedChoice = turn.choices
              .where((c) => c.result == choiceResult)
              .firstOrNull;

          if (selectedChoice == null) return const SizedBox.shrink();

          return _buildTurnReviewCard(
            context,
            turnNumber: i + 1,
            situation: turn.situation,
            choice: selectedChoice,
            choiceResult: choiceResult,
          );
        },
      ),
    );
  }

  Widget _buildTurnReviewCard(
    BuildContext context, {
    required int turnNumber,
    required String situation,
    required ScenarioChoice choice,
    required ChoiceResult choiceResult,
  }) {
    final icon = switch (choiceResult) {
      ChoiceResult.perfect => Icons.check_circle,
      ChoiceResult.awkward => Icons.warning_rounded,
      ChoiceResult.fail => Icons.cancel,
    };
    final iconColor = switch (choiceResult) {
      ChoiceResult.perfect => AppColors.secondaryColor(context),
      ChoiceResult.awkward => AppColors.accentColor(context),
      ChoiceResult.fail => AppColors.errorColor(context),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppLayout.gapMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Turn header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.paddingMD,
              AppLayout.paddingMD,
              AppLayout.paddingMD,
              AppLayout.paddingSM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Turn number + situation
                Text(
                  '$turnNumber️⃣  $situation',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: AppLayout.gapSM),
                // Selected expression
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: AppLayout.iconSM, color: iconColor),
                    const SizedBox(width: AppLayout.gapXS),
                    Expanded(
                      child: Text(
                        '"${choice.english}"',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimaryColor(context),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Explanation expansion tile
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppLayout.paddingMD,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                AppLayout.paddingMD,
                0,
                AppLayout.paddingMD,
                AppLayout.paddingMD,
              ),
              title: Text(
                '해설 보기',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryColor(context),
                ),
              ),
              iconColor: AppColors.primaryColor(context),
              collapsedIconColor: AppColors.primaryColor(context),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppLayout.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAltColor(context),
                    borderRadius: BorderRadius.circular(AppLayout.radiusSM),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          choice.explanation,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseCard(BuildContext context, dynamic phrase) {
    return Semantics(
      button: true,
      label: '${phrase.english} 표현 상세보기',
      child: GestureDetector(
        onTap: () => context.push('/phrase/${phrase.id}'),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppLayout.gapSM),
          padding: const EdgeInsets.all(AppLayout.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(AppLayout.radiusMD),
            border: Border.all(color: AppColors.borderColor(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase.english,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: AppLayout.gapXS),
                    Text(
                      phrase.korean,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondaryColor(context),
                size: AppLayout.iconMD,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _gradeColor(ScenarioGrade grade, BuildContext context) {
    switch (grade) {
      case ScenarioGrade.S:
        return Colors.amber;
      case ScenarioGrade.A:
        return AppColors.secondaryColor(context);
      case ScenarioGrade.B:
        return AppColors.primaryColor(context);
      case ScenarioGrade.C:
        return AppColors.textSecondaryColor(context);
      case ScenarioGrade.F:
        return AppColors.errorColor(context);
    }
  }

  String _gradeLabel(ScenarioGrade grade) {
    switch (grade) {
      case ScenarioGrade.S:
        return 'Perfect!';
      case ScenarioGrade.A:
        return 'Great!';
      case ScenarioGrade.B:
        return 'Good!';
      case ScenarioGrade.C:
        return 'Not Bad';
      case ScenarioGrade.F:
        return 'Game Over';
    }
  }
}
