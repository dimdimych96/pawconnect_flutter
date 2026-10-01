class PetStoryModel {
  final String id;
  final String? authorId;
  final String authorName;
  final bool isOfficial;
  final String? authorAvatar;
  final String? petName;
  final String district;
  final String mediaUrl;
  final String statusText;
  final String visibility;
  final DateTime createdAt;
  final bool isViewed;

  PetStoryModel({
    required this.id,
    this.authorId,
    required this.authorName,
    this.isOfficial = false,
    this.authorAvatar,
    this.petName,
    required this.district,
    required this.mediaUrl,
    required this.statusText,
    this.visibility = 'district',
    required this.createdAt,
    this.isViewed = false,
  });

  factory PetStoryModel.fromJson(Map<String, dynamic> json) {
    return PetStoryModel(
      id: json['id'] ?? '',
      authorId: json['authorId'] ?? json['author_id']?.toString(),
      authorName: json['authorName'] ?? json['author_name'] ?? 'Аноним',
      isOfficial: json['isOfficial'] ?? json['is_official'] ?? false,
      authorAvatar: json['authorAvatar'] ?? json['author_avatar'],
      petName: json['petName'] ?? json['pet_name'],
      district: json['district'] ?? 'Центральный',
      mediaUrl: json['mediaUrl'] ?? json['media_url'] ?? '',
      statusText: json['statusText'] ?? json['status_text'] ?? '',
      visibility: json['visibility'] ?? 'district',
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      isViewed: json['isViewed'] ?? json['is_viewed'] ?? false,
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
        'mediaUrl': mediaUrl,
        'media_url': mediaUrl,
        'statusText': statusText,
        'status_text': statusText,
        'visibility': visibility,
        'createdAt': createdAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'isViewed': isViewed,
        'is_viewed': isViewed,
      };

  PetStoryModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    bool? isOfficial,
    String? authorAvatar,
    String? petName,
    String? district,
    String? mediaUrl,
    String? statusText,
    String? visibility,
    DateTime? createdAt,
    bool? isViewed,
  }) {
    return PetStoryModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isOfficial: isOfficial ?? this.isOfficial,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      petName: petName ?? this.petName,
      district: district ?? this.district,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      statusText: statusText ?? this.statusText,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
