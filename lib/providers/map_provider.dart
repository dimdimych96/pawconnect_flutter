import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/map_marker_model.dart';
import '../models/gps_device_model.dart';
import '../services/map_service.dart';

class MapState {
  final List<MapMarkerModel> markers;
  final GpsDeviceModel? gpsDevice;
  final Set<String> activeFilters; // 'lost_pet', 'playground', 'companion'
  final String searchQuery;
  final MapMarkerModel? selectedMarker;
  final bool isSearchExpanded;
  final bool isLoading;
  final bool isFiltersOpen;

  const MapState({
    this.markers = const [],
    this.gpsDevice,
    this.activeFilters = const {'lost_pet', 'playground', 'companion'},
    this.searchQuery = '',
    this.selectedMarker,
    this.isSearchExpanded = false,
    this.isLoading = false,
    this.isFiltersOpen = false,
  });

  MapState copyWith({
    List<MapMarkerModel>? markers,
    GpsDeviceModel? gpsDevice,
    Set<String>? activeFilters,
    String? searchQuery,
    MapMarkerModel? selectedMarker,
    bool clearSelectedMarker = false,
    bool? isSearchExpanded,
    bool? isLoading,
    bool? isFiltersOpen,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      gpsDevice: gpsDevice ?? this.gpsDevice,
      activeFilters: activeFilters ?? this.activeFilters,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMarker: clearSelectedMarker ? null : (selectedMarker ?? this.selectedMarker),
      isSearchExpanded: isSearchExpanded ?? this.isSearchExpanded,
      isLoading: isLoading ?? this.isLoading,
      isFiltersOpen: isFiltersOpen ?? this.isFiltersOpen,
    );
  }

  List<MapMarkerModel> get filteredMarkers {
    return markers.where((m) {
      final matchesFilter = activeFilters.contains(m.type);
      final matchesSearch = searchQuery.isEmpty ||
          m.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (m.breed != null && m.breed!.toLowerCase().contains(searchQuery.toLowerCase())) ||
          (m.description != null && m.description!.toLowerCase().contains(searchQuery.toLowerCase()));
      return matchesFilter && matchesSearch;
    }).toList();
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final MapService _mapService;

  MapNotifier(this._mapService) : super(const MapState()) {
    loadMapData();
  }

  Future<void> loadMapData() async {
    state = state.copyWith(isLoading: true);
    final markers = await _mapService.getMapMarkers();
    final gpsDevice = await _mapService.getActiveGpsDevice();
    state = state.copyWith(
      markers: markers,
      gpsDevice: gpsDevice,
      isLoading: false,
    );
  }

  void toggleFilter(String filter) {
    final currentFilters = Set<String>.from(state.activeFilters);
    if (currentFilters.contains(filter)) {
      currentFilters.remove(filter);
    } else {
      currentFilters.add(filter);
    }
    state = state.copyWith(activeFilters: currentFilters);
  }

  void toggleAllFilters(bool enableAll) {
    if (enableAll) {
      state = state.copyWith(activeFilters: const {'lost_pet', 'playground', 'companion'});
    } else {
      state = state.copyWith(activeFilters: const {});
    }
  }

  void toggleFiltersOpen(bool isOpen) {
    state = state.copyWith(isFiltersOpen: isOpen);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleSearchExpanded([bool? expanded]) {
    state = state.copyWith(
      isSearchExpanded: expanded ?? !state.isSearchExpanded,
      searchQuery: (expanded ?? !state.isSearchExpanded) ? state.searchQuery : '',
    );
  }

  void selectMarker(MapMarkerModel? marker) {
    state = state.copyWith(selectedMarker: marker, clearSelectedMarker: marker == null);
  }

  void addMarker(MapMarkerModel newMarker) {
    state = state.copyWith(
      markers: [newMarker, ...state.markers],
      selectedMarker: newMarker,
    );
  }

  void updateSafeZoneRadius(double newRadius) async {
    if (state.gpsDevice == null) return;
    final updatedDevice = await _mapService.updateSafeZone(
      state.gpsDevice!.imei,
      state.gpsDevice!.safeZoneLatitude ?? state.gpsDevice!.latitude,
      state.gpsDevice!.safeZoneLongitude ?? state.gpsDevice!.longitude,
      newRadius,
    );
    state = state.copyWith(gpsDevice: updatedDevice);
  }
}

final mapServiceProvider = Provider<MapService>((ref) => MapService());

final mapNotifierProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final service = ref.watch(mapServiceProvider);
  return MapNotifier(service);
});
