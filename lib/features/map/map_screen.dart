import 'dart:async';
import 'dart:ui';
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
import 'widgets/liquid_glass_bottom_sheet.dart';
import 'widgets/turn_by_turn_hud.dart';
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
  bool _isControlsVisible = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _isControlsVisible = false);
      }
    });
  }

  void _onMapInteraction() {
    if (!_isControlsVisible) {
      setState(() => _isControlsVisible = true);
    }
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
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
        padding: const EdgeInsets.only(top: 140, bottom: 260, left: 50, right: 50),
      ),
    );
  }

  void _centerOnMax(double lat, double lng, {bool isNavigating = false}) {
    setState(() => _isPetFocus = true);
    _mapController.move(LatLng(lat, lng), 16.0);
    PawToast.show(
      context,
      title: 'Камера сфокусирована на ошейнике Макса',
      subtitle: 'GPS-ошейник в центре карты',
      type: ToastType.success,
      topOffset: isNavigating ? 96.0 : null,
    );
  }

  void _centerOnUser(double lat, double lng, {bool isNavigating = false}) async {
    setState(() => _isPetFocus = false);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    final mapState = ref.read(mapNotifierProvider);
    if (!mapState.hasLocationPermission || !mapState.isLocationTrackingActive) {
      await mapNotifier.initLocationTracking();
    }
    final updatedState = ref.read(mapNotifierProvider);
    _mapController.move(LatLng(updatedState.userLatitude, updatedState.userLongitude), 16.0);
    PawToast.show(
      context,
      title: 'Камера сфокусирована на вашей геопозиции',
      subtitle: updatedState.hasLocationPermission
          ? 'Ваше местоположение в центре карты'
          : 'Разрешите доступ к GPS для точного трекинга',
      type: updatedState.hasLocationPermission ? ToastType.info : ToastType.alert,
      topOffset: isNavigating ? 96.0 : null,
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

    // Position RightControlRail safely in the upper-right area, clearing any top banners
    final double controlRailTop = isBreached
        ? 140.0
        : (mapState.isNavigating ? 150.0 : 80.0);

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
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) _onMapInteraction();
              },
              onTap: (_, __) {
                _onMapInteraction();
                if (mapState.selectedMarker != null) {
                  mapNotifier.selectMarker(null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png',
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
                      color: (mapState.selectedTransportMode == 'park_safe'
                              ? AppColors.accentGreen
                              : AppColors.accentBlue)
                          .withValues(alpha: 0.35),
                    ),
                    Polyline(
                      points: mapState.activeRoute!.waypoints,
                      strokeWidth: 5.0,
                      color: mapState.selectedTransportMode == 'park_safe'
                          ? AppColors.accentGreen
                          : AppColors.accentBlue,
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
                        _onMapInteraction();
                        _centerOnUser(mapState.userLatitude, mapState.userLongitude, isNavigating: mapState.isNavigating);
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
                        _onMapInteraction();
                        _centerOnMax(maxLat, maxLng, isNavigating: mapState.isNavigating);
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
                          _onMapInteraction();
                          mapNotifier.selectMarker(marker);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Top GPS Enable Prompt (if GPS tracking not active yet)
          if (!mapState.isLocationTrackingActive && !mapState.isNavigating && !isBreached)
            Positioned(
              top: 72,
              left: 16,
              right: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xE01A1D24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accentBlue.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_searching_rounded, color: AppColors.accentBlue, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Включить реальный GPS',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            PawToast.show(
                              context,
                              title: 'Определение геопозиции...',
                              subtitle: 'Запрос GPS и сетевых координат',
                              type: ToastType.info,
                            );
                            await mapNotifier.initLocationTracking();
                            final st = ref.read(mapNotifierProvider);
                            if (st.isLocationTrackingActive) {
                              _mapController.move(LatLng(st.userLatitude, st.userLongitude), 16.0);
                              PawToast.show(
                                context,
                                title: 'Геопозиция определена!',
                                subtitle: 'Широта: ${st.userLatitude.toStringAsFixed(4)}, Долгота: ${st.userLongitude.toStringAsFixed(4)}',
                                type: ToastType.success,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Разрешить',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 2. Right Liquid Glass Control Rail (Upper-Right placement + Smart Auto-Hide)
          Positioned(
            right: 14,
            top: controlRailTop,
            child: AnimatedOpacity(
              opacity: _isControlsVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !_isControlsVisible,
                child: RightControlRail(
                  petName: gpsDevice?.petName ?? 'Макс',
                  distanceMeters: mapState.distanceToPetInMeters,
                  isBreached: isBreached,
                  isPetFocus: _isPetFocus,
                  activeFilters: mapState.activeFilters,
                  onToggleFilter: (category) {
                    _onMapInteraction();
                    mapNotifier.toggleFilter(category);
                  },
                  onPetFocus: () {
                    _onMapInteraction();
                    _centerOnMax(maxLat, maxLng, isNavigating: mapState.isNavigating);
                  },
                  onUserFocus: () {
                    _onMapInteraction();
                    _centerOnUser(mapState.userLatitude, mapState.userLongitude, isNavigating: mapState.isNavigating);
                  },
                  onAddEvent: () {
                    _onMapInteraction();
                    _openNewMarkerModal(maxLat, maxLng);
                  },
                  onBuildRoute: () async {
                    _onMapInteraction();
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
            ),
          ),

          // 3. Sliding Marker Detail Sheet (if marker selected and no active route)
          if (mapState.selectedMarker != null && mapState.activeRoute == null)
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

          // 4. Liquid Glass Bottom Sheet (Route Preview mode)
          if (mapState.activeRoute != null && !mapState.isNavigating)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LiquidGlassBottomSheet(
                route: mapState.activeRoute!,
                activeMode: mapState.selectedTransportMode,
                onModeSelected: (mode) {
                  _onMapInteraction();
                  mapNotifier.setTransportMode(mode);
                },
                onStartNavigation: () {
                  _onMapInteraction();
                  mapNotifier.startNavigation();
                  PawToast.show(
                    context,
                    title: 'Навигация запущена',
                    subtitle: 'Следуйте по указаниям на экране',
                    type: ToastType.success,
                    topOffset: 96.0,
                  );
                },
                onClose: () {
                  _onMapInteraction();
                  mapNotifier.clearRoute();
                },
              ),
            ),

          // 5. Active Turn-by-Turn Navigation HUD (When navigating)
          if (mapState.activeRoute != null && mapState.isNavigating)
            TurnByTurnHud(
              route: mapState.activeRoute!,
              currentStepIndex: mapState.currentStepIndex,
              onNextStep: () {
                _onMapInteraction();
                mapNotifier.nextStep();
              },
              onPrevStep: () {
                _onMapInteraction();
                mapNotifier.prevStep();
              },
              onEndNavigation: () {
                _onMapInteraction();
                mapNotifier.endNavigation();
                PawToast.show(
                  context,
                  title: 'Навигация завершена',
                  subtitle: 'Вы вернулись в режим обзора карты',
                  type: ToastType.info,
                );
              },
            ),
        ],
      ),
    );
  }
}
