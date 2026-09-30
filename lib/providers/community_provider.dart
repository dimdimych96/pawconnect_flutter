import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_post_model.dart';
import '../models/pet_story_model.dart';
import '../models/post_comment_model.dart';
import '../services/community_service.dart';

class CommunityState {
  final AsyncValue<List<CommunityPostModel>> postsAsync;
  final AsyncValue<List<PetStoryModel>> storiesAsync;
  final String selectedDistrict;
  final String selectedCategory; // 'all', 'health', 'training', 'sos', 'general'
  final Map<String, List<PostCommentModel>> postCommentsCache;
  final Set<String> bookmarkedPostIds;

  const CommunityState({
    this.postsAsync = const AsyncValue.loading(),
    this.storiesAsync = const AsyncValue.loading(),
    this.selectedDistrict = 'Все районы',
    this.selectedCategory = 'all',
    this.postCommentsCache = const {},
    this.bookmarkedPostIds = const {},
  });

  CommunityState copyWith({
    AsyncValue<List<CommunityPostModel>>? postsAsync,
    AsyncValue<List<PetStoryModel>>? storiesAsync,
    String? selectedDistrict,
    String? selectedCategory,
    Map<String, List<PostCommentModel>>? postCommentsCache,
    Set<String>? bookmarkedPostIds,
  }) {
    return CommunityState(
      postsAsync: postsAsync ?? this.postsAsync,
      storiesAsync: storiesAsync ?? this.storiesAsync,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      postCommentsCache: postCommentsCache ?? this.postCommentsCache,
      bookmarkedPostIds: bookmarkedPostIds ?? this.bookmarkedPostIds,
    );
  }

  // Compatibility helpers
  List<CommunityPostModel> get posts => postsAsync.valueOrNull ?? const [];
  List<PetStoryModel> get stories => storiesAsync.valueOrNull ?? const [];
  bool get isLoading => postsAsync.isLoading || storiesAsync.isLoading;

  List<CommunityPostModel> get filteredPosts {
    return posts.where((p) {
      final matchesDistrict = selectedDistrict == 'Все районы' || p.district == selectedDistrict;
      final matchesCategory = selectedCategory == 'all' || p.category == selectedCategory;
      return matchesDistrict && matchesCategory;
    }).toList();
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final CommunityService _communityService;

  CommunityNotifier(this._communityService) : super(const CommunityState()) {
    loadFeed();
  }

  /// Loads feed posts and stories in parallel.
  Future<void> loadFeed({bool forceRefresh = false}) async {
    if (forceRefresh || state.postsAsync is! AsyncData) {
      state = state.copyWith(
        postsAsync: const AsyncValue.loading(),
        storiesAsync: const AsyncValue.loading(),
      );
    }

    try {
      final results = await Future.wait([
        _communityService.getPosts(),
        _communityService.getStories(),
      ]);

      final posts = results[0] as List<CommunityPostModel>;
      final stories = results[1] as List<PetStoryModel>;

      // Maintain bookmark status across refreshes
      final synchedPosts = posts.map((p) {
        if (state.bookmarkedPostIds.contains(p.id)) {
          return p.copyWith(isBookmarked: true);
        }
        return p;
      }).toList();

      state = state.copyWith(
        postsAsync: AsyncValue.data(synchedPosts),
        storiesAsync: AsyncValue.data(stories),
      );
    } catch (e, st) {
      state = state.copyWith(
        postsAsync: AsyncValue.error(e, st),
        storiesAsync: AsyncValue.error(e, st),
      );
    }
  }

  Future<void> loadPosts() => loadFeed();

  void setDistrict(String district) {
    state = state.copyWith(selectedDistrict: district);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Optimistically updates post like state, then calls the backend API.
  /// If the API call throws, rolls back the optimistic update to preserve backend sync.
  Future<void> toggleLike(String postId) async {
    final currentPosts = state.posts;
    if (currentPosts.isEmpty) return;

    final updatedPosts = currentPosts.map((p) {
      if (p.id == postId) {
        final newIsLiked = !p.isLiked;
        final newCount = newIsLiked ? p.likesCount + 1 : (p.likesCount > 0 ? p.likesCount - 1 : 0);
        return p.copyWith(isLiked: newIsLiked, likesCount: newCount);
      }
      return p;
    }).toList();

    state = state.copyWith(postsAsync: AsyncValue.data(updatedPosts));

    try {
      await _communityService.toggleLike(postId);
    } catch (_) {
      // Rollback to original pre-toggle state on server error
      final rolledBackPosts = state.posts.map((p) {
        if (p.id == postId) {
          return currentPosts.firstWhere((cp) => cp.id == postId, orElse: () => p);
        }
        return p;
      }).toList();
      state = state.copyWith(postsAsync: AsyncValue.data(rolledBackPosts));
    }
  }

  /// Toggles post bookmark state and tracks in bookmarkedPostIds.
  void toggleBookmark(String postId) {
    final updatedBookmarks = Set<String>.from(state.bookmarkedPostIds);
    final isBookmarking = !updatedBookmarks.contains(postId);
    if (isBookmarking) {
      updatedBookmarks.add(postId);
    } else {
      updatedBookmarks.remove(postId);
    }

    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        return p.copyWith(isBookmarked: isBookmarking);
      }
      return p;
    }).toList();

