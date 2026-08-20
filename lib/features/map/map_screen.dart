import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/pill_toast.dart';
import '../../providers/map_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/collar_marker_widget.dart';
import 'widgets/category_marker_widget.dart';
import 'widgets/marker_detail_sheet.dart';
import 'widgets/new_marker_modal.dart';
import 'widgets/user_marker_widget.dart';
import 'widgets/route_banner_widget.dart';
import 'widgets/right_control_rail.dart';
import '../../models/route_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _isPetFocus = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // Mock 24h walking trail points around Central Park Novosibirsk
  final List<LatLng> _walkTrailPoints = const [
    LatLng(55.0302, 82.9204),
    LatLng(55.0310, 82.9220),
    LatLng(55.0325, 82.9215),
    LatLng(55.0330, 82.9180),
    LatLng(55.0315, 82.9150),
    LatLng(55.0295, 82.9170),
    LatLng(55.0302, 82.9204),
  ];
  void _fitRouteBounds(ActiveRouteModel route) {
    final bounds = LatLngBounds.fromPoints(route.waypoints);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.only(top: 140, bottom: 120, left: 50, right: 50),
      ),
    );
  }

  void _centerOnMax(double lat, double lng) {
    setState(() => _isPetFocus = true);
    _mapController.move(LatLng(lat, lng), 16.0);
    PawToast.show(
      context,
      title: 'Камера сфокусирована на ошейнике Макса',
      subtitle: 'GPS-ошейник в центре карты',
      type: ToastType.success,
    );
  }

  void _centerOnUser(double lat, double lng) {
    setState(() => _isPetFocus = false);
    _mapController.move(LatLng(lat, lng), 16.0);
    PawToast.show(
      context,
      title: 'Камера сфокусирована на вашей геопозиции',
      subtitle: 'Ваше местоположение в центре карты',
      type: ToastType.info,
    );
  }

  void _openNewMarkerModal(double lat, double lng) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewMarkerModal(
        currentLat: lat,
        currentLng: lng,
        onAdd: (newMarker) {
          ref.read(mapNotifierProvider.notifier).addMarker(newMarker);
          _mapController.move(LatLng(newMarker.latitude, newMarker.longitude), 16.0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final userState = ref.watch(userNotifierProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    final gpsDevice = mapState.gpsDevice;

    final maxLat = gpsDevice?.latitude ?? 55.0302;
    final maxLng = gpsDevice?.longitude ?? 82.9204;
    final safeZoneRadius = gpsDevice?.safeZoneRadius ?? 350.0;
    final isBreached = (gpsDevice?.isBreached ?? false) || userState.isSimulatingBreach;

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: Stack(
        children: [
          // 1. FlutterMap with CartoDB Dark Matter Tiles
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(maxLat, maxLng),
              initialZoom: 15.0,
              minZoom: 4.0,
              maxZoom: 19.0,
              onTap: (_, __) {
                if (mapState.selectedMarker != null) {
                  mapNotifier.selectMarker(null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.pawconnect.app',
                maxZoom: 19,
              ),

              if (gpsDevice != null && gpsDevice.safeZoneLatitude != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(
                        gpsDevice.safeZoneLatitude!,
                        gpsDevice.safeZoneLongitude!,
                      ),
                      radius: safeZoneRadius,
                      useRadiusInMeter: true,
                      color: isBreached
                          ? AppColors.accentRed.withValues(alpha: 0.18)
                          : AppColors.accentGreen.withValues(alpha: 0.12),
                      borderColor: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),

              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _walkTrailPoints,
                    strokeWidth: 3.5,
                    color: AppColors.accentGreen.withValues(alpha: 0.75),
                  ),
                ],
              ),

              if (mapState.activeRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: mapState.activeRoute!.waypoints,
                      strokeWidth: 9.0,
                      color: AppColors.accentBlue.withValues(alpha: 0.35),
                    ),
                    Polyline(
                      points: mapState.activeRoute!.waypoints,
                      strokeWidth: 5.0,
                      color: AppColors.accentBlue,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(mapState.userLatitude, mapState.userLongitude),
                    width: 60,
                    height: 60,
                    child: UserMarkerWidget(
                      ownerName: userState.ownerName,
                      avatarUrl: userState.ownerAvatar,
                      onTap: () {
                        _centerOnUser(mapState.userLatitude, mapState.userLongitude);
                      },
                    ),
                  ),

                  Marker(
                    point: LatLng(maxLat, maxLng),
                    width: 64,
                    height: 64,
                    child: CollarMarkerWidget(
                      petName: gpsDevice?.petName ?? 'Макс',
                      isBreached: isBreached,
                      photoUrl: gpsDevice?.photoUrl,
                      onTap: () {
                        _centerOnMax(maxLat, maxLng);
                      },
                    ),
                  ),

                  ...mapState.filteredMarkers.map((marker) {
                    return Marker(
                      point: LatLng(marker.latitude, marker.longitude),
                      width: 50,
                      height: 58,
                      child: CategoryMarkerWidget(
                        marker: marker,
                        onTap: () {
                          mapNotifier.selectMarker(marker);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Route Navigation Banner (if active)
          if (mapState.activeRoute != null)
            Positioned(
              top: isBreached ? 80.0 : 0.0,
              left: 0,
              right: 0,
              child: RouteBannerWidget(
                route: mapState.activeRoute!,
                onModeChanged: (mode) {
                  mapNotifier.setTransportMode(mode);
                },
                onClose: () {
                  mapNotifier.clearRoute();
                },
              ),
            ),

          // 3. Right Liquid Glass Control Rail (Unified Pet/User Focus, Layers Drawer & Add Event)
          Positioned(
            right: 14,
            bottom: 80,
            child: RightControlRail(
              petName: gpsDevice?.petName ?? 'Макс',
              distanceMeters: mapState.distanceToPetInMeters,
              isBreached: isBreached,
              isPetFocus: _isPetFocus,
              activeFilters: mapState.activeFilters,
              onToggleFilter: (category) {
                mapNotifier.toggleFilter(category);
              },
              onPetFocus: () => _centerOnMax(maxLat, maxLng),
              onUserFocus: () => _centerOnUser(mapState.userLatitude, mapState.userLongitude),
              onAddEvent: () => _openNewMarkerModal(maxLat, maxLng),
              onBuildRoute: () async {
                await mapNotifier.buildRouteTo(
                  LatLng(maxLat, maxLng),
                  gpsDevice?.petName ?? 'Макс',
                  type: 'collar',
                );
                final route = ref.read(mapNotifierProvider).activeRoute;
                if (route != null) {
                  _fitRouteBounds(route);
                }
              },
            ),
          ),

          // 5. Sliding Marker Detail Sheet (if marker selected)
          if (mapState.selectedMarker != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: MarkerDetailSheet(
                marker: mapState.selectedMarker!,
                onClose: () => mapNotifier.selectMarker(null),
                onBuildRoute: () async {
                  final dest = LatLng(mapState.selectedMarker!.latitude, mapState.selectedMarker!.longitude);
                  await mapNotifier.buildRouteTo(
                    dest,
                    mapState.selectedMarker!.title,
                    type: mapState.selectedMarker!.type,
                  );
                  final route = ref.read(mapNotifierProvider).activeRoute;
                  if (route != null) {
                    _fitRouteBounds(route);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
