class CommunityPostModel {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String district; // Novosibirsk districts e.g. 'Центральный', 'Академгородок'
  final String category; // 'general', 'health', 'training', 'sos'
  final String title;
  final String content;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final String? imageUrl;

  CommunityPostModel({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.district,
    required this.category,
    required this.title,
    required this.content,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    this.imageUrl,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] ?? '',
      authorName: json['authorName'] ?? 'Аноним',
      authorAvatar: json['authorAvatar'],
      district: json['district'] ?? 'Центральный',
      category: json['category'] ?? 'general',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'district': district,
        'category': category,
        'title': title,
        'content': content,
        'likesCount': likesCount,
        'isLiked': isLiked,
        'createdAt': createdAt.toIso8601String(),
        'imageUrl': imageUrl,
      };

  CommunityPostModel copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? district,
    String? category,
    String? title,
    String? content,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      district: district ?? this.district,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
