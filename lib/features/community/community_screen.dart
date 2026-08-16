import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/widgets/paw_image.dart';
import '../../core/widgets/pill_toast.dart';
import '../../models/community_post_model.dart';
import '../../providers/community_provider.dart';
import '../../services/community_service.dart';
import 'widgets/heart_pop_button.dart';
import 'widgets/new_post_modal.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  Color _getCategoryBorderColor(String category) {
    switch (category) {
      case 'sos':
        return AppColors.accentRed;
      case 'training':
        return AppColors.accentBlue;
      case 'health':
        return AppColors.accentGreen;
      default:
        return AppColors.glassBorder;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин назад';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ч назад';
    } else {
      return '${diff.inDays} дн назад';
    }
  }

  void _openNewPostModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewPostModal(
        onPublish: (newPost) {
          ref.read(communityNotifierProvider.notifier).addPost(newPost);
          PawToast.show(
            context,
            title: 'Пост опубликован в сообществе',
            type: ToastType.success,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityNotifierProvider);
    final communityNotifier = ref.read(communityNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Title
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Лента Сообщества',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openNewPostModal(context, ref),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // 1. Novosibirsk 10 Districts Horizontal Filter Row
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: CommunityService.novosibirskDistricts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final district = CommunityService.novosibirskDistricts[index];
                  final isSelected = communityState.selectedDistrict == district;

                  return GlassCapsule(
                    isActive: isSelected,
                    activeColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    onTap: () => communityNotifier.setDistrict(district),
                    child: Text(
                      district,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 2. Category Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TopicCategoryFilter(
                      label: 'Все темы',
                      category: 'all',
                      isSelected: communityState.selectedCategory == 'all',
                      activeColor: AppColors.textPrimary,
                      onTap: () => communityNotifier.setCategory('all'),
                    ),
                    const SizedBox(width: 8),
                    _TopicCategoryFilter(
                      label: '🏥 Здоровье',
                      category: 'health',
                      isSelected: communityState.selectedCategory == 'health',
                      activeColor: AppColors.accentGreen,
                      onTap: () => communityNotifier.setCategory('health'),
                    ),
                    const SizedBox(width: 8),
                    _TopicCategoryFilter(
                      label: '🦮 Дрессировка',
                      category: 'training',
                      isSelected: communityState.selectedCategory == 'training',
                      activeColor: AppColors.accentBlue,
                      onTap: () => communityNotifier.setCategory('training'),
                    ),
                    const SizedBox(width: 8),
                    _TopicCategoryFilter(
                      label: '🚨 SOS',
                      category: 'sos',
                      isSelected: communityState.selectedCategory == 'sos',
                      activeColor: AppColors.accentRed,
                      onTap: () => communityNotifier.setCategory('sos'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Posts List Feed
            Expanded(
              child: communityState.filteredPosts.isEmpty
                  ? const Center(
                      child: Text(
                        'В этом районе пока нет публикаций',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                      itemCount: communityState.filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = communityState.filteredPosts[index];
                        final borderColor = _getCategoryBorderColor(post.category);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: _PostCard(
                            post: post,
                            borderColor: borderColor,
                            timeAgo: _formatTimeAgo(post.createdAt),
                            onLike: () {
                              communityNotifier.toggleLike(post.id);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCategoryFilter extends StatelessWidget {
  final String label;
  final String category;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TopicCategoryFilter({
    required this.label,
    required this.category,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCapsule(
      isActive: isSelected,
      activeColor: activeColor,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPostModel post;
  final Color borderColor;
  final String timeAgo;
  final VoidCallback onLike;

  const _PostCard({
    required this.post,
    required this.borderColor,
    required this.timeAgo,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: borderColor,
              width: 4.5,
            ),
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Avatar & Meta Header
            Row(
              children: [
                PawAvatar(
                  url: post.authorAvatar,
                  radius: 20,
                  fallbackColor: AppColors.accentBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.district,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Post Content Text
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              PawImage(
                url: post.imageUrl,
                width: double.infinity,
                height: 180,
                borderRadius: 16,
                fallbackColor: AppColors.accentBlue,
              ),
            ],

            const SizedBox(height: 14),

            // Post Footer: Heart Pop Like Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeartPopButton(
                  isLiked: post.isLiked,
                  likesCount: post.likesCount,
                  onTap: onLike,
                ),
                TextButton.icon(
                  onPressed: () {
                    PawToast.show(
                      context,
                      title: 'Комментарии откроются в полной версии',
                      type: ToastType.info,
                    );
                  },
                  icon: const Icon(Icons.mode_comment_outlined, size: 16, color: AppColors.textSecondary),
                  label: const Text(
                    'Ответить',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
