class MapMarkerModel {
  final String id;
  final String type; // 'lost_pet', 'playground', 'companion', 'danger'
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final String? breed;
  final String? age;
  final String? image;
  final String? address;
  final String? dangerType; // 'poison', 'aggressive_pack', 'broken_glass', 'hazard_other'
  final int confirmationsCount;
  final int clearedCount;
  final DateTime? expiresAt;
  final DateTime createdAt;

  MapMarkerModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.breed,
    this.age,
    this.image,
    this.address,
    this.dangerType,
    this.confirmationsCount = 1,
    this.clearedCount = 0,
    this.expiresAt,
    required this.createdAt,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      id: json['id'] ?? '',
      type: json['type'] ?? json['category'] ?? 'lost_pet',
      title: json['title'] ?? '',
      description: json['description'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      breed: json['breed'],
      age: json['age'],
      image: json['image'] ?? json['photo_url'] ?? json['photoUrl'],
      address: json['address'],
      dangerType: json['dangerType'] ?? json['danger_type'],
      confirmationsCount: json['confirmationsCount'] ?? json['confirmations_count'] ?? 1,
      clearedCount: json['clearedCount'] ?? json['cleared_count'] ?? 0,
      expiresAt: DateTime.tryParse(json['expiresAt'] ?? json['expires_at'] ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'category': type,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'breed': breed,
        'age': age,
        'image': image,
        'photo_url': image,
        'address': address,
        'dangerType': dangerType,
        'danger_type': dangerType,
        'confirmationsCount': confirmationsCount,
        'confirmations_count': confirmationsCount,
        'clearedCount': clearedCount,
        'cleared_count': clearedCount,
        'expiresAt': expiresAt?.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  MapMarkerModel copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? breed,
    String? age,
    String? image,
    String? address,
    String? dangerType,
    int? confirmationsCount,
    int? clearedCount,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return MapMarkerModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      image: image ?? this.image,
      address: address ?? this.address,
      dangerType: dangerType ?? this.dangerType,
      confirmationsCount: confirmationsCount ?? this.confirmationsCount,
      clearedCount: clearedCount ?? this.clearedCount,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
