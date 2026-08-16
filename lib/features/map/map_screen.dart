import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/colors.dart';
import '../../providers/map_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/collar_marker_widget.dart';
import 'widgets/category_marker_widget.dart';
import 'widgets/marker_detail_sheet.dart';
import 'widgets/new_marker_modal.dart';
import 'widgets/user_marker_widget.dart';
import 'widgets/route_banner_widget.dart';
import 'widgets/right_control_rail.dart';
import 'widgets/left_header_rail.dart';
import '../../models/route_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<State<LeftHeaderRail>> _leftHeaderRailKey = GlobalKey<State<LeftHeaderRail>>();
  bool _isPetFocus = false;

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

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Камера сфокусирована на ошейнике Макса 🐾'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _centerOnUser(double lat, double lng) {
    setState(() => _isPetFocus = false);
    _mapController.move(LatLng(lat, lng), 16.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Камера сфокусирована на вашей геопозиции 📍'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.accentBlue,
      ),
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
                (_leftHeaderRailKey.currentState as dynamic)?.closeAll();
                if (mapState.selectedMarker != null) {
                  mapNotifier.selectMarker(null);
                }
                if (mapState.isSearchExpanded) {
                  mapNotifier.toggleSearchExpanded(false);
                }
              },
            ),
            children: [
              // CartoDB Dark Matter Tiles (CORS-friendly for Web & Mobile)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.pawconnect.app',
                maxZoom: 19,
              ),

              // Safe Zone Circle
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

              // 24h Walk Trail Polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _walkTrailPoints,
                    strokeWidth: 3.5,
                    color: AppColors.accentGreen.withValues(alpha: 0.75),
                  ),
                ],
              ),

              // Active Route Polyline Layer (Glowing cyan line)
              if (mapState.activeRoute != null)
                PolylineLayer(
                  polylines: [
                    // Glow underlayer
                    Polyline(
                      points: mapState.activeRoute!.waypoints,
                      strokeWidth: 9.0,
                      color: AppColors.accentBlue.withValues(alpha: 0.35),
                    ),
                    // Main route polyline
                    Polyline(
                      points: mapState.activeRoute!.waypoints,
                      strokeWidth: 5.0,
                      color: AppColors.accentBlue,
                    ),
                  ],
                ),

              // Markers Layer
              MarkerLayer(
                markers: [
                  // User Device Marker
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

                  // Collar Marker (Max)
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

                  // Category Markers (Lost pets, Playgrounds, Companions)
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

          // 2. Top Header: Search & Filters OR Active Route Navigation Banner
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
            )
          else
            Positioned(
              top: MediaQuery.of(context).padding.top + (isBreached ? 84.0 : 8.0),
              left: 14.0,
              right: 14.0,
              child: LeftHeaderRail(
                key: _leftHeaderRailKey,
                searchController: _searchController,
                onSearchChanged: (val) {
                  mapNotifier.setSearchQuery(val);
                },
                activeFilters: mapState.activeFilters,
                onToggleFilter: (category) {
                  mapNotifier.toggleFilter(category);
                },
                onClearSearch: () {
                  _searchController.clear();
                  mapNotifier.setSearchQuery('');
                },
              ),
            ),

          // 3. Right Liquid Glass Control Rail (Unified Pet/User Focus & Add Event)
          Positioned(
            right: 14,
            bottom: 80,
            child: RightControlRail(
              petName: gpsDevice?.petName ?? 'Макс',
              distanceMeters: mapState.distanceToPetInMeters,
              isBreached: isBreached,
              isPetFocus: _isPetFocus,
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
