import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../providers/phrase_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/phrase/phrase_list_item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phraseProvider = context.watch<PhraseProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final favIds = progressProvider.progress.favoritePhraseIds;
    final favorites = phraseProvider.phrases
        .where((p) => favIds.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('즐겨찾기', style: AppTextStyles.headlineSmall),
            Text('${favorites.length}개 표현', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryColor(context))),
          ],
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💙', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppLayout.paddingMD),
                  Text(
                    '즐겨찾기한 표현이 없어요.',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryColor(context)),
                  ),
                  const SizedBox(height: AppLayout.paddingSM),
                  Text(
                    '표현 상세 화면에서 ♥ 를 눌러 저장해보세요.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: AppLayout.paddingMD),
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, i) {
                      final phrase = favorites[i];
                      return Dismissible(
                        key: Key(phrase.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppLayout.paddingLG),
                          color: AppColors.error.withValues(alpha: 0.1),
                          child: const Icon(Icons.delete_outline, color: AppColors.error),
                        ),
                        onDismissed: (_) => progressProvider.toggleFavorite(phrase.id),
                        child: PhraseListItem(
                          phrase: phrase,
                          onTap: () => context.push('/phrase/${phrase.id}'),
                          onFavoriteToggle: () => progressProvider.toggleFavorite(phrase.id),
                        ),
                      );
                    },
                  ),
                ),
                // 즐겨찾기 퀴즈 버튼
                Padding(
                  padding: const EdgeInsets.all(AppLayout.screenPadding),
                  child: SizedBox(
                    width: double.infinity,
                    height: AppLayout.buttonHeight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('즐겨찾기 퀴즈 시작'),
                      onPressed: () => context.push('/quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
