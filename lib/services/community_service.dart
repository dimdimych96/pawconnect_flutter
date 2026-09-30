import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../models/community_post_model.dart';
import '../models/pet_story_model.dart';
import '../models/post_comment_model.dart';

class CommunityService {
  final Dio _dio;
  final bool _allowMockFallback;

  CommunityService({Dio? dio, bool? allowMockFallback})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 3),
              ),
            ),
        _allowMockFallback = allowMockFallback ?? AppConfig.enableOfflineMocks;

  static const List<String> novosibirskDistricts = [
    'Все районы',
    'Центральный',
    'Заельцовский',
    'Дзержинский',
    'Железнодорожный',
    'Калининский',
    'Кировский',
    'Ленинский',
    'Октябрьский',
    'Первомайский',
    'Советский (Академгородок)',
  ];

  static final List<PetStoryModel> mockStories = [
    PetStoryModel(
      id: 'story-pc-official',
      authorName: 'PawConnect Team',
      isOfficial: true,
      authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      petName: null,
      district: 'Центральный',
      mediaUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&q=80',
      statusText: 'Совет кинолога: настройка безопасных геозон ошейника',
      createdAt: DateTime(2026, 9, 30, 10, 0),
      isViewed: false,
    ),
    PetStoryModel(
      id: 'story-pet-1',
      authorName: 'Анна С.',
      isOfficial: false,
      authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      petName: 'Рекс (Хаски)',
      district: 'Заельцовский',
      mediaUrl: 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=800&q=80',
      statusText: 'Гуляет 25 мин в Нарымском сквере',
      createdAt: DateTime(2026, 9, 30, 10, 15),
      isViewed: false,
    ),
    PetStoryModel(
      id: 'story-pet-2',
      authorName: 'Михаил Д.',
      isOfficial: false,
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      petName: 'Луна (Корги)',
      district: 'Советский (Академгородок)',
      mediaUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=800&q=80',
      statusText: 'Тренировка на дог-площадке НГУ',
      createdAt: DateTime(2026, 9, 30, 10, 30),
      isViewed: false,
    ),
    PetStoryModel(
      id: 'story-pet-3',
      authorName: 'Екатерина В.',
      isOfficial: false,
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      petName: 'Майло (Джек-рассел)',
      district: 'Первомайский',
      mediaUrl: 'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=800&q=80',
      statusText: 'Утренняя пробежка у набережной',
      createdAt: DateTime(2026, 9, 30, 10, 45),
      isViewed: false,
    ),
  ];

  static final List<CommunityPostModel> mockPosts = [
    CommunityPostModel(
      id: 'post-official-1',
      authorName: 'PawConnect Team',
      isOfficial: true,
      authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      petName: 'Барс (Самоед)',
      district: 'Центральный',
      category: 'training',
      title: 'Умный выгул: Настройка безопасных геозон ошейника',
      content: 'Команда PawConnect подготовила подробный гид по настройке GPS-ошейника и безопасных зон выгула в Новосибирске. Задайте радиус безопасной зоны от 50 до 500 метров в карточке питомца. При выходе за границу вы мгновенно получите пуш-уведомление и сигнал тревоги!',
      likesCount: 42,
      isLiked: true,
      commentsCount: 2,
      isBookmarked: false,
      createdAt: DateTime(2026, 9, 30, 10, 0),
      imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&q=80',
    ),
    CommunityPostModel(
      id: 'post-1',
      authorName: 'Елена В.',
      authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      petName: 'Джеки (Бигль)',
      district: 'Заельцовский',
      category: 'sos',
      title: '🚨 СРОЧНО! Потерялся бигль возле Нарымского сквера',
      content: 'Убежал в сторону улицы 1905 года! Отзывается на кличку "Джеки". Синий ошейник с адресником. Просьба придержать!',
      likesCount: 24,
      isLiked: false,
      commentsCount: 1,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      imageUrl: 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=400&q=80',
    ),
    CommunityPostModel(
      id: 'post-2',
      authorName: 'Михаил Д.',
      authorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      district: 'Центральный',
      category: 'training',
      title: '🦮 Совместные занятия по ноузуорку в Центральном парке',
      content: 'Каждую субботу в 11:00 собираемся у дальнего входа. Уровень любой — от щенков до опытных собак! Бесплатно.',
      likesCount: 18,
      isLiked: true,
      commentsCount: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=400&q=80',
    ),
    CommunityPostModel(
      id: 'post-3',
      authorName: 'Ольга К.',
      authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      district: 'Советский (Академгородок)',
      category: 'health',
      title: '🏥 Отзыв: Ветеринар дерматолог в Академгородке',
      content: 'Хочу порекомендовать доктора Петрову — вылечила аллергию у нашего лабрадора за 2 недели без гормонов! Задавайте вопросы в комментариях.',
      likesCount: 31,
      isLiked: false,
      commentsCount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    CommunityPostModel(
      id: 'post-4',
      authorName: 'Артём С.',
      authorAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      district: 'Первомайский',
      category: 'general',
      title: 'Новая огороженная площадка на Первомайке!',
      content: 'Завершили благоустройство площадки у парка Первомайский. Поставили снаряды для аджилити, скамейки для владельцев и урны.',
      likesCount: 42,
      isLiked: true,
      commentsCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'https://images.unsplash.com/photo-1534361960057-19889db98d18?auto=format&fit=crop&w=400&q=80',
    ),
    CommunityPostModel(
      id: 'post-5',
      authorName: 'Ирина П.',
      authorAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
      petName: 'Грей (Хаски)',
      district: 'Ленинский',
      category: 'training',
      title: 'Ищем щенков для социализации на Монументе Славы',
      content: 'Нашему щенку хаски 4 месяца, ищем дружелюбных щенков аналогичного возраста для спокойных совместных прогулок.',
      likesCount: 12,
      isLiked: false,
      commentsCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final Map<String, List<PostCommentModel>> mockComments = {
    'post-official-1': [
      PostCommentModel(
        id: 'comment-1',
        postId: 'post-official-1',
        authorName: 'PawConnect Team',
        authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
        isOfficial: true,
        text: 'Если у вас возникнут вопросы по калибровке GPS в условиях плотной застройки — задавайте в комментариях, наши кинологи ответят!',
        createdAt: DateTime(2026, 9, 30, 10, 5),
        likesCount: 5,
        isLiked: true,
      ),
      PostCommentModel(
        id: 'comment-2',
        postId: 'post-official-1',
        authorName: 'Мария К.',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        isOfficial: false,
        text: 'Спасибо за совет! В Нарымском сквере настроила 150 метров — работает идеально.',
        createdAt: DateTime(2026, 9, 30, 10, 20),
        likesCount: 2,
        isLiked: false,
      ),
    ],
  };

  /// Fetches posts with optional district and category filtering.
  Future<List<CommunityPostModel>> getPosts({String? district, String? category}) async {
    try {
      final response = await _dio.get('/community/posts', queryParameters: {
        if (district != null && district != 'Все районы') 'district': district,
        if (category != null && category != 'all') 'category': category,
      }).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => CommunityPostModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }

    return mockPosts.where((p) {
      final matchesDistrict = district == null || district == 'Все районы' || p.district == district;
      final matchesCategory = category == null || category == 'all' || p.category == category;
      return matchesDistrict && matchesCategory;
    }).toList();
  }

  /// Creates a new community post.
  Future<CommunityPostModel> createPost(CommunityPostModel post) async {
    try {
      final response = await _dio.post('/community/posts', data: post.toJson()).timeout(const Duration(seconds: 5));
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return CommunityPostModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return post;
  }

  /// Fetches active pet stories for the Stories rail.
  Future<List<PetStoryModel>> getStories() async {
    try {
      final response = await _dio.get('/community/stories').timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => PetStoryModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return mockStories;
  }

  /// Fetches comments for a specific post.
  Future<List<PostCommentModel>> getComments(String postId) async {
    try {
      final response = await _dio.get('/community/posts/$postId/comments').timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => PostCommentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return mockComments[postId] ?? [];
  }

  /// Submits a new comment to a post.
  Future<PostCommentModel> addComment(String postId, String text) async {
    try {
      final response = await _dio.post(
        '/community/posts/$postId/comments',
        data: {'text': text},
      ).timeout(const Duration(seconds: 5));
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return PostCommentModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return PostCommentModel(
      id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorName: 'Вы',
      text: text,
      createdAt: DateTime.now(),
    );
  }

  /// Toggles like on a post.
  Future<CommunityPostModel> toggleLike(String postId) async {
    try {
      final response = await _dio.post('/community/posts/$postId/like').timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 && response.data != null) {
        return CommunityPostModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    final post = mockPosts.firstWhere((p) => p.id == postId, orElse: () => mockPosts.first);
    final newIsLiked = !post.isLiked;
    final newLikes = newIsLiked ? post.likesCount + 1 : (post.likesCount > 0 ? post.likesCount - 1 : 0);
    return post.copyWith(isLiked: newIsLiked, likesCount: newLikes);
  }
}
