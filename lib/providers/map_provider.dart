import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_marker_model.dart';
import '../models/gps_device_model.dart';
import '../models/route_model.dart';
import '../services/map_service.dart';
import '../services/location_service.dart';

class MapState {
  final List<MapMarkerModel> markers;
  final GpsDeviceModel? gpsDevice;
  final Set<String> activeFilters; // 'lost_pet', 'playground', 'companion'
  final String searchQuery;
  final MapMarkerModel? selectedMarker;
  final bool isSearchExpanded;
  final bool isLoading;
  final bool isFiltersOpen;
  final double userLatitude;
  final double userLongitude;
  final double? userAccuracy;
  final bool hasLocationPermission;
  final bool isLocationTrackingActive;
  final ActiveRouteModel? activeRoute;
  final bool isNavigating;
  final int currentStepIndex;
  final String selectedTransportMode; // 'walk', 'park_safe', 'drive'

  const MapState({
    this.markers = const [],
    this.gpsDevice,
    this.activeFilters = const {'lost_pet', 'playground', 'companion'},
    this.searchQuery = '',
    this.selectedMarker,
    this.isSearchExpanded = false,
    this.isLoading = false,
    this.isFiltersOpen = false,
    this.userLatitude = 55.0285,
    this.userLongitude = 82.9165,
    this.userAccuracy,
    this.hasLocationPermission = true,
    this.isLocationTrackingActive = false,
    this.activeRoute,
    this.isNavigating = false,
    this.currentStepIndex = 0,
    this.selectedTransportMode = 'walk',
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
    double? userLatitude,
    double? userLongitude,
    double? userAccuracy,
    bool? hasLocationPermission,
    bool? isLocationTrackingActive,
    ActiveRouteModel? activeRoute,
    bool clearActiveRoute = false,
    bool? isNavigating,
    int? currentStepIndex,
    String? selectedTransportMode,
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
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      userAccuracy: userAccuracy ?? this.userAccuracy,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      isLocationTrackingActive: isLocationTrackingActive ?? this.isLocationTrackingActive,
      activeRoute: clearActiveRoute ? null : (activeRoute ?? this.activeRoute),
      isNavigating: isNavigating ?? this.isNavigating,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      selectedTransportMode: selectedTransportMode ?? this.selectedTransportMode,
    );
  }

  int get distanceToPetInMeters {
    if (gpsDevice == null) return 0;
    const distanceCalc = Distance();
    final meters = distanceCalc.as(
      LengthUnit.Meter,
      LatLng(userLatitude, userLongitude),
      LatLng(gpsDevice!.latitude, gpsDevice!.longitude),
    );
    return meters.round();
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

  RouteStep? get currentStep {
    if (activeRoute == null || activeRoute!.steps.isEmpty) return null;
    if (currentStepIndex >= 0 && currentStepIndex < activeRoute!.steps.length) {
      return activeRoute!.steps[currentStepIndex];
    }
    return activeRoute!.steps.first;
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final MapService _mapService;
  final LocationService _locationService;
  StreamSubscription<UserLocation>? _locationSubscription;

  MapNotifier(
    this._mapService, {
    LocationService? locationService,
  })  : _locationService = locationService ?? GeolocatorLocationService(),
        super(const MapState()) {
    loadMapData();
    initLocationTracking();
  }

  Future<void> loadMapData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    final markers = await _mapService.getMapMarkers();
    final gpsDevice = await _mapService.getActiveGpsDevice();
    if (!mounted) return;
    state = state.copyWith(
      markers: markers,
      gpsDevice: gpsDevice,
      isLoading: false,
    );
  }

  Future<void> initLocationTracking() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      state = state.copyWith(isLocationTrackingActive: false);
      return;
    }

    var permission = await _locationService.checkPermission();
    if (permission == LocationPermissionStatus.denied) {
      permission = await _locationService.requestPermission();
    }
    if (!mounted) return;

    final hasPerm = permission == LocationPermissionStatus.granted;
    state = state.copyWith(hasLocationPermission: hasPerm);

    // Fetch initial position (via GPS or real IP fallback)
    final initialPos = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (initialPos != null) {
      state = state.copyWith(
        userLatitude: initialPos.latitude,
        userLongitude: initialPos.longitude,
        userAccuracy: initialPos.accuracy,
        isLocationTrackingActive: true,
      );
    }

    if (hasPerm) {
      // Subscribe to live position stream
      await _locationSubscription?.cancel();
      _locationSubscription = _locationService.getLocationStream(distanceFilter: 5).listen((pos) {
        if (!mounted) return;
        state = state.copyWith(
          userLatitude: pos.latitude,
          userLongitude: pos.longitude,
          userAccuracy: pos.accuracy,
          isLocationTrackingActive: true,
        );
      });
    }
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
    state = state.copyWith(
      selectedMarker: marker,
      clearSelectedMarker: marker == null,
      isNavigating: false,
    );
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
    if (!mounted) return;
    state = state.copyWith(gpsDevice: updatedDevice);
  }

  void updateUserLocation(double lat, double lng) {
    state = state.copyWith(userLatitude: lat, userLongitude: lng);
  }

  Future<void> buildRouteTo(
    LatLng destination,
    String title, {
    String type = 'marker',
    String? mode,
  }) async {
    final transportMode = mode ?? state.selectedTransportMode;
    final start = LatLng(state.userLatitude, state.userLongitude);
    final realRoute = await _mapService.fetchRealRoute(
      origin: start,
      destination: destination,
      title: title,
      type: type,
      mode: transportMode,
    );
    if (!mounted) return;
    state = state.copyWith(
      activeRoute: realRoute,
      selectedTransportMode: transportMode,
      currentStepIndex: 0,
      clearSelectedMarker: true,
    );
  }

  void setTransportMode(String mode) {
    if (state.activeRoute == null) return;
    state = state.copyWith(selectedTransportMode: mode);
    buildRouteTo(
      state.activeRoute!.endPoint,
      state.activeRoute!.destinationTitle,
      type: state.activeRoute!.destinationType,
      mode: mode,
    );
  }

  void startNavigation() {
    if (state.activeRoute == null) return;
    state = state.copyWith(
      isNavigating: true,
      currentStepIndex: 0,
    );
  }

  void endNavigation() {
    state = state.copyWith(
      isNavigating: false,
      clearActiveRoute: true,
      currentStepIndex: 0,
    );
  }

  void nextStep() {
    if (state.activeRoute == null) return;
    if (state.currentStepIndex < state.activeRoute!.steps.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    }
  }

  void prevStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
    }
  }

  void clearRoute() {
    state = state.copyWith(
      clearActiveRoute: true,
      isNavigating: false,
      currentStepIndex: 0,
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

final mapServiceProvider = Provider<MapService>((ref) => MapService());
final locationServiceProvider = Provider<LocationService>((ref) => GeolocatorLocationService());

final mapNotifierProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final service = ref.watch(mapServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return MapNotifier(service, locationService: locationService);
});
