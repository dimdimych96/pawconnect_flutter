class CommunityPostModel {
  final String id;
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
      authorName: json['authorName'] ?? 'Аноним',
      isOfficial: json['isOfficial'] ?? false,
      authorAvatar: json['authorAvatar'],
      petName: json['petName'],
      district: json['district'] ?? 'Центральный',
      category: json['category'] ?? 'general',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      commentsCount: json['commentsCount'] ?? 0,
      isBookmarked: json['isBookmarked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'isOfficial': isOfficial,
        'authorAvatar': authorAvatar,
        'petName': petName,
        'district': district,
        'category': category,
        'title': title,
        'content': content,
        'likesCount': likesCount,
        'isLiked': isLiked,
        'commentsCount': commentsCount,
        'isBookmarked': isBookmarked,
        'createdAt': createdAt.toIso8601String(),
        'imageUrl': imageUrl,
      };

  CommunityPostModel copyWith({
    String? id,
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
