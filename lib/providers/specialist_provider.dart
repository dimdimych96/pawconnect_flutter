import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/specialist_model.dart';
import '../services/specialist_service.dart';

class SpecialistsState {
  final AsyncValue<List<SpecialistModel>> specialistsAsync;
  final String selectedProfession; // 'all', 'cynologist', 'dogsitter', 'groomer', 'vet_specialist'
  final String selectedDistrict;
  final String searchQuery;
  final bool isSendingInquiry;

  const SpecialistsState({
    this.specialistsAsync = const AsyncValue.loading(),
    this.selectedProfession = 'all',
    this.selectedDistrict = 'Все районы',
    this.searchQuery = '',
    this.isSendingInquiry = false,
  });

  SpecialistsState copyWith({
    AsyncValue<List<SpecialistModel>>? specialistsAsync,
    String? selectedProfession,
    String? selectedDistrict,
    String? searchQuery,
    bool? isSendingInquiry,
  }) {
    return SpecialistsState(
      specialistsAsync: specialistsAsync ?? this.specialistsAsync,
      selectedProfession: selectedProfession ?? this.selectedProfession,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      searchQuery: searchQuery ?? this.searchQuery,
      isSendingInquiry: isSendingInquiry ?? this.isSendingInquiry,
    );
  }
}

class SpecialistsNotifier extends StateNotifier<SpecialistsState> {
  final SpecialistService _service;

  SpecialistsNotifier(this._service) : super(const SpecialistsState()) {
    loadSpecialists();
  }

  Future<void> loadSpecialists({bool forceRefresh = false}) async {
    if (!forceRefresh && state.specialistsAsync is AsyncLoading && state.specialistsAsync.hasValue) {
      return;
    }

    if (forceRefresh) {
      state = state.copyWith(specialistsAsync: const AsyncValue.loading());
    }

    try {
      final items = await _service.getSpecialists(
        profession: state.selectedProfession,
        district: state.selectedDistrict,
        query: state.searchQuery,
      );
      if (!mounted) return;
      state = state.copyWith(specialistsAsync: AsyncValue.data(items));
    } catch (e, st) {
      if (!mounted) return;
      state = state.copyWith(specialistsAsync: AsyncValue.error(e, st));
    }
  }

  Future<void> setProfession(String profession) async {
    if (state.selectedProfession == profession) return;
    state = state.copyWith(
      selectedProfession: profession,
      specialistsAsync: const AsyncValue.loading(),
    );
    await loadSpecialists();
  }

  Future<void> setDistrict(String district) async {
    if (state.selectedDistrict == district) return;
    state = state.copyWith(
      selectedDistrict: district,
      specialistsAsync: const AsyncValue.loading(),
    );
    await loadSpecialists();
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(
      searchQuery: query,
      specialistsAsync: const AsyncValue.loading(),
    );
    await loadSpecialists();
  }

  Future<bool> sendInquiry(
    String specialistId, {
    required String message,
    String? petId,
  }) async {
    if (!mounted) return false;
    state = state.copyWith(isSendingInquiry: true);
    try {
      final success = await _service.sendInquiry(
        specialistId,
        message: message,
        petId: petId,
      );
      if (!mounted) return false;
      state = state.copyWith(isSendingInquiry: false);
      return success;
    } catch (_) {
      if (!mounted) return false;
      state = state.copyWith(isSendingInquiry: false);
      return false;
    }
  }
}

final specialistServiceProvider = Provider<SpecialistService>((ref) {
  return SpecialistService();
});

final specialistsNotifierProvider =
    StateNotifierProvider<SpecialistsNotifier, SpecialistsState>((ref) {
  final service = ref.watch(specialistServiceProvider);
  return SpecialistsNotifier(service);
});
