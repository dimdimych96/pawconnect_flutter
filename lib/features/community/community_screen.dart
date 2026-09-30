import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/widgets/pill_toast.dart';
import '../../models/pet_story_model.dart';
import '../../providers/community_provider.dart';
import '../../services/community_service.dart';
import 'widgets/comments_bottom_sheet.dart';
import 'widgets/community_post_card.dart';
import 'widgets/community_stories_bar.dart';
import 'widgets/new_post_modal.dart';
import 'widgets/story_player_screen.dart';

/// Tab 0 (/feed): Instagram 2026 Liquid Glass Community Feed.
///
/// Features:
/// - Sticky Top Glass Header with PawConnect branding and quick action buttons.
/// - Novosibirsk 10 Districts filter bar and Category Pills.
/// - Stories Rail with full-screen StoryPlayerScreen navigation.
/// - Main Feed Stream with pull-to-refresh, skeleton loaders, and zero-stub error state.
/// - Apple Liquid Glass performance rules (NO BackdropFilter inside scrolling post cards).
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  void _openNewPostModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewPostModal(
        onPublish: (newPost) async {
          try {
            await ref.read(communityNotifierProvider.notifier).addPost(newPost);
            if (context.mounted) {
              PawToast.show(
                context,
                title: 'Пост опубликован в сообществе',
                type: ToastType.success,
              );
            }
          } catch (_) {
            if (context.mounted) {
              PawToast.show(
                context,
                title: 'Не удалось опубликовать пост',
                type: ToastType.alert,
              );
            }
          }
        },
      ),
    );
  }

  void _openStoryPlayer(
    BuildContext context,
    List<PetStoryModel> stories,
    int initialIndex,
    CommunityNotifier notifier,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => StoryPlayerScreen(
          stories: stories,
          initialIndex: initialIndex,
          onStoryViewed: (id) => notifier.markStoryViewed(id),
        ),
      ),
    );
  }

  void _openComments(
    BuildContext context,
    CommunityNotifier notifier,
    CommunityState state,
    String postId,
  ) {
    final cachedComments = notifier.getCommentsForPost(postId);
    if (cachedComments.isEmpty) {
      notifier.loadComments(postId);
    }

    CommentsBottomSheet.show(
      context,
      postId: postId,
      comments: cachedComments.isNotEmpty
          ? cachedComments
          : (state.postCommentsCache[postId] ?? const []),
      onAddComment: (text) => notifier.addComment(postId, text),
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
            // 1. Top Glass Header
            _buildTopHeader(context, ref, communityNotifier),

            // 2. Novosibirsk 10 Districts Horizontal Filter Bar
            _buildDistrictsFilter(communityState, communityNotifier),

            const SizedBox(height: 8),

            // 3. Category Filter Pills
            _buildCategoriesFilter(communityState, communityNotifier),

            const SizedBox(height: 8),

            // 4. Stories Rail
            _buildStoriesRail(context, communityState, communityNotifier),

            // 5. Main Post Feed Stream
            Expanded(
              child: RefreshIndicator(
                key: const ValueKey('feed_refresh_indicator'),
                color: AppColors.accentBlue,
                backgroundColor: AppColors.obsidianCard,
                onRefresh: () => communityNotifier.loadFeed(forceRefresh: true),
                child: communityState.postsAsync.when(
                  data: (_) {
                    final filteredPosts = communityState.filteredPosts;
                    if (filteredPosts.isEmpty) {
                      return _FeedEmptyView(
                        key: const ValueKey('feed_empty_view'),
                        onResetFilters: () {
                          communityNotifier.setDistrict('Все районы');
                          communityNotifier.setCategory('all');
                        },
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        return CommunityPostCard(
                          key: ValueKey('post_${post.id}'),
                          post: post,
                          onLike: () => communityNotifier.toggleLike(post.id),
                          onBookmark: () => communityNotifier.toggleBookmark(post.id),
                          onComment: () => _openComments(
                            context,
                            communityNotifier,
                            communityState,
                            post.id,
                          ),
                          onShare: () {
                            PawToast.show(
                              context,
                              title: 'Ссылка на публикацию скопирована',
                              type: ToastType.success,
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const _FeedSkeleton(key: ValueKey('feed_skeleton')),
                  error: (error, _) => _FeedErrorView(
                    key: const ValueKey('feed_error_view'),
                    error: error,
                    onRetry: () => communityNotifier.loadFeed(forceRefresh: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    WidgetRef ref,
    CommunityNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          // Paw Logo with Vivid Emerald/Azure Gradient
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF34D399), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3334D399),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Title & Location Tag
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'PawConnect',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Лента',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Новосибирск • Сообщество',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          IconButton(
            key: const ValueKey('feed_refresh_button'),
            tooltip: 'Обновить ленту',
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.obsidianGlassSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorderSubtle),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            onPressed: () => notifier.loadFeed(forceRefresh: true),
          ),
          const SizedBox(width: 6),

          // Add Post Button
          IconButton(
            key: const ValueKey('feed_add_post_button'),
            tooltip: 'Создать запись',
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            onPressed: () => _openNewPostModal(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictsFilter(
    CommunityState state,
    CommunityNotifier notifier,
  ) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CommunityService.novosibirskDistricts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final district = CommunityService.novosibirskDistricts[index];
          final isSelected = state.selectedDistrict == district;

          return GlassCapsule(
            key: ValueKey('district_filter_$district'),
            isActive: isSelected,
            activeColor: AppColors.accentBlue,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onTap: () => notifier.setDistrict(district),
            child: Text(
              district,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesFilter(
    CommunityState state,
    CommunityNotifier notifier,
  ) {
    final categories = [
      ('all', 'Все темы', AppColors.accentBlue),
      ('sos', '🚨 SOS', AppColors.accentRed),
      ('health', '🏥 Здоровье', AppColors.accentGreen),
      ('training', '🦮 Дрессировка', AppColors.accentBlue),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (id, label, color) = categories[index];
          final isSelected = state.selectedCategory == id;

          return GlassCapsule(
            key: ValueKey('category_filter_$id'),
            isActive: isSelected,
            activeColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onTap: () => notifier.setCategory(id),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoriesRail(
    BuildContext context,
    CommunityState state,
    CommunityNotifier notifier,
  ) {
    return state.storiesAsync.when(
      data: (stories) {
        if (stories.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: CommunityStoriesBar(
            stories: stories,
            onTapStory: (story, index) {
              _openStoryPlayer(context, stories, index, notifier);
            },
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: _StoriesSkeleton(),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Shimmering skeleton placeholder cards for feed posts loading state.
class _FeedSkeleton extends StatefulWidget {
  const _FeedSkeleton({super.key});

  @override
  State<_FeedSkeleton> createState() => _FeedSkeletonState();
}

class _FeedSkeletonState extends State<_FeedSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: child,
        );
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        itemCount: 3,
        itemBuilder: (context, index) => const _FeedSkeletonCard(),
      ),
    );
  }
}

class _FeedSkeletonCard extends StatelessWidget {
  const _FeedSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.obsidianCardTranslucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 0.8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.obsidianGlassSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 70,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.obsidianGlassSurface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 180,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 220,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer placeholder circles for stories loading state.
class _StoriesSkeleton extends StatelessWidget {
  const _StoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.obsidianCardTranslucent,
                  border: Border.all(color: AppColors.glassBorder),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 48,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Zero-Stub genuine Liquid Glass error view.
class _FeedErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _FeedErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 100),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.obsidianCardTranslucent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.accentRed,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Не удалось загрузить ленту',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Проверьте подключение к сети или повторите попытку',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  key: const ValueKey('feed_retry_button'),
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Повторить попытку',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Friendly empty state with reset filters action.
class _FeedEmptyView extends StatelessWidget {
  final VoidCallback onResetFilters;

  const _FeedEmptyView({
    super.key,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 100),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.obsidianCardTranslucent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: AppColors.accentBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'В этом районе пока нет публикаций',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Попробуйте выбрать другой район или сбросить фильтры тем',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TextButton.icon(
                  key: const ValueKey('feed_reset_filters_button'),
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.accentBlue),
                  label: const Text(
                    'Сбросить фильтры',
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
