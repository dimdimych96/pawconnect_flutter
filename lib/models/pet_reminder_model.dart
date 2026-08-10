class PetReminderModel {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final bool isCompleted;
  final String category; // 'vaccine', 'grooming', 'vet', 'pill'
  final String? notes;

  PetReminderModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.isCompleted,
    required this.category,
    this.notes,
  });

  factory PetReminderModel.fromJson(Map<String, dynamic> json) {
    return PetReminderModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '12:00',
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'] ?? 'vet',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'time': time,
        'isCompleted': isCompleted,
        'category': category,
        'notes': notes,
      };

  PetReminderModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? time,
    bool? isCompleted,
    String? category,
    String? notes,
  }) {
    return PetReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}
