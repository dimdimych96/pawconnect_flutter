class MapMarkerModel {
  final String id;
  final String type; // 'lost_pet', 'playground', 'companion'
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final String? breed;
  final String? age;
  final String? image;
  final String? address;
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
    required this.createdAt,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'lost_pet',
      title: json['title'] ?? '',
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      breed: json['breed'],
      age: json['age'],
      image: json['image'],
      address: json['address'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'breed': breed,
        'age': age,
        'image': image,
        'address': address,
        'createdAt': createdAt.toIso8601String(),
      };
}
