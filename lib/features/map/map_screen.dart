import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../providers/map_provider.dart';
import 'widgets/collar_marker_widget.dart';
import 'widgets/category_marker_widget.dart';
import 'widgets/marker_detail_sheet.dart';
import 'widgets/new_marker_modal.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

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

  void _centerOnMax(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 16.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Камера сфокусирована на ошейнике Макса 🐾'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _resetNorth() {
    _mapController.rotate(0.0);
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
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    final gpsDevice = mapState.gpsDevice;

    final maxLat = gpsDevice?.latitude ?? 55.0302;
    final maxLng = gpsDevice?.longitude ?? 82.9204;
    final safeZoneRadius = gpsDevice?.safeZoneRadius ?? 350.0;
    final isBreached = gpsDevice?.isBreached ?? false;

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
                if (mapState.isSearchExpanded) {
                  mapNotifier.toggleSearchExpanded(false);
                }
              },
            ),
            children: [
              // CartoDB Dark Matter Tiles
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
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

              // Markers Layer
              MarkerLayer(
                markers: [
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

          // 2. Top Header: Collapsible Apple Maps Search Bar & Category Filter Capsules
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collapsible Search Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    width: mapState.isSearchExpanded
                        ? MediaQuery.of(context).size.width - 32
                        : 56.0,
                    height: 56.0,
                    child: GlassContainer(
                      borderRadius: 14,
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          if (!mapState.isSearchExpanded) {
                            mapNotifier.toggleSearchExpanded(true);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.accentGreen,
                              size: 24,
                            ),
                            if (mapState.isSearchExpanded) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  cursorColor: AppColors.accentGreen,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: AppColors.textPrimary,
                                  ),
                                  onChanged: (val) {
                                    mapNotifier.setSearchQuery(val);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Поиск площадок, потеряшек...',
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  mapNotifier.toggleSearchExpanded(false);
                                },
                              ),
                              const SizedBox(width: 4),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Category Filter Capsules Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterCapsule(
                          label: 'Все',
                          isActive: mapState.activeFilter == 'all',
                          activeColor: AppColors.accentGreen,
                          onTap: () => mapNotifier.setFilter('all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterCapsule(
                          label: '🚨 Потеряшки',
                          isActive: mapState.activeFilter == 'lost_pet',
                          activeColor: AppColors.accentRed,
                          onTap: () => mapNotifier.setFilter('lost_pet'),
                        ),
                        const SizedBox(width: 8),
                        _FilterCapsule(
                          label: '🦮 Площадки',
                          isActive: mapState.activeFilter == 'playground',
                          activeColor: AppColors.accentGreen,
                          onTap: () => mapNotifier.setFilter('playground'),
                        ),
                        const SizedBox(width: 8),
                        _FilterCapsule(
                          label: '🐾 Компаньоны',
                          isActive: mapState.activeFilter == 'companion',
                          activeColor: AppColors.accentBlue,
                          onTap: () => mapNotifier.setFilter('companion'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Action Buttons (Right / Bottom controls)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compass reset button
                GlassContainer(
                  width: 46,
                  height: 46,
                  padding: EdgeInsets.zero,
                  borderRadius: 14,
                  onTap: _resetNorth,
                  child: const Center(
                    child: Icon(Icons.explore_outlined, color: AppColors.textPrimary, size: 24),
                  ),
                ),
                const SizedBox(height: 10),

                // Zoom Capsule (+ / -)
                GlassContainer(
                  width: 46,
                  padding: EdgeInsets.zero,
                  borderRadius: 14,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 22),
                        onPressed: _zoomIn,
                        constraints: const BoxConstraints(minWidth: 46, minHeight: 44),
                      ),
                      const Divider(height: 1, color: AppColors.glassBorderSubtle),
                      IconButton(
                        icon: const Icon(Icons.remove, color: AppColors.textPrimary, size: 22),
                        onPressed: _zoomOut,
                        constraints: const BoxConstraints(minWidth: 46, minHeight: 44),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // FAB + to add new marker
                FloatingActionButton(
                  heroTag: 'add_marker_fab',
                  backgroundColor: AppColors.accentGreen,
                  elevation: 6,
                  onPressed: () => _openNewMarkerModal(maxLat, maxLng),
                  child: const Icon(Icons.add, color: Colors.black, size: 28),
                ),
              ],
            ),
          ),

          // 4. Centering Button «Где Макс?» (Bottom Left Floating Pill)
          Positioned(
            left: 16,
            bottom: 100,
            child: GlassCapsule(
              isActive: true,
              activeColor: isBreached ? AppColors.accentRed : AppColors.accentGreen,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: () => _centerOnMax(maxLat, maxLng),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location_rounded,
                    color: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Где ${gpsDevice?.petName ?? "Макс"}?',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Sliding Marker Detail Sheet (if marker selected)
          if (mapState.selectedMarker != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              top: 0,
              child: MarkerDetailSheet(
                marker: mapState.selectedMarker!,
                onClose: () => mapNotifier.selectMarker(null),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterCapsule extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterCapsule({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCapsule(
      isActive: isActive,
      activeColor: activeColor,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
