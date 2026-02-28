import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/layout.dart';
import '../../constants/typography.dart';
import '../../models/phrase.dart';
import '../../providers/progress_provider.dart';

class PhraseListItem extends StatelessWidget {
  final Phrase phrase;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTtsPlay;

  const PhraseListItem({
    super.key,
    required this.phrase,
    this.onTap,
    this.onFavoriteToggle,
    this.onTtsPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, _) {
        final isFav = progress.isFavorite(phrase.id);
        final isLearned = progress.isLearned(phrase.id);

        return Semantics(
          button: true,
          label: '${phrase.english}, ${phrase.korean}${isLearned ? ', 학습 완료' : ''}${isFav ? ', 즐겨찾기' : ''}',
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenPadding,
                vertical: AppLayout.gapSM / 2,
              ),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 좌측: 배지 + 텍스트
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEARNED 배지
                        if (isLearned)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppLayout.gapXS,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppLayout.paddingSM,
                                vertical: AppLayout.paddingXS - 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor(context).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: AppLayout.iconSM - 6,
                                    color: AppColors.secondaryColor(context),
                                  ),
                                  const SizedBox(width: AppLayout.gapXS),
                                  Text(
                                    'LEARNED',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.secondaryColor(context),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: AppLayout.paddingXS),
                        // 영어 표현
                        Text(
                          phrase.english,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.textPrimaryColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppLayout.gapXS),
                        // 한국어 번역
                        Text(
                          phrase.korean,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 우측: TTS + 즐겨찾기 아이콘 (세로 배치)
                  Column(
                    children: [
                      // TTS 버튼
                      GestureDetector(
                        onTap: onTtsPlay,
                        child: Padding(
                          padding: const EdgeInsets.all(AppLayout.paddingXS),
                          child: Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.primaryColor(context),
                            size: AppLayout.iconMD,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppLayout.gapMD),
                      // 즐겨찾기 버튼
                      GestureDetector(
                        onTap: onFavoriteToggle ??
                            () => progress.toggleFavorite(phrase.id),
                        child: Padding(
                          padding: const EdgeInsets.all(AppLayout.paddingXS),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? Colors.redAccent
                                : AppColors.textDisabledColor(context),
                            size: AppLayout.iconMD,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
