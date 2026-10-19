import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/breed_model.dart';
import '../models/pet_health_profile_model.dart';
import '../services/health_service.dart';

class HealthState {
  final PetHealthProfileModel? profile;
  final BreedModel? currentBreed;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final String selectedPetId;

  const HealthState({
    this.profile,
    this.currentBreed,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.selectedPetId = 'pet-archi-1',
  });

  HealthState copyWith({
    PetHealthProfileModel? profile,
    BreedModel? currentBreed,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    String? selectedPetId,
  }) {
    return HealthState(
      profile: profile ?? this.profile,
      currentBreed: currentBreed ?? this.currentBreed,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedPetId: selectedPetId ?? this.selectedPetId,
    );
  }
}

class HealthNotifier extends StateNotifier<HealthState> {
  final HealthService _service;

  HealthNotifier(this._service) : super(const HealthState()) {
    loadProfile(state.selectedPetId);
  }

  Future<void> loadProfile(String petId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true, selectedPetId: petId);
    try {
      final profile = await _service.getPetHealthProfile(petId);
      if (!mounted) return;
      state = state.copyWith(profile: profile, isLoading: false);

      // Also fetch breed intelligence if available
      if (profile.breedId != null || profile.breedName != null) {
        await loadBreed(profile.breedId ?? profile.breedName!);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Не удалось загрузить профиль здоровья',
      );
    }
  }

  Future<void> loadBreed(String breedIdOrName) async {
    try {
      BreedModel? breed;
      if (breedIdOrName.length <= 25 && !breedIdOrName.contains(' ')) {
        breed = await _service.getBreedDetail(breedIdOrName);
      } else {
        breed = await _service.matchBreedByName(breedIdOrName);
      }
      if (!mounted) return;
      if (breed != null) {
        state = state.copyWith(currentBreed: breed);
      }
    } catch (_) {}
  }

  Future<bool> updateCondition({
    required String petId,
    double? weightKg,
    double? targetWeightKg,
    int? bcsScore,
    int? activityGoalMinutes,
  }) async {
    if (!mounted) return false;
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.updatePetCondition(
        petId,
        weightKg: weightKg,
        targetWeightKg: targetWeightKg,
        bcsScore: bcsScore,
        activityGoalMinutes: activityGoalMinutes,
      );
      if (!mounted) return false;
      state = state.copyWith(profile: updated, isUpdating: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Не удалось обновить параметры кондиции',
      );
      return false;
    }
  }

  Future<bool> applyStandardMilestones(String petId) async {
    if (!mounted) return false;
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.applyStandardMilestones(petId);
      if (!mounted) return false;
      state = state.copyWith(profile: updated, isUpdating: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'Не удалось применить стандартные вехи',
      );
      return false;
    }
  }
}

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());

final healthNotifierProvider = StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  final service = ref.watch(healthServiceProvider);
  return HealthNotifier(service);
});
