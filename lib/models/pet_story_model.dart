class PetStoryModel {
  final String id;
  final String authorName;
  final bool isOfficial;
  final String? authorAvatar;
  final String? petName;
  final String district;
  final String mediaUrl;
  final String statusText;
  final DateTime createdAt;
  final bool isViewed;

  PetStoryModel({
    required this.id,
    required this.authorName,
    this.isOfficial = false,
    this.authorAvatar,
    this.petName,
    required this.district,
    required this.mediaUrl,
    required this.statusText,
    required this.createdAt,
    this.isViewed = false,
  });

  factory PetStoryModel.fromJson(Map<String, dynamic> json) {
    return PetStoryModel(
      id: json['id'] ?? '',
      authorName: json['authorName'] ?? 'Аноним',
      isOfficial: json['isOfficial'] ?? false,
      authorAvatar: json['authorAvatar'],
      petName: json['petName'],
      district: json['district'] ?? 'Центральный',
      mediaUrl: json['mediaUrl'] ?? '',
      statusText: json['statusText'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isViewed: json['isViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'isOfficial': isOfficial,
        'authorAvatar': authorAvatar,
        'petName': petName,
        'district': district,
        'mediaUrl': mediaUrl,
        'statusText': statusText,
        'createdAt': createdAt.toIso8601String(),
        'isViewed': isViewed,
      };

  PetStoryModel copyWith({
    String? id,
    String? authorName,
    bool? isOfficial,
    String? authorAvatar,
    String? petName,
    String? district,
    String? mediaUrl,
    String? statusText,
    DateTime? createdAt,
    bool? isViewed,
  }) {
    return PetStoryModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      isOfficial: isOfficial ?? this.isOfficial,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      petName: petName ?? this.petName,
      district: district ?? this.district,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      statusText: statusText ?? this.statusText,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
