import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../models/community_post_model.dart';

class CommunityService {
  final Dio _dio;

  CommunityService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 3),
              ),
            );

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

  static final List<CommunityPostModel> mockPosts = [
    CommunityPostModel(
      id: 'post-1',
      authorName: 'Елена В.',
      authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      district: 'Заельцовский',
      category: 'sos',
      title: '🚨 СРОЧНО! Потерялся бигль возле Нарымского сквера',
      content: 'Убежал в сторону улицы 1905 года! Отзывается на кличку "Джеки". Синий ошейник с адресником. Просьба придержать!',
      likesCount: 24,
      isLiked: false,
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
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'https://images.unsplash.com/photo-1534361960057-19889db98d18?auto=format&fit=crop&w=400&q=80',
    ),
    CommunityPostModel(
      id: 'post-5',
      authorName: 'Ирина П.',
      authorAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
      district: 'Ленинский',
      category: 'training',
      title: 'Ищем щенков для социализации на Монументе Славы',
      content: 'Нашему щенку хаски 4 месяца, ищем дружелюбных щенков аналогичного возраста для спокойных совместных прогулок.',
      likesCount: 12,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Future<List<CommunityPostModel>> getPosts({String? district, String? category}) async {
    try {
      final response = await _dio.get('/posts', queryParameters: {
        if (district != null && district != 'Все районы') 'district': district,
        if (category != null && category != 'all') 'category': category,
      });
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => CommunityPostModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return mockPosts;
  }

  Future<CommunityPostModel> createPost(CommunityPostModel post) async {
    try {
      final response = await _dio.post('/posts', data: post.toJson());
      if (response.statusCode == 200 && response.data != null) {
        return CommunityPostModel.fromJson(response.data);
      }
    } catch (_) {}
    return post;
  }
}
