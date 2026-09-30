class PostCommentModel {
  final String id;
  final String postId;
  final String authorName;
  final String? authorAvatar;
  final bool isOfficial;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    this.authorAvatar,
    this.isOfficial = false,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      authorName: json['authorName'] ?? 'Аноним',
      authorAvatar: json['authorAvatar'],
      isOfficial: json['isOfficial'] ?? false,
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'isOfficial': isOfficial,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'likesCount': likesCount,
        'isLiked': isLiked,
      };

  PostCommentModel copyWith({
    String? id,
    String? postId,
    String? authorName,
    String? authorAvatar,
    bool? isOfficial,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return PostCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isOfficial: isOfficial ?? this.isOfficial,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
