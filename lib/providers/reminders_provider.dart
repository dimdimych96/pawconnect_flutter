import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_reminder_model.dart';
import '../services/reminder_service.dart';

class RemindersState {
  final List<PetReminderModel> reminders;
  final bool isLoading;

  const RemindersState({
    this.reminders = const [],
    this.isLoading = false,
  });

  RemindersState copyWith({
    List<PetReminderModel>? reminders,
    bool? isLoading,
  }) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RemindersNotifier extends StateNotifier<RemindersState> {
  final ReminderService _reminderService;

  RemindersNotifier(this._reminderService) : super(const RemindersState()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true);
    final reminders = await _reminderService.getReminders();
    state = state.copyWith(reminders: reminders, isLoading: false);
  }

  void toggleReminder(String id, bool value) async {
    final updatedList = state.reminders.map((r) {
      if (r.id == id) {
        return r.copyWith(isCompleted: value);
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: updatedList);
    await _reminderService.toggleReminder(id, value);
  }

  void addReminder(PetReminderModel newReminder) async {
    state = state.copyWith(reminders: [newReminder, ...state.reminders]);
    await _reminderService.addReminder(newReminder);
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService());

final remindersNotifierProvider = StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  final service = ref.watch(reminderServiceProvider);
  return RemindersNotifier(service);
});
