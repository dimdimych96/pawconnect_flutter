import 'package:latlong2/latlong.dart';

enum ManeuverType {
  straight,
  turnLeft,
  turnRight,
  slightLeft,
  slightRight,
  arrive,
}

class RouteStep {
  final String instruction;
  final String streetName;
  final int distanceMeters;
  final ManeuverType maneuverType;
  final LatLng? location;

  const RouteStep({
    required this.instruction,
    this.streetName = '',
    required this.distanceMeters,
    this.maneuverType = ManeuverType.straight,
    this.location,
  });
}

class ActiveRouteModel {
  final String destinationTitle;
  final String destinationType; // 'collar', 'lost_pet', 'playground', 'companion'
  final LatLng startPoint;
  final LatLng endPoint;
  final List<LatLng> waypoints;
  final int distanceMeters;
  final int durationMinutes;
  final String transportMode; // 'walk', 'park_safe', 'drive'
  final List<RouteStep> steps;

  const ActiveRouteModel({
    required this.destinationTitle,
    required this.destinationType,
    required this.startPoint,
    required this.endPoint,
    required this.waypoints,
    required this.distanceMeters,
    required this.durationMinutes,
    this.transportMode = 'walk',
    this.steps = const [],
  });

  ActiveRouteModel copyWith({
    String? destinationTitle,
    String? destinationType,
    LatLng? startPoint,
    LatLng? endPoint,
    List<LatLng>? waypoints,
    int? distanceMeters,
    int? durationMinutes,
    String? transportMode,
    List<RouteStep>? steps,
  }) {
    return ActiveRouteModel(
      destinationTitle: destinationTitle ?? this.destinationTitle,
      destinationType: destinationType ?? this.destinationType,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      waypoints: waypoints ?? this.waypoints,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      transportMode: transportMode ?? this.transportMode,
      steps: steps ?? this.steps,
    );
  }
}
