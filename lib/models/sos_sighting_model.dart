class SosSightingModel {
  final String id;
  final String postId;
  final String? authorId;
  final String authorName;
  final String? authorAvatar;
  final double latitude;
  final double longitude;
  final String? note;
  final String? timeAgoStr;
  final String? photoUrl;
  final DateTime createdAt;

  SosSightingModel({
    required this.id,
    required this.postId,
    this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.latitude,
    required this.longitude,
    this.note,
    this.timeAgoStr,
    this.photoUrl,
    required this.createdAt,
  });

  factory SosSightingModel.fromJson(Map<String, dynamic> json) {
    return SosSightingModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? json['post_id'] ?? '',
      authorId: json['authorId'] ?? json['author_id']?.toString(),
      authorName: json['authorName'] ?? json['author_name'] ?? 'Анонимный свидетель',
      authorAvatar: json['authorAvatar'] ?? json['author_avatar'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
      timeAgoStr: json['timeAgoStr'] ?? json['time_ago_str'] ?? 'Недавно',
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'post_id': postId,
        'authorId': authorId,
        'author_id': authorId,
        'authorName': authorName,
        'author_name': authorName,
        'authorAvatar': authorAvatar,
        'author_avatar': authorAvatar,
        'latitude': latitude,
        'longitude': longitude,
        'note': note,
        'timeAgoStr': timeAgoStr,
        'time_ago_str': timeAgoStr,
        'photoUrl': photoUrl,
        'photo_url': photoUrl,
        'createdAt': createdAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  SosSightingModel copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    double? latitude,
    double? longitude,
    String? note,
    String? timeAgoStr,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return SosSightingModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      note: note ?? this.note,
      timeAgoStr: timeAgoStr ?? this.timeAgoStr,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
