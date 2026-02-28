import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../models/phrase.dart';
import '../providers/settings_provider.dart';
import '../widgets/common/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Difficulty? _selected;

  static const _levels = [
    _LevelCard(
      difficulty: Difficulty.beginner,
      emoji: '🌱',
      title: '초급',
      subtitle: 'Beginner',
      description: '기초 표현부터 천천히 시작해요.\n일상 대화의 첫걸음을 떼어봐요.',
      color: AppColors.secondary,
    ),
    _LevelCard(
      difficulty: Difficulty.intermediate,
      emoji: '🚀',
      title: '중급',
      subtitle: 'Intermediate',
      description: '기초는 알지만 더 자연스럽게\n말하고 싶은 분에게 맞아요.',
      color: AppColors.primary,
    ),
    _LevelCard(
      difficulty: Difficulty.advanced,
      emoji: '⚡',
      title: '고급',
      subtitle: 'Advanced',
      description: '다양한 상황에서 세련된 영어로\n소통할 수 있도록 연습해요.',
      color: AppColors.accent,
    ),
  ];

  Future<void> _onStart() async {
    if (_selected == null) return;
    await context.read<SettingsProvider>().setLevel(_selected!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_onboarded', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppLayout.paddingXL),
              Text('안녕하세요! 👋', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppLayout.paddingSM),
              Text(
                '나에게 맞는 학습 레벨을 선택해주세요.',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryColor(context)),
              ),
              const SizedBox(height: AppLayout.paddingXL),
              Expanded(
                child: ListView.separated(
                  itemCount: _levels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppLayout.gapMD),
                  itemBuilder: (context, i) {
                    final level = _levels[i];
                    final isSelected = _selected == level.difficulty;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = level.difficulty),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppLayout.paddingMD),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? level.color.withValues(alpha: 0.08)
                              : AppColors.surfaceColor(context),
                          borderRadius: BorderRadius.circular(AppLayout.radiusLG),
                          border: Border.all(
                            color: isSelected ? level.color : AppColors.borderColor(context),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: level.color.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: level.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                              ),
                              child: Center(
                                child: Text(level.emoji, style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                            const SizedBox(width: AppLayout.gapMD),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(level.title, style: AppTextStyles.headlineSmall),
                                      const SizedBox(width: AppLayout.gapSM),
                                      Text(
                                        level.subtitle,
                                        style: AppTextStyles.bodySmall.copyWith(color: level.color),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    level.description,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: level.color, size: AppLayout.iconMD),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppLayout.paddingLG),
              CustomButton(
                label: '시작하기',
                onPressed: _selected != null ? _onStart : null,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: AppLayout.paddingSM),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard {
  final Difficulty difficulty;
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const _LevelCard({
    required this.difficulty,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
