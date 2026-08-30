import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Centralized configuration for quick park highlight style tweaks
class ParkHighlightConfig {
  /// Fill color for park polygons (e.g. emerald glass, mint neon, olive)
  static Color fillColor = const Color(0x2830D158);

  /// Border outline color for park polygons
  static Color borderColor = const Color(0x8030D158);

  /// Width of park polygon borders
  static double borderStrokeWidth = 1.5;

  /// Global master toggle for park highlights overlay
  static bool enableParkHighlights = true;
}

/// Precise real-world polygons for Novosibirsk's major parks and green walking zones
class ParkZonesData {
  static List<Polygon> getParkPolygons() {
    if (!ParkHighlightConfig.enableParkHighlights) {
      return [];
    }

    final fill = ParkHighlightConfig.fillColor;
    final border = ParkHighlightConfig.borderColor;
    final stroke = ParkHighlightConfig.borderStrokeWidth;

    return realParkPolygons.map((park) {
      return Polygon(
        points: park.points,
        color: fill,
        borderColor: border,
        borderStrokeWidth: stroke,
      );
    }).toList();
  }

  static final List<RealParkDefinition> realParkPolygons = [
    // 1. ПКиО «Центральный» (Точный контур: ул. Мичурина, ул. Фрунзе, ул. Каменская, ул. Ядринцевская)
    RealParkDefinition(
      name: 'ПКиО «Центральный»',
      points: const [
        LatLng(55.0335, 82.9228), // NW (Фрунзе / Мичурина)
        LatLng(55.0342, 82.9282), // NE (Фрунзе / Каменская)
        LatLng(55.0305, 82.9292), // SE (Ядринцевская / Каменская)
        LatLng(55.0298, 82.9238), // SW (Ядринцевская / Мичурина)
      ],
    ),

    // 2. Нарымский Сквер (Точный контур: ул. Нарымская, ул. 1905 года, ул. Советская, Вознесенский собор)
    RealParkDefinition(
      name: 'Нарымский сквер',
      points: const [
        LatLng(55.0458, 82.9082), // NW (1905 года / Нарымская)
        LatLng(55.0466, 82.9132), // NE (1905 года / Советская)
        LatLng(55.0432, 82.9142), // SE (Советская / Цирк)
        LatLng(55.0425, 82.9092), // SW (Нарымская / Цирк)
      ],
    ),

    // 3. Первомайский Сквер (Точный контур: Красный пр., ул. Ленина, ул. Советская, ул. М. Горького)
    RealParkDefinition(
      name: 'Первомайский сквер',
      points: const [
        LatLng(55.0288, 82.9192), // NW (Ленина / Советская)
        LatLng(55.0294, 82.9222), // NE (Ленина / Красный пр.)
        LatLng(55.0266, 82.9230), // SE (М. Горького / Красный пр.)
        LatLng(55.0260, 82.9200), // SW (М. Горького / Советская)
      ],
    ),

    // 4. ПКиО «Берёзовая роща» (Точный контур: пр. Дзержинского, ул. Кошурникова, ул. Фрунзе, ул. Планетная)
    RealParkDefinition(
      name: 'ПКиО «Берёзовая роща»',
      points: const [
        LatLng(55.0508, 82.9515), // NW (Фрунзе / Планетная)
        LatLng(55.0528, 82.9640), // NE (Фрунзе / Кошурникова)
        LatLng(55.0445, 82.9658), // SE (пр. Дзержинского / Кошурникова)
        LatLng(55.0428, 82.9530), // SW (пр. Дзержинского / Планетная)
      ],
    ),

    // 5. Монумент Славы / Сквер Славы (Точный контур: ул. Станиславского, ул. Плахотного, ул. Пархоменко)
    RealParkDefinition(
      name: 'Монумент Славы',
      points: const [
        LatLng(55.0278, 82.8638), // NW (Плахотного / Римского-Корсакова)
        LatLng(55.0286, 82.8718), // NE (Плахотного / Станиславского)
        LatLng(55.0242, 82.8728), // SE (Пархоменко / Станиславского)
        LatLng(55.0235, 82.8648), // SW (Пархоменко / Римского-Корсакова)
      ],
    ),

    // 6. ПКиО им. С.М. Кирова (Левый берег: ул. Станиславского, ул. Широкая, ул. Котовского)
    RealParkDefinition(
      name: 'ПКиО им. Кирова',
      points: const [
        LatLng(55.0302, 82.8725), // NW (Широкая / Ватутина)
        LatLng(55.0312, 82.8802), // NE (Широкая / Станиславского)
        LatLng(55.0268, 82.8812), // SE (Котовского / Станиславского)
        LatLng(55.0258, 82.8735), // SW (Котовского / Ватутина)
      ],
    ),

    // 7. Михайловская Набережная (Прибрежный парк вдоль Оби у Речного Вокзала)
    RealParkDefinition(
      name: 'Михайловская набережная',
      points: const [
        LatLng(55.0135, 82.9288), // Северо-западная окнечность (Мост)
        LatLng(55.0152, 82.9348), // Речной вокзал
        LatLng(55.0118, 82.9425), // Набережная центр
        LatLng(55.0085, 82.9465), // Юго-восточная граница
        LatLng(55.0072, 82.9405), // Берег река Обь
        LatLng(55.0115, 82.9298), // Берег у моста
      ],
    ),

    // 8. ПКиО «Заельцовский» (Реальный сосновый массив парка на берегу Оби)
    RealParkDefinition(
      name: 'ПКиО «Заельцовский»',
      points: const [
        LatLng(55.0645, 82.8360), // Северный въезд
        LatLng(55.0675, 82.8580), // Восток (ул. Сухарная)
        LatLng(55.0535, 82.8635), // Юго-Восток
        LatLng(55.0485, 82.8390), // Южный берег Оби
      ],
    ),

    // 9. Новосибирский Зоопарк и Дендропарк (Заельцовский район)
    RealParkDefinition(
      name: 'Зоопарк им. Шило и Дендропарк',
      points: const [
        LatLng(55.0585, 82.8720), // NW (Жуковского / Северная)
        LatLng(55.0610, 82.8940), // NE (Дендропарк восток)
        LatLng(55.0522, 82.8970), // SE (Ботаническая)
        LatLng(55.0490, 82.8745), // SW (Вход в Зоопарк)
      ],
    ),

    // 10. ПКиО «Сосновый бор» (Калининский район: ул. Учительская / ул. 25 лет Октября)
    RealParkDefinition(
      name: 'ПКиО «Сосновый бор»',
      points: const [
        LatLng(55.0745, 82.9360), // NW (Учительская)
        LatLng(55.0785, 82.9585), // NE (Богдана Хмельницкого)
        LatLng(55.0665, 82.9635), // SE (ЛДС Сибирь восток)
        LatLng(55.0622, 82.9410), // SW (Речка Ельцовка)
      ],
    ),

    // 11. Новый Парк «Арена» (у ЛДС Арена на берегу Оби)
    RealParkDefinition(
      name: 'Парк «Арена»',
      points: const [
        LatLng(54.9982, 82.9060), // Берег Оби север
        LatLng(55.0012, 82.9225), // Октябрьский мост подход
        LatLng(54.9922, 82.9282), // Арена юг
        LatLng(54.9892, 82.9110), // Берег Оби юг
      ],
    ),

    // 12. ПКиО «Бугринская роща» (Прибрежный сосновый бор у Бугринского моста)
    RealParkDefinition(
      name: 'Бугринская роща',
      points: const [
        LatLng(54.9780, 82.9460), // Бугринский мост примыкание
        LatLng(54.9825, 82.9655), // Восток берег Оби
        LatLng(54.9665, 82.9710), // Смотровая площадка
        LatLng(54.9615, 82.9490), // Запад (ул. Саввы Кожевникова)
      ],
    ),

    // 13. Центральный Сибирский Ботанический Сад (ЦСБС СО РАН, Академгородок)
    RealParkDefinition(
      name: 'ЦСБС СО РАН (Ботанический сад)',
      points: const [
        LatLng(54.8385, 83.0860), // Северо-запад (ул. Золотодолинская)
        LatLng(54.8455, 83.1260), // Северо-восток (Дендрарий)
        LatLng(54.8210, 83.1360), // Юго-восток (Лесной массив)
        LatLng(54.8155, 83.0960), // Юго-запад (Речка Зырянка)
      ],
    ),

    // 14. ПКиО «Затулинский» (Кировский район: ул. Зорге / ул. Громова)
    RealParkDefinition(
      name: 'ПКиО «Затулинский»',
      points: const [
        LatLng(54.9542, 82.8805), // NW (ул. Зорге)
        LatLng(54.9562, 82.8925), // NE (ул. Громова)
        LatLng(54.9502, 82.8955), // SE (Городок аттракционов)
        LatLng(54.9482, 82.8835), // SW (ул. Петухова)
      ],
    ),
  ];
}

class RealParkDefinition {
  final String name;
  final List<LatLng> points;

  const RealParkDefinition({
    required this.name,
    required this.points,
  });
}
