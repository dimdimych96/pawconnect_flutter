import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/search/widgets/specialist_card.dart';
import 'package:pawconnect/models/specialist_model.dart';

void main() {
  final testSpecialist = SpecialistModel(
    id: 'spec-anna-melnikova',
    name: 'Анна Мельникова',
    avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
    profession: 'cynologist',
    professionTitle: 'Кинолог-зоопсихолог',
    rating: 4.95,
    reviewsCount: 48,
    experienceYears: 7,
    priceFrom: 1500,
    priceUnit: '₽ / занятие',
    isVerified: true,
    district: 'Заельцовский',
    address: 'Красный проспект, 182',
    latitude: 55.0620,
    longitude: 82.9150,
    bio: 'Гуманная дрессировка щенков и взрослых собак без аверсивных методов.',
    phone: '+7 (913) 450-12-88',
    telegram: '@anna_dogpsychology',
    services: [
      SpecialistServiceItemModel(title: 'Индивидуальная тренировка', price: 1500),
    ],
  );

  testWidgets('SpecialistCard renders name, profession, verified badge, rating and price', (tester) async {
    bool routeClicked = false;
    bool inquireClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SpecialistCard(
              specialist: testSpecialist,
              onRoute: () => routeClicked = true,
              onInquire: () => inquireClicked = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Анна Мельникова'), findsOneWidget);
    expect(find.textContaining('Кинолог-зоопсихолог'), findsOneWidget);
    expect(find.text('ВЕРИФИЦИРОВАН'), findsOneWidget);
    expect(find.textContaining('5.0 (48)'), findsOneWidget);
    expect(find.textContaining('от 1 500 ₽ / занятие'), findsOneWidget);
    expect(find.textContaining('Красный проспект, 182'), findsOneWidget);
    expect(find.text('Маршрут'), findsOneWidget);
    expect(find.text('Связаться'), findsOneWidget);

    // Test taps
    await tester.tap(find.text('Маршрут'));
    expect(routeClicked, isTrue);

    await tester.tap(find.text('Связаться'));
    expect(inquireClicked, isTrue);
  });
}
