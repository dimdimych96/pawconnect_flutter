import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_post_model.dart';
import '../services/community_service.dart';

class CommunityState {
  final List<CommunityPostModel> posts;
  final String selectedDistrict;
  final String selectedCategory; // 'all', 'health', 'training', 'sos', 'general'
  final bool isLoading;

  const CommunityState({
    this.posts = const [],
    this.selectedDistrict = 'Все районы',
    this.selectedCategory = 'all',
    this.isLoading = false,
  });

  CommunityState copyWith({
    List<CommunityPostModel>? posts,
    String? selectedDistrict,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

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
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true);
    final posts = await _communityService.getPosts();
    state = state.copyWith(posts: posts, isLoading: false);
  }

  void setDistrict(String district) {
    state = state.copyWith(selectedDistrict: district);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleLike(String postId) {
    final updatedPosts = state.posts.map((p) {
      if (p.id == postId) {
        final newIsLiked = !p.isLiked;
        final newCount = newIsLiked ? p.likesCount + 1 : p.likesCount - 1;
        return p.copyWith(isLiked: newIsLiked, likesCount: newCount);
      }
      return p;
    }).toList();

    state = state.copyWith(posts: updatedPosts);
  }

  void addPost(CommunityPostModel newPost) async {
    state = state.copyWith(posts: [newPost, ...state.posts]);
    await _communityService.createPost(newPost);
  }
}

final communityServiceProvider = Provider<CommunityService>((ref) => CommunityService());

final communityNotifierProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  final service = ref.watch(communityServiceProvider);
  return CommunityNotifier(service);
});
