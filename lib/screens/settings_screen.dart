import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../models/phrase.dart';
import '../providers/settings_provider.dart';
import '../providers/progress_provider.dart';
import '../services/sherpa_tts_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    final levelLabel = switch (settings.level) {
      Difficulty.beginner => '초급',
      Difficulty.intermediate => '중급',
      Difficulty.advanced => '고급',
    };

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        title: Text('설정', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppLayout.paddingMD),

            // 학습 설정
            _SectionHeader(title: '학습 설정'),
            _SettingsCard(
              children: [
                // 학습 레벨
                _SettingsTile(
                  icon: Icons.school_outlined,
                  title: '학습 레벨',
                  trailing: GestureDetector(
                    onTap: () => _showLevelPicker(context, settings),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(levelLabel,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.primary)),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            color: AppColors.textSecondaryColor(context),
                            size: 18),
                      ],
                    ),
                  ),
                ),
                _Divider(),
                // 일일 학습 목표
                _SettingsTile(
                  icon: Icons.flag_outlined,
                  title: '일일 학습 목표',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [5, 10, 20].map((g) {
                      final isSelected = settings.dailyGoal == g;
                      return GestureDetector(
                        onTap: () => settings.setDailyGoal(g),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceAltColor(context),
                            borderRadius:
                                BorderRadius.circular(AppLayout.radiusCircle),
                          ),
                          child: Text(
                            '$g개',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondaryColor(context),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppLayout.paddingSM),

            // 음성 설정
            _SectionHeader(title: '음성 설정'),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.record_voice_over_outlined,
                  title: '보이스 ID',
                  subtitle: '다중 화자 모델 (0~${SherpaTtsService.maxSpeakerId})',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ID ${settings.ttsSpeakerId}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondaryColor(context),
                        size: 18,
                      ),
                    ],
                  ),
                  onTap: () => _showVoicePicker(context, settings),
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.speed_outlined,
                  title: '음성 속도',
                  subtitle: settings.speechRate <= 0.3
                      ? '느리게'
                      : settings.speechRate <= 0.5
                          ? '보통'
                          : '빠르게',
                  trailing: SizedBox(
                    width: 140,
                    child: Slider(
                      value: settings.speechRate,
                      min: 0.2,
                      max: 0.7,
                      divisions: 5,
                      activeColor: AppColors.primary,
                      onChanged: (v) => settings.setSpeechRate(v),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppLayout.paddingSM),

            // 알림 설정
            _SectionHeader(title: '알림 설정'),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: '학습 알림',
                  trailing: Switch(
                    value: settings.isNotificationEnabled,
                    onChanged: (v) => settings.setNotificationEnabled(v),
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                if (settings.isNotificationEnabled) ...[
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.access_time_outlined,
                    title: '알림 시간',
                    trailing: GestureDetector(
                      onTap: () => _showTimePicker(context, settings),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(settings.notificationTime,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.primary)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: AppColors.textSecondaryColor(context),
                              size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppLayout.paddingSM),

            // 앱 정보
            _SectionHeader(title: '앱 정보'),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: '버전',
                  trailing: Text('1.0.0',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondaryColor(context))),
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.restart_alt,
                  title: '학습 초기화',
                  titleColor: AppColors.error,
                  trailing: Icon(Icons.chevron_right,
                      color: AppColors.textSecondaryColor(context), size: 18),
                  onTap: () => _showResetDialog(context, progressProvider),
                ),
              ],
            ),

            const SizedBox(height: AppLayout.paddingXXL),
          ],
        ),
      ),
    );
  }

  void _showLevelPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppLayout.radiusXL)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppLayout.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('학습 레벨 선택', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppLayout.paddingMD),
            ...Difficulty.values.map((d) {
              final label = switch (d) {
                Difficulty.beginner => '초급',
                Difficulty.intermediate => '중급',
                Difficulty.advanced => '고급',
              };
              final isSelected = settings.level == d;
              return ListTile(
                title: Text(label, style: AppTextStyles.bodyLarge),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setLevel(d);
                  Navigator.of(context).pop();
                },
              );
            }),
            const SizedBox(height: AppLayout.paddingMD),
          ],
        ),
      ),
    );
  }

  void _showVoicePicker(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(
      text: settings.ttsSpeakerId.toString(),
    );
    int selectedId = settings.ttsSpeakerId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppLayout.radiusXL)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void pick(int id) {
              selectedId = id;
              controller.text = id.toString();
              setModalState(() {});
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppLayout.paddingLG,
                AppLayout.paddingLG,
                AppLayout.paddingLG,
                MediaQuery.of(sheetContext).viewInsets.bottom +
                    AppLayout.paddingLG,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('보이스 선택', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppLayout.gapSM),
                  Text(
                    '성별 라벨 대신 화자 ID로 선택합니다.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryColor(context),
                    ),
                  ),
                  const SizedBox(height: AppLayout.paddingMD),
                  Wrap(
                    spacing: AppLayout.gapSM,
                    runSpacing: AppLayout.gapSM,
                    children: SherpaTtsService.recommendedSpeakerIds
                        .map((id) => ChoiceChip(
                              label: Text('ID $id'),
                              selected: selectedId == id,
                              onSelected: (_) => pick(id),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppLayout.paddingMD),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '직접 입력',
                      hintText: '0 ~ ${SherpaTtsService.maxSpeakerId}',
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null) return;
                      final clamped = parsed
                          .clamp(0, SherpaTtsService.maxSpeakerId)
                          .toInt();
                      selectedId = clamped;
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: AppLayout.paddingLG),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: AppLayout.gapMD),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final parsed = int.tryParse(controller.text.trim());
                            final finalId = (parsed ?? selectedId)
                                .clamp(0, SherpaTtsService.maxSpeakerId)
                                .toInt();
                            settings.setTtsSpeakerId(finalId);
                            Navigator.of(sheetContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('적용'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Future<void> _showTimePicker(
      BuildContext context, SettingsProvider settings) async {
    final parts = settings.notificationTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      settings.setNotificationTime(timeStr);
    }
  }

  void _showResetDialog(
      BuildContext context, ProgressProvider progressProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.radiusLG)),
        title: const Text('학습 초기화'),
        content: const Text('모든 학습 기록이 삭제됩니다. 계속하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: ProgressProvider에 reset 메서드 추가 후 연결
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('학습 기록이 초기화되었습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenPadding,
        AppLayout.paddingMD,
        AppLayout.screenPadding,
        AppLayout.gapSM,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textSecondaryColor(context)),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppLayout.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppLayout.paddingMD,
          vertical: AppLayout.paddingMD,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: AppColors.textSecondaryColor(context),
                size: AppLayout.iconSM + 2),
            const SizedBox(width: AppLayout.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(color: titleColor),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 52, endIndent: 0);
  }
}
