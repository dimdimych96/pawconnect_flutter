class GpsDeviceModel {
  final String imei;
  final String petName;
  final double latitude;
  final double longitude;
  final bool isBreached;
  final double? safeZoneLatitude;
  final double? safeZoneLongitude;
  final double? safeZoneRadius;
  final int batteryLevel;
  final bool isConnected;
  final String? photoUrl;

  GpsDeviceModel({
    required this.imei,
    required this.petName,
    required this.latitude,
    required this.longitude,
    required this.isBreached,
    this.safeZoneLatitude,
    this.safeZoneLongitude,
    this.safeZoneRadius,
    required this.batteryLevel,
    required this.isConnected,
    this.photoUrl,
  });

  factory GpsDeviceModel.fromJson(Map<String, dynamic> json) {
    return GpsDeviceModel(
      imei: json['imei'] ?? '',
      petName: json['petName'] ?? 'Макс',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isBreached: json['isBreached'] ?? false,
      safeZoneLatitude: json['safeZoneLatitude'] != null
          ? (json['safeZoneLatitude'] as num).toDouble()
          : null,
      safeZoneLongitude: json['safeZoneLongitude'] != null
          ? (json['safeZoneLongitude'] as num).toDouble()
          : null,
      safeZoneRadius: json['safeZoneRadius'] != null
          ? (json['safeZoneRadius'] as num).toDouble()
          : null,
      batteryLevel: json['batteryLevel'] ?? 80,
      isConnected: json['isConnected'] ?? true,
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'imei': imei,
        'petName': petName,
        'latitude': latitude,
        'longitude': longitude,
        'isBreached': isBreached,
        'safeZoneLatitude': safeZoneLatitude,
        'safeZoneLongitude': safeZoneLongitude,
        'safeZoneRadius': safeZoneRadius,
        'batteryLevel': batteryLevel,
        'isConnected': isConnected,
        'photoUrl': photoUrl,
      };

  GpsDeviceModel copyWith({
    String? imei,
    String? petName,
    double? latitude,
    double? longitude,
    bool? isBreached,
    double? safeZoneLatitude,
    double? safeZoneLongitude,
    double? safeZoneRadius,
    int? batteryLevel,
    bool? isConnected,
    String? photoUrl,
  }) {
    return GpsDeviceModel(
      imei: imei ?? this.imei,
      petName: petName ?? this.petName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isBreached: isBreached ?? this.isBreached,
      safeZoneLatitude: safeZoneLatitude ?? this.safeZoneLatitude,
      safeZoneLongitude: safeZoneLongitude ?? this.safeZoneLongitude,
      safeZoneRadius: safeZoneRadius ?? this.safeZoneRadius,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isConnected: isConnected ?? this.isConnected,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
