import 'dart:ui';
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

          // 2. Top Header: Split Search & Filters (Sleek Apple Maps style)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Collapsible Search Button / Bar (Left)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    width: mapState.isSearchExpanded
                        ? MediaQuery.of(context).size.width - 32
                        : 44.0,
                    height: 44.0,
                    child: GlassContainer(
                      borderRadius: 12,
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          if (!mapState.isSearchExpanded) {
                            mapNotifier.toggleSearchExpanded(true);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: !mapState.isSearchExpanded
                            ? const Center(
                                child: Icon(
                                  Icons.search_rounded,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.accentGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      autofocus: true,
                                      cursorColor: AppColors.accentGreen,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                      onChanged: (val) {
                                        mapNotifier.setSearchQuery(val);
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Поиск площадок, потеряшек...',
                                        hintStyle: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      mapNotifier.setSearchQuery('');
                                      mapNotifier.toggleSearchExpanded(false);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      color: Colors.transparent,
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.textSecondary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  // Filter Button (Right) — only shown when search is not expanded
                  if (!mapState.isSearchExpanded)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GlassContainer(
                          width: 44,
                          height: 44,
                          borderRadius: 12,
                          padding: EdgeInsets.zero,
                          onTap: () async {
                            mapNotifier.toggleFiltersOpen(true);
                            await _showFilterPicker(context, mapState.activeFilters, mapNotifier);
                            mapNotifier.toggleFiltersOpen(false);
                          },
                          child: const Center(
                            child: Icon(
                              Icons.tune_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        if (mapState.activeFilters.length < 3)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getFilterBadgeColor(mapState.activeFilters),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getFilterBadgeColor(mapState.activeFilters).withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
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
              bottom: 0,
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

  Color _getFilterBadgeColor(Set<String> filters) {
    if (filters.isEmpty) return AppColors.accentRed;
    final first = filters.first;
    switch (first) {
      case 'lost_pet':
        return AppColors.accentRed;
      case 'playground':
        return AppColors.accentGreen;
      case 'companion':
        return AppColors.accentBlue;
      default:
        return AppColors.accentGreen;
    }
  }

  Future<void> _showFilterPicker(BuildContext context, Set<String> currentFilters, MapNotifier mapNotifier) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final mapState = ref.watch(mapNotifierProvider);
            final filters = mapState.activeFilters;
            final notifier = ref.read(mapNotifierProvider.notifier);
            final allSelected = filters.length == 3;

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.only(top: 12, bottom: 24, left: 20, right: 20),
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top drag bar indicator
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Фильтрация карты',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FilterOptionItem(
                      label: 'Все активности',
                      isActive: allSelected,
                      activeColor: AppColors.accentGreen,
                      onTap: () {
                        notifier.toggleAllFilters(!allSelected);
                      },
                    ),
                    const Divider(color: AppColors.glassBorderSubtle, height: 1),
                    _FilterOptionItem(
                      label: '🚨 Потерянные питомцы',
                      isActive: filters.contains('lost_pet'),
                      activeColor: AppColors.accentRed,
                      onTap: () {
                        notifier.toggleFilter('lost_pet');
                      },
                    ),
                    const Divider(color: AppColors.glassBorderSubtle, height: 1),
                    _FilterOptionItem(
                      label: '🦮 Площадки для собак',
                      isActive: filters.contains('playground'),
                      activeColor: AppColors.accentGreen,
                      onTap: () {
                        notifier.toggleFilter('playground');
                      },
                    ),
                    const Divider(color: AppColors.glassBorderSubtle, height: 1),
                    _FilterOptionItem(
                      label: '🐾 Поиск компаньонов',
                      isActive: filters.contains('companion'),
                      activeColor: AppColors.accentBlue,
                      onTap: () {
                        notifier.toggleFilter('companion');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterOptionItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterOptionItem({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive ? activeColor : Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: isActive
                  ? Icon(
                      Icons.check_rounded,
                      color: activeColor,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
