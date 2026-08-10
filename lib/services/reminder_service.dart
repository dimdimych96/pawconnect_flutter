import 'package:dio/dio.dart';
import '../models/pet_reminder_model.dart';

class ReminderService {
  final Dio _dio;

  ReminderService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.pawconnect.app/api/v1', connectTimeout: const Duration(seconds: 2)));

  static final List<PetReminderModel> mockReminders = [
    PetReminderModel(
      id: 'rem-1',
      title: 'Обработка от клещей (Симпарика)',
      date: DateTime.now(),
      time: '10:00',
      isCompleted: true,
      category: 'pill',
      notes: '1 таблетка с кормом после прогулки',
    ),
    PetReminderModel(
      id: 'rem-2',
      title: 'Ежегодная вакцинация (Nobivac DHPPi)',
      date: DateTime.now().add(const Duration(days: 14)),
      time: '12:30',
      isCompleted: false,
      category: 'vaccine',
      notes: 'Запись в клинике ВетЛекарь на Красном проспекте',
    ),
    PetReminderModel(
      id: 'rem-3',
      title: 'Плановый осмотр ветеринара',
      date: DateTime.now().add(const Duration(days: 30)),
      time: '16:00',
      isCompleted: false,
      category: 'vet',
      notes: 'Проверка суставов и чистка зубов ультразвуком',
    ),
    PetReminderModel(
      id: 'rem-4',
      title: 'Груминг и стрижка когтей',
      date: DateTime.now().add(const Duration(days: 45)),
      time: '14:00',
      isCompleted: false,
      category: 'grooming',
      notes: 'Салон DogGrooming на Вокзальной магистрали',
    ),
  ];

  Future<List<PetReminderModel>> getReminders() async {
    try {
      final response = await _dio.get('/reminders');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => PetReminderModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return mockReminders;
  }

  Future<PetReminderModel> addReminder(PetReminderModel reminder) async {
    try {
      final response = await _dio.post('/reminders', data: reminder.toJson());
      if (response.statusCode == 200 && response.data != null) {
        return PetReminderModel.fromJson(response.data);
      }
    } catch (_) {}
    return reminder;
  }

  Future<PetReminderModel> toggleReminder(String id, bool isCompleted) async {
    try {
      final response = await _dio.patch('/reminders/$id', data: {'isCompleted': isCompleted});
      if (response.statusCode == 200 && response.data != null) {
        return PetReminderModel.fromJson(response.data);
      }
    } catch (_) {}
    final match = mockReminders.firstWhere((r) => r.id == id, orElse: () => mockReminders.first);
    return match.copyWith(isCompleted: isCompleted);
  }
}
