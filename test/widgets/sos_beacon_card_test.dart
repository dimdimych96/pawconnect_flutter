import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/community_post_model.dart';
import 'package:pawconnect/features/community/widgets/sos_beacon_card.dart';

void main() {
  testWidgets('SosBeaconCard renders urgent badge, volunteer counter, and action buttons', (tester) async {
    bool sightingTapped = false;
    bool volunteerTapped = false;
    bool mapTapped = false;

    final post = CommunityPostModel(
      id: 'sos-1',
      authorName: 'Дмитрий',
      district: 'Центральный',
      category: 'sos',
      title: 'SOS: Пропал хаски Арчи',
      content: 'Убежал 2 часа назад в Нарымском сквере',
      likesCount: 15,
      isLiked: false,
      volunteersCount: 4,
      sightingsCount: 1,
      isVolunteering: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SosBeaconCard(
              post: post,
              onSightingTap: () => sightingTapped = true,
              onVolunteerTap: () => volunteerTapped = true,
              onOpenMapTap: () => mapTapped = true,
              onLike: () {},
              onComment: () {},
              onShare: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('🚨 СРОЧНЫЙ ПОИСК'), findsOneWidget);
    expect(find.text('Замечен здесь'), findsOneWidget);
    expect(find.text('Помочь в поиске'), findsOneWidget);
    expect(find.text('4 в отряде'), findsOneWidget);

    await tester.tap(find.text('Замечен здесь'));
    await tester.pump();
    expect(sightingTapped, isTrue);

    await tester.tap(find.text('Помочь в поиске'));
    await tester.pump();
    expect(volunteerTapped, isTrue);

    await tester.tap(find.text('На карте'));
    await tester.pump();
    expect(mapTapped, isTrue);
  });
}
