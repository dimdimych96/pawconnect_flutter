import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/walk_session_model.dart';
import '../services/walk_service.dart';

class WalkState {
  final WalkSessionModel? activeWalk;
  final List<WalkingCompanionModel> nearbyCompanions;
  final bool isLoading;
  final bool isStarting;
  final bool isStopping;
  final String? errorMessage;
  final WalkingCompanionModel? selectedCompanion;
  final DogTemperament userPetTemperament;
  final String activePetId;
  final String activePetName;

  const WalkState({
    this.activeWalk,
    this.nearbyCompanions = const [],
    this.isLoading = false,
    this.isStarting = false,
    this.isStopping = false,
    this.errorMessage,
    this.selectedCompanion,
    this.userPetTemperament = DogTemperament.playful,
    this.activePetId = 'pet-archi-1',
    this.activePetName = 'Арчи',
  });

  bool get isWalking => activeWalk != null && activeWalk!.isActive;

  WalkState copyWith({
    WalkSessionModel? activeWalk,
    bool clearActiveWalk = false,
    List<WalkingCompanionModel>? nearbyCompanions,
    bool? isLoading,
    bool? isStarting,
    bool? isStopping,
    String? errorMessage,
    bool clearError = false,
    WalkingCompanionModel? selectedCompanion,
    bool clearSelectedCompanion = false,
    DogTemperament? userPetTemperament,
    String? activePetId,
    String? activePetName,
  }) {
    return WalkState(
      activeWalk: clearActiveWalk ? null : (activeWalk ?? this.activeWalk),
      nearbyCompanions: nearbyCompanions ?? this.nearbyCompanions,
      isLoading: isLoading ?? this.isLoading,
      isStarting: isStarting ?? this.isStarting,
      isStopping: isStopping ?? this.isStopping,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedCompanion: clearSelectedCompanion ? null : (selectedCompanion ?? this.selectedCompanion),
      userPetTemperament: userPetTemperament ?? this.userPetTemperament,
      activePetId: activePetId ?? this.activePetId,
      activePetName: activePetName ?? this.activePetName,
    );
  }
}

class WalkNotifier extends StateNotifier<WalkState> {
  final WalkService _service;

  WalkNotifier(this._service) : super(const WalkState());

  Future<void> loadNearbyCompanions({
    double latitude = 55.0302,
    double longitude = 82.9204,
    double radiusMeters = 5000,
  }) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final companions = await _service.getNearbyCompanions(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      if (!mounted) return;
      state = state.copyWith(nearbyCompanions: companions, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Не удалось загрузить компаньонов поблизости',
      );
    }
  }

  Future<void> checkActiveWalk({String? petId}) async {
    final targetPetId = petId ?? state.activePetId;
    try {
      final session = await _service.getActiveWalk(petId: targetPetId);
      if (!mounted) return;
      if (session != null) {
        state = state.copyWith(activeWalk: session);
      } else {
        state = state.copyWith(clearActiveWalk: true);
      }
    } catch (_) {}
  }

  Future<bool> startWalk({
    required String petId,
    required String petName,
    String walkMode = 'open',
    required double latitude,
    required double longitude,
    DogTemperament? temperament,
    String? note,
  }) async {
    if (!mounted) return false;
    state = state.copyWith(isStarting: true, clearError: true);
    try {
      final session = await _service.startWalk(
        petId: petId,
        walkMode: walkMode,
        latitude: latitude,
        longitude: longitude,
        note: note,
      );
      if (!mounted) return false;
      state = state.copyWith(
        activeWalk: session,
        isStarting: false,
        activePetId: petId,
        activePetName: petName,
        userPetTemperament: temperament ?? state.userPetTemperament,
      );
      // Refresh companions list
      await loadNearbyCompanions(latitude: latitude, longitude: longitude);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isStarting: false,
        errorMessage: 'Не удалось начать прогулку',
      );
      return false;
    }
  }

  Future<bool> stopWalk() async {
    if (state.activeWalk == null) return false;
    final petId = state.activeWalk!.petId;
    if (!mounted) return false;
    state = state.copyWith(isStopping: true, clearError: true);
    try {
      await _service.stopWalk(petId: petId);
      if (!mounted) return false;
      state = state.copyWith(
        clearActiveWalk: true,
        isStopping: false,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isStopping: false,
        errorMessage: 'Не удалось завершить прогулку',
      );
      return false;
    }
  }

  Future<bool> sendWalkInvite({
    required String toPetId,
    String? message,
  }) async {
    try {
      await _service.sendWalkInvite(toPetId: toPetId, message: message);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(errorMessage: 'Не удалось отправить приглашение');
      return false;
    }
  }

  void selectCompanion(WalkingCompanionModel? companion) {
    if (companion == null) {
      state = state.copyWith(clearSelectedCompanion: true);
    } else {
      state = state.copyWith(selectedCompanion: companion);
    }
  }

  Future<void> setUserPetTemperament(DogTemperament temperament, {String? petId}) async {
    final targetPetId = petId ?? state.activePetId;
    if (!mounted) return;
    state = state.copyWith(userPetTemperament: temperament);
    try {
      await _service.updatePetTemperament(petId: targetPetId, temperament: temperament);
    } catch (_) {}
  }
}

final walkServiceProvider = Provider<WalkService>((ref) => WalkService());

final walkNotifierProvider = StateNotifierProvider<WalkNotifier, WalkState>((ref) {
  final service = ref.watch(walkServiceProvider);
  return WalkNotifier(service);
});
