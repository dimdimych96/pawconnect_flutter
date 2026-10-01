class CommunityPostModel {
  final String id;
  final String? authorId;
  final String authorName;
  final bool isOfficial;
  final String? authorAvatar;
  final String? petName;
  final String district; // Novosibirsk districts e.g. 'Центральный', 'Академгородок'
  final String category; // 'general', 'health', 'training', 'sos'
  final String title;
  final String content;
  final int likesCount;
  final bool isLiked;
  final int commentsCount;
  final bool isBookmarked;
  final DateTime createdAt;
  final String? imageUrl;

  CommunityPostModel({
    required this.id,
    this.authorId,
    required this.authorName,
    this.isOfficial = false,
    this.authorAvatar,
    this.petName,
    required this.district,
    required this.category,
    required this.title,
    required this.content,
    required this.likesCount,
    required this.isLiked,
    this.commentsCount = 0,
    this.isBookmarked = false,
    required this.createdAt,
    this.imageUrl,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? json['author_id']?.toString(),
      authorName: json['authorName'] ?? 'Аноним',
      isOfficial: json['isOfficial'] ?? false,
      authorAvatar: json['authorAvatar'],
      petName: json['petName'],
      district: json['district'] ?? 'Центральный',
      category: json['category'] ?? 'general',
      title: json['title'] ?? '',
      content: json['content'] ?? json['text'] ?? '',
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? 0,
      isBookmarked: json['isBookmarked'] ?? json['is_bookmarked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'] ?? json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'author_id': authorId,
        'authorName': authorName,
        'author_name': authorName,
        'isOfficial': isOfficial,
        'is_official': isOfficial,
        'authorAvatar': authorAvatar,
        'author_avatar': authorAvatar,
        'petName': petName,
        'pet_name': petName,
        'district': district,
        'category': category,
        'title': title,
        'text': content,
        'content': content,
        'likesCount': likesCount,
        'likes_count': likesCount,
        'isLiked': isLiked,
        'is_liked': isLiked,
        'commentsCount': commentsCount,
        'comments_count': commentsCount,
        'isBookmarked': isBookmarked,
        'is_bookmarked': isBookmarked,
        'createdAt': createdAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'imageUrl': imageUrl,
        'photo_url': imageUrl,
      };

  CommunityPostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    bool? isOfficial,
    String? authorAvatar,
    String? petName,
    String? district,
    String? category,
    String? title,
    String? content,
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
    bool? isBookmarked,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isOfficial: isOfficial ?? this.isOfficial,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      petName: petName ?? this.petName,
      district: district ?? this.district,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
