import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/specialist_model.dart';

void main() {
  group('SpecialistModel Tests', () {
    final sampleJson = {
      'id': 'spec-anna-melnikova',
      'name': 'Анна Мельникова',
      'avatar_url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      'profession': 'cynologist',
      'profession_title': 'Кинолог-зоопсихолог',
      'rating': 4.95,
      'reviews_count': 48,
      'experience_years': 7,
      'price_from': 1500,
      'price_unit': '₽ / занятие',
      'is_verified': true,
      'district': 'Заельцовский',
      'address': 'Красный проспект, 182',
      'latitude': 55.0620,
      'longitude': 82.9150,
      'bio': 'Гуманная дрессировка щенков и взрослых собак.',
      'phone': '+7 (913) 450-12-88',
      'telegram': '@anna_dogpsychology',
      'services': [
        {'title': 'Индивидуальная тренировка', 'price': 1500},
        {'title': 'Консультация зоопсихолога', 'price': 2000},
      ],
    };

    test('SpecialistModel parses JSON and serializes back correctly', () {
      final model = SpecialistModel.fromJson(sampleJson);

      expect(model.id, 'spec-anna-melnikova');
      expect(model.name, 'Анна Мельникова');
      expect(model.profession, 'cynologist');
      expect(model.professionTitle, 'Кинолог-зоопсихолог');
      expect(model.rating, 4.95);
      expect(model.reviewsCount, 48);
      expect(model.experienceYears, 7);
      expect(model.priceFrom, 1500);
      expect(model.priceUnit, '₽ / занятие');
      expect(model.isVerified, true);
      expect(model.district, 'Заельцовский');
      expect(model.address, 'Красный проспект, 182');
      expect(model.latitude, 55.0620);
      expect(model.longitude, 82.9150);
      expect(model.services.length, 2);
      expect(model.services.first.title, 'Индивидуальная тренировка');
      expect(model.services.first.price, 1500);

      expect(model.formattedPrice, 'от 1 500 ₽ / занятие');
      expect(model.formattedRating, '★ 5.0 (48)');

      final jsonOut = model.toJson();
      expect(jsonOut['id'], 'spec-anna-melnikova');
      expect(jsonOut['name'], 'Анна Мельникова');
      expect((jsonOut['services'] as List).length, 2);
    });

    test('SpecialistModel copyWith works accurately', () {
      final model = SpecialistModel.fromJson(sampleJson);
      final updated = model.copyWith(
        rating: 5.0,
        reviewsCount: 49,
      );

      expect(updated.rating, 5.0);
      expect(updated.reviewsCount, 49);
      expect(updated.name, model.name);
    });
  });
}
