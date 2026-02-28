import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../providers/progress_provider.dart';
import '../providers/phrase_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final phraseProvider = context.watch<PhraseProvider>();
    final progress = progressProvider.progress;
    final weeklyRecords = progressProvider.weeklyRecords;
    final totalPhrases = phraseProvider.phrases.length;
    final learnedCount = progress.learnedPhraseIds.length;
    final completionRate = totalPhrases > 0 ? learnedCount / totalPhrases : 0.0;

    // 카테고리별 달성률
    final categoryPhraseIds = <String, List<String>>{};
    for (final cat in phraseProvider.categories) {
      categoryPhraseIds[cat.id] =
          phraseProvider.getPhrasesByCategory(cat.id).map((p) => p.id).toList();
    }
    final catProgress = progressProvider.categoryProgress(categoryPhraseIds);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        title: Text('학습 통계', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 카드들
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    color: AppColors.accent,
                    label: '연속 학습',
                    value: '${progress.streakDays}일',
                  ),
                ),
                const SizedBox(width: AppLayout.gapMD),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_outline,
                    color: AppColors.secondary,
                    label: '학습 완료',
                    value: '$learnedCount개',
                  ),
                ),
                const SizedBox(width: AppLayout.gapMD),
                Expanded(
                  child: _StatCard(
                    icon: Icons.percent,
                    color: AppColors.primary,
                    label: '완료율',
                    value: '${(completionRate * 100).round()}%',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppLayout.paddingXL),

            // 주간 차트
            Text('이번 주 학습', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppLayout.paddingMD),
            Container(
              padding: const EdgeInsets.all(AppLayout.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                borderRadius: BorderRadius.circular(AppLayout.radiusLG),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklyRecords.map((record) {
                        final maxVal = weeklyRecords
                            .map((r) => r.phrasesLearned)
                            .reduce((a, b) => a > b ? a : b);
                        final ratio = maxVal > 0 ? record.phrasesLearned / maxVal : 0.0;
                        final isToday = record.date == _todayString();
                        final dayName = _dayName(record.date);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (record.phrasesLearned > 0)
                                  Text(
                                    '${record.phrasesLearned}',
                                    style: AppTextStyles.caption,
                                  ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: double.infinity,
                                    height: 80 * ratio + (record.phrasesLearned > 0 ? 8 : 2),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? AppColors.primary
                                          : AppColors.primary.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dayName,
                                  style: AppTextStyles.caption.copyWith(
                                    color: isToday ? AppColors.primary : AppColors.textSecondaryColor(context),
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppLayout.paddingXL),

            // 카테고리별 달성률
            Text('카테고리별 달성률', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppLayout.paddingMD),
            ...phraseProvider.categories.map((cat) {
              final pct = catProgress[cat.id] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppLayout.gapMD),
                child: Container(
                  padding: const EdgeInsets.all(AppLayout.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(context),
                    borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppLayout.radiusSM),
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 18),
                      ),
                      const SizedBox(width: AppLayout.gapMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat.name, style: AppTextStyles.titleMedium),
                                Text(
                                  '${(pct * 100).round()}%',
                                  style: AppTextStyles.labelMedium.copyWith(color: cat.color),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.surfaceAltColor(context),
                                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: AppLayout.paddingLG),

            // 획득 배지
            Text('획득 배지', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppLayout.paddingMD),
            Wrap(
              spacing: AppLayout.gapMD,
              runSpacing: AppLayout.gapMD,
              children: _getBadges(progress.streakDays, learnedCount).map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(badge.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(badge.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent)),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppLayout.paddingXL),
          ],
        ),
      ),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _dayName(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const days = ['일', '월', '화', '수', '목', '금', '토'];
      return days[date.weekday % 7];
    } catch (_) {
      return '';
    }
  }

  List<_Badge> _getBadges(int streak, int learned) {
    final badges = <_Badge>[];
    if (streak >= 1) badges.add(_Badge('🔥', '첫 학습'));
    if (streak >= 3) badges.add(_Badge('⚡', '3일 연속'));
    if (streak >= 7) badges.add(_Badge('🌟', '7일 연속'));
    if (learned >= 10) badges.add(_Badge('📚', '10개 완료'));
    if (learned >= 30) badges.add(_Badge('🏆', '30개 완료'));
    if (learned >= 80) badges.add(_Badge('👑', '전체 완료'));
    if (badges.isEmpty) badges.add(_Badge('🌱', '시작!'));
    return badges;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppLayout.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppLayout.iconMD),
          const SizedBox(height: AppLayout.gapSM),
          Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)),
          Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Badge {
  final String emoji;
  final String label;

  const _Badge(this.emoji, this.label);
}
