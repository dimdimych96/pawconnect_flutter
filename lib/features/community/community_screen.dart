import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/pill_toast.dart';
import '../../models/auth_model.dart';
import '../../models/community_post_model.dart';
import '../../models/pet_story_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import 'widgets/comments_bottom_sheet.dart';
import 'widgets/community_post_card.dart';
import 'widgets/community_stories_bar.dart';
import 'widgets/district_picker_bottom_sheet.dart';
import 'widgets/feed_segmented_control.dart';
import 'widgets/new_post_modal.dart';
import 'widgets/new_story_modal.dart';
import 'widgets/story_player_screen.dart';

/// Tab 0 (/feed): Instagram 2026 Liquid Glass Community Feed.
///
/// Features:
/// - Clean Branding Header with PawConnect logo & create post button.
/// - Apple Liquid Glass Segmented Control (Для вас | Мой район | SOS 🚨).
/// - Natural scroll: stories scroll with posts, freeing 100% of vertical height for media.
/// - Contextual District Selector (DistrictPickerBottomSheet) within the «Мой район» stream.
/// - Dedicated SOS urgent search stream.
/// - Apple Liquid Glass performance rules (strictly ZERO BackdropFilter in scrolling post cards).
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openNewPostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewPostModal(
        onPublish: (newPost) async {
          await ref.read(communityNotifierProvider.notifier).addPost(newPost);
          if (context.mounted) {
            PawToast.show(
              context,
              title: 'Пост опубликован в сообществе',
              type: ToastType.success,
            );
          }
        },
      ),
    );
  }

  void _openEditPostModal(BuildContext context, CommunityPostModel post) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewPostModal(
        initialPost: post,
        onPublish: (updatedPost) async {
          await ref.read(communityNotifierProvider.notifier).updatePost(updatedPost);
          if (context.mounted) {
            PawToast.show(
              context,
              title: 'Публикация обновлена',
              type: ToastType.success,
            );
          }
        },
      ),
    );
  }

  Future<void> _handleDeletePost(BuildContext context, CommunityPostModel post) async {
    try {
      await ref.read(communityNotifierProvider.notifier).deletePost(post.id);
      if (context.mounted) {
        final currentUser = ref.read(authNotifierProvider).currentUser;
        final isOtherUser = !_isPostAuthor(post, currentUser);
        PawToast.show(
          context,
          title: isOtherUser ? 'Публикация удалена администратором' : 'Публикация удалена',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        PawToast.show(
          context,
          title: 'Не удалось удалить публикацию',
          type: ToastType.alert,
        );
      }
    }
  }

  void _openNewStoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewStoryModal(
        onPublish: (newStory) async {
          await ref.read(communityNotifierProvider.notifier).addStory(newStory);
          if (context.mounted) {
            PawToast.show(
              context,
              title: 'История опубликована',
              type: ToastType.success,
            );
          }
        },
      ),
    );
  }

  bool _isPostAuthor(CommunityPostModel post, UserAuthModel? currentUser) {
    if (currentUser == null) {
      return post.authorName == 'Дмитрий Борона' ||
          post.authorName == 'Владелец' ||
          post.authorName == 'PawConnect Team';
    }
    if (currentUser.canPublishAsTeam && post.isOfficial) return true;
    if (post.authorId != null && post.authorId == currentUser.id) return true;
    if (post.authorName == currentUser.name) return true;
    return false;
  }

  void _openStoryPlayer(
    BuildContext context,
    List<PetStoryModel> stories,
    int initialIndex,
    CommunityNotifier notifier, {
    UserAuthModel? currentUser,
  }) {
    final isAdmin = currentUser?.canModerate ?? false;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => StoryPlayerScreen(
          stories: stories,
          initialIndex: initialIndex,
          onStoryViewed: (id) => notifier.markStoryViewed(id),
          canDeleteStory: (story) {
            if (isAdmin) return true;
            if (story.authorId != null && story.authorId == currentUser?.id) return true;
            if (story.authorName == currentUser?.name) return true;
            return false;
          },
          onDeleteStory: (id) async {
            await notifier.deleteStory(id);
          },
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

  Future<void> _openDistrictPicker(
    BuildContext context,
    CommunityNotifier notifier,
    String currentDistrict,
  ) async {
    final selected = await DistrictPickerBottomSheet.show(
      context,
      currentDistrict: currentDistrict,
    );
    if (selected != null) {
      notifier.setDistrict(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityNotifierProvider);
    final communityNotifier = ref.read(communityNotifierProvider.notifier);

    final allPosts = communityState.postsAsync.maybeWhen(
      data: (posts) => posts,
      orElse: () => <CommunityPostModel>[],
    );

    final sosPosts = allPosts.where((p) => p.category.toLowerCase() == 'sos').toList();

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Clean Top Branding Header
            _buildTopHeader(context),

            // 2. Liquid Glass Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: FeedSegmentedControl(
                controller: _tabController,
                sosCount: sosPosts.length,
              ),
            ),

            const SizedBox(height: 6),

            // 3. Tab Streams with horizontal swipe support
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: «Для вас» (All community posts + stories)
                  _buildForYouTab(context, communityState, communityNotifier),

                  // Tab 1: «Мой район» (District filtered posts + contextual picker)
                  _buildDistrictTab(context, communityState, communityNotifier),

                  // Tab 2: «SOS 🚨» (Emergency lost & found posts)
                  _buildSosTab(context, communityState, communityNotifier, sosPosts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Header
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Branding
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34D399), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34D399).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets_rounded,
                    color: Color(0xFF0A0A0C),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PawConnect',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Create Post Button
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
            onPressed: () => _openNewPostModal(context),
          ),
        ],
      ),
    );
  }

  // MARK: - Tab 0: «Для вас»
  Widget _buildForYouTab(
    BuildContext context,
    CommunityState state,
    CommunityNotifier notifier,
  ) {
    return RefreshIndicator(
      key: const ValueKey('feed_refresh_indicator'),
      color: AppColors.accentBlue,
      backgroundColor: AppColors.obsidianCard,
      onRefresh: () => notifier.loadFeed(forceRefresh: true),
      child: state.postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return _FeedEmptyView(
              key: const ValueKey('feed_empty_view'),
              message: 'Пока нет публикаций в сообществе',
              onResetFilters: () => notifier.loadFeed(forceRefresh: true),
            );
          }

          final stories = state.storiesAsync.maybeWhen(
            data: (items) => items,
            orElse: () => <PetStoryModel>[],
          );

          final currentUser = ref.watch(authNotifierProvider).currentUser;
          final itemCount = posts.length + 1;

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CommunityStoriesBar(
                    stories: stories,
                    currentUserAvatar: currentUser?.avatarUrl,
                    onTapAddStory: () => _openNewStoryModal(context),
                    onTapStory: (story, sIndex) {
                      _openStoryPlayer(context, stories, sIndex, notifier, currentUser: currentUser);
                    },
                  ),
                );
              }

              final post = posts[index - 1];
              final isAuthor = _isPostAuthor(post, currentUser);
              final isAdmin = currentUser?.canModerate ?? false;
              final canDelete = isAuthor || isAdmin;
              final canEdit = isAuthor || (isAdmin && post.isOfficial);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommunityPostCard(
                  key: ValueKey('post_${post.id}'),
                  post: post,
                  isAuthor: isAuthor,
                  isAdmin: isAdmin,
                  onLike: () => notifier.toggleLike(post.id),
                  onBookmark: () => notifier.toggleBookmark(post.id),
                  onComment: () => _openComments(context, notifier, state, post.id),
                  onEdit: canEdit ? () => _openEditPostModal(context, post) : null,
                  onDelete: canDelete ? () => _handleDeletePost(context, post) : null,
                  onShare: () {
                    PawToast.show(
                      context,
                      title: 'Ссылка на публикацию скопирована',
                      type: ToastType.success,
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const _FeedLoadingSkeleton(),
        error: (err, _) => _FeedErrorView(
          key: const ValueKey('feed_error_view'),
          error: err,
          onRetry: () => notifier.loadFeed(forceRefresh: true),
        ),
      ),
    );
  }

  // MARK: - Tab 1: «Мой район»
  Widget _buildDistrictTab(
    BuildContext context,
    CommunityState state,
    CommunityNotifier notifier,
  ) {
    final currentDistrict = state.selectedDistrict;
    final isAllDistricts = currentDistrict == 'Все районы';

    return Column(
      children: [
        // Contextual Sticky District Selector Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.accentGreen,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAllDistricts ? 'Все районы Новосибирска' : '$currentDistrict район',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  key: const ValueKey('feed_change_district_button'),
                  onTap: () => _openDistrictPicker(context, notifier, currentDistrict),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Сменить',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGreen,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.accentGreen,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // District Filtered Feed
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accentGreen,
            backgroundColor: AppColors.obsidianCard,
            onRefresh: () => notifier.loadFeed(forceRefresh: true),
            child: state.postsAsync.when(
              data: (posts) {
                final districtPosts = posts.where((p) {
                  return isAllDistricts || p.district == currentDistrict;
                }).toList();

                if (districtPosts.isEmpty) {
                  return _FeedEmptyView(
                    key: const ValueKey('feed_district_empty_view'),
                    message: 'В районе $currentDistrict пока нет публикаций',
                    actionLabel: 'Выбрать другой район',
                    onResetFilters: () => _openDistrictPicker(context, notifier, currentDistrict),
                  );
                }

                // Filter stories by district (plus official team tips)
                final districtStories = state.storiesAsync.maybeWhen(
                  data: (items) => items.where((s) {
                    return s.isOfficial || isAllDistricts || s.district == currentDistrict;
                  }).toList(),
                  orElse: () => <PetStoryModel>[],
                );

                final currentUser = ref.watch(authNotifierProvider).currentUser;
                final itemCount = districtPosts.length + 1;

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CommunityStoriesBar(
                          stories: districtStories,
                          currentUserAvatar: currentUser?.avatarUrl,
                          onTapAddStory: () => _openNewStoryModal(context),
                          onTapStory: (story, sIndex) {
                            _openStoryPlayer(context, districtStories, sIndex, notifier, currentUser: currentUser);
                          },
                        ),
                      );
                    }

                    final post = districtPosts[index - 1];
                    final isAuthor = _isPostAuthor(post, currentUser);
                    final isAdmin = currentUser?.canModerate ?? false;
                    final canDelete = isAuthor || isAdmin;
                    final canEdit = isAuthor || (isAdmin && post.isOfficial);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CommunityPostCard(
                        key: ValueKey('post_${post.id}'),
                        post: post,
                        isAuthor: isAuthor,
                        isAdmin: isAdmin,
                        onLike: () => notifier.toggleLike(post.id),
                        onBookmark: () => notifier.toggleBookmark(post.id),
                        onComment: () => _openComments(context, notifier, state, post.id),
                        onEdit: canEdit ? () => _openEditPostModal(context, post) : null,
                        onDelete: canDelete ? () => _handleDeletePost(context, post) : null,
                        onShare: () {
                          PawToast.show(
                            context,
                            title: 'Ссылка на публикацию скопирована',
                            type: ToastType.success,
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const _FeedLoadingSkeleton(),
              error: (err, _) => _FeedErrorView(
                error: err,
                onRetry: () => notifier.loadFeed(forceRefresh: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - Tab 2: «SOS 🚨»
  Widget _buildSosTab(
    BuildContext context,
    CommunityState state,
    CommunityNotifier notifier,
    List<CommunityPostModel> sosPosts,
  ) {
    return Column(
      children: [
        // SOS Alert Header Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentRed.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Экстренные поиски и помощь',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${sosPosts.length} активных',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // SOS Posts Feed
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accentRed,
            backgroundColor: AppColors.obsidianCard,
            onRefresh: () => notifier.loadFeed(forceRefresh: true),
            child: state.postsAsync.when(
              data: (_) {
                if (sosPosts.isEmpty) {
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
                                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.accentGreen,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Все питомцы дома!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'В настоящий момент нет активных сигналов SOS в Новосибирске.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: sosPosts.length,
                  itemBuilder: (context, index) {
                    final post = sosPosts[index];
                    final currentUser = ref.watch(authNotifierProvider).currentUser;
                    final isAuthor = _isPostAuthor(post, currentUser);
                    final isAdmin = currentUser?.canModerate ?? false;
                    final canDelete = isAuthor || isAdmin;
                    final canEdit = isAuthor || (isAdmin && post.isOfficial);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CommunityPostCard(
                        key: ValueKey('post_${post.id}'),
                        post: post,
                        isAuthor: isAuthor,
                        isAdmin: isAdmin,
                        onLike: () => notifier.toggleLike(post.id),
                        onBookmark: () => notifier.toggleBookmark(post.id),
                        onComment: () => _openComments(context, notifier, state, post.id),
                        onEdit: canEdit ? () => _openEditPostModal(context, post) : null,
                        onDelete: canDelete ? () => _handleDeletePost(context, post) : null,
                        onShare: () {
                          PawToast.show(
                            context,
                            title: 'Ссылка на публикацию скопирована',
                            type: ToastType.success,
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const _FeedLoadingSkeleton(),
              error: (err, _) => _FeedErrorView(
                error: err,
                onRetry: () => notifier.loadFeed(forceRefresh: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// MARK: - Loading Skeleton
class _FeedLoadingSkeleton extends StatefulWidget {
  const _FeedLoadingSkeleton();

  @override
  State<_FeedLoadingSkeleton> createState() => _FeedLoadingSkeletonState();
}

class _FeedLoadingSkeletonState extends State<_FeedLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
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
        key: const ValueKey('feed_skeleton'),
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
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - Error View
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

// MARK: - Empty View
class _FeedEmptyView extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onResetFilters;

  const _FeedEmptyView({
    super.key,
    required this.message,
    this.actionLabel = 'Сбросить фильтры',
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
                  'Пока пусто',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  key: const ValueKey('feed_reset_filters_button'),
                  onPressed: onResetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 13,
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