    state = state.copyWith(
      bookmarkedPostIds: updatedBookmarks,
      postsAsync: AsyncValue.data(updatedPosts),
    );
  }

  /// Loads comments for a specific post into the local cache.
  Future<void> loadComments(String postId) async {
    final comments = await _communityService.getComments(postId);
    final updatedCache = Map<String, List<PostCommentModel>>.from(state.postCommentsCache);
    updatedCache[postId] = comments;
    state = state.copyWith(postCommentsCache: updatedCache);
  }

  /// Returns cached comments for a post, or an empty list if not yet loaded.
  List<PostCommentModel> getCommentsForPost(String postId) {
    return state.postCommentsCache[postId] ?? const [];
  }

  /// Adds a new comment: prepends to the comments cache and increments commentsCount on the post.
  Future<void> addComment(String postId, String text) async {
    final newComment = await _communityService.addComment(postId, text);

    final currentComments = state.postCommentsCache[postId] ?? const [];
    final updatedComments = [newComment, ...currentComments];
    final updatedCache = Map<String, List<PostCommentModel>>.from(state.postCommentsCache);
    updatedCache[postId] = updatedComments;

    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        return p.copyWith(commentsCount: p.commentsCount + 1);
      }
      return p;
    }).toList();

    state = state.copyWith(
      postCommentsCache: updatedCache,
      postsAsync: AsyncValue.data(updatedPosts),
    );
  }

  /// Marks a story as viewed in storiesAsync.
  void markStoryViewed(String storyId) {
    final currentStories = state.stories;
    final updatedStories = currentStories.map((s) {
      if (s.id == storyId) {
        return s.copyWith(isViewed: true);
      }
      return s;
    }).toList();

    state = state.copyWith(storiesAsync: AsyncValue.data(updatedStories));
  }

  /// Adds a new post to the top of the feed and publishes it via CommunityService.
  /// Replaces the optimistic post with the server-returned instance or rolls back on error.
  Future<void> addPost(CommunityPostModel newPost) async {
    final optimisticPosts = [newPost, ...state.posts];
    state = state.copyWith(postsAsync: AsyncValue.data(optimisticPosts));

    try {
      final confirmedPost = await _communityService.createPost(newPost);
      final confirmedPosts = state.posts.map((p) => p.id == newPost.id ? confirmedPost : p).toList();
      state = state.copyWith(postsAsync: AsyncValue.data(confirmedPosts));
    } catch (e) {
      // Roll back optimistic post from feed on failure
      final revertedPosts = state.posts.where((p) => p.id != newPost.id).toList();
      state = state.copyWith(postsAsync: AsyncValue.data(revertedPosts));
      rethrow;
    }
  }

  Future<void> createPost(CommunityPostModel newPost) => addPost(newPost);
}

final communityServiceProvider = Provider<CommunityService>((ref) => CommunityService());

final communityNotifierProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  final service = ref.watch(communityServiceProvider);
  return CommunityNotifier(service);
});
