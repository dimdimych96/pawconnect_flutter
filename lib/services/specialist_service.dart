import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../models/specialist_model.dart';

class SpecialistService {
  final Dio _dio;
  final bool allowMockFallback;

  SpecialistService({
    Dio? dio,
    this.allowMockFallback = false,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
              ),
            );

  static final List<SpecialistModel> mockSpecialists = [
    SpecialistModel(
      id: 'spec-anna-melnikova',
      name: 'Анна Мельникова',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
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
      bio: 'Гуманная дрессировка щенков и взрослых собак без аверсивных методов. Коррекция страхов, тревоги разлуки и натяжения поводка.',
      phone: '+7 (913) 450-12-88',
      telegram: '@anna_dogpsychology',
      services: [
        SpecialistServiceItemModel(title: 'Индивидуальная тренировка', price: 1500),
        SpecialistServiceItemModel(title: 'Консультация зоопсихолога', price: 2000),
      ],
    ),
    SpecialistModel(
      id: 'spec-dmitry-vet',
      name: 'Клиника «ВетЛекарь»',
      avatarUrl: 'https://images.unsplash.com/photo-1628009368231-7bb7cfcb0def?auto=format&fit=crop&w=256&q=80',
      profession: 'vet_specialist',
      professionTitle: 'Ветеринарный центр 24/7',
      rating: 4.90,
      reviewsCount: 112,
      experienceYears: 12,
      priceFrom: 900,
      priceUnit: '₽ / прием',
      isVerified: true,
      district: 'Центральный',
      address: 'ул. Фрунзе, 57',
      latitude: 55.0380,
      longitude: 82.9280,
      bio: 'Круглосуточный стационар, цифровая рентгенография, УЗИ экспертного класса и экстренная хирургия.',
      phone: '+7 (383) 220-44-11',
      telegram: '@vetlekar_nsk',
      services: [
        SpecialistServiceItemModel(title: 'Первичный осмотр терапевта', price: 900),
        SpecialistServiceItemModel(title: 'Вакцинация комплексная', price: 1800),
      ],
    ),
    SpecialistModel(
      id: 'spec-elena-dogsitter',
      name: 'Елена Смирнова',
      avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=256&q=80',
      profession: 'dogsitter',
      professionTitle: 'Догситтер & Передержка',
      rating: 4.98,
      reviewsCount: 34,
      experienceYears: 4,
      priceFrom: 850,
      priceUnit: '₽ / сутки',
      isVerified: true,
      district: 'Советский',
      address: 'Морской проспект, 22',
      latitude: 54.8480,
      longitude: 83.0980,
      bio: 'Уютная домашняя передержка в Академгородке рядом с лесом. Никаких клеток. Фото- и видеоотчеты 3 раза в день.',
      phone: '+7 (923) 115-77-90',
      telegram: '@elena_petsitting',
      services: [
        SpecialistServiceItemModel(title: 'Суточная домашняя передержка', price: 850),
        SpecialistServiceItemModel(title: 'Дневной выгул и присмотр (1 час)', price: 450),
      ],
    ),
    SpecialistModel(
      id: 'spec-dog-grooming',
      name: 'Студия груминга «PawChic»',
      avatarUrl: 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=256&q=80',
      profession: 'groomer',
      professionTitle: 'Мастера бережного груминга',
      rating: 4.92,
      reviewsCount: 67,
      experienceYears: 5,
      priceFrom: 1800,
      priceUnit: '₽ / комплекс',
      isVerified: true,
      district: 'Ленинский',
      address: 'проспект Карла Маркса, 30',
      latitude: 54.9880,
      longitude: 82.8950,
      bio: 'Бережный груминг без наркоза и фиксаторов. Экспресс-линька, гигиеническая стрижка, spa-уход с озоном.',
      phone: '+7 (952) 880-33-22',
      telegram: '@pawchic_grooming',
      services: [
        SpecialistServiceItemModel(title: 'Полный гигиенический комплекс', price: 1800),
        SpecialistServiceItemModel(title: 'Экспресс-линька для хаски и корги', price: 2500),
      ],
    ),
    SpecialistModel(
      id: 'spec-maksim-cynologist',
      name: 'Максим Громов',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=256&q=80',
      profession: 'cynologist',
      professionTitle: 'Инструктор ОКД и УГС',
      rating: 4.88,
      reviewsCount: 29,
      experienceYears: 9,
      priceFrom: 1300,
      priceUnit: '₽ / занятие',
      isVerified: true,
      district: 'Октябрьский',
      address: 'ул. Кирова, 113',
      latitude: 55.0120,
      longitude: 82.9550,
      bio: 'Нормативная дрессировка (ОКД, УГС), подготовка к выставкам, адаптация собак из приюта.',
      phone: '+7 (913) 770-90-55',
      telegram: '@gromov_dogs',
      services: [
        SpecialistServiceItemModel(title: 'Курс послушания УГС', price: 1300),
        SpecialistServiceItemModel(title: 'Тестирование поведения', price: 1500),
      ],
    ),
  ];

  Future<List<SpecialistModel>> getSpecialists({
    String? profession,
    String? district,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (profession != null && profession != 'all') {
        queryParams['profession'] = profession;
      }
      if (district != null && district != 'Все районы') {
        queryParams['district'] = district;
      }
      if (query != null && query.trim().isNotEmpty) {
        queryParams['query'] = query.trim();
      }

      final response = await _dio.get(
        '/specialists',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => SpecialistModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (!allowMockFallback && !AppConfig.enableOfflineMocks) {
        rethrow;
      }
    }

    // Local in-memory filtering fallback
    return mockSpecialists.where((s) {
      if (profession != null && profession != 'all' && s.profession != profession) {
        return false;
      }
      if (district != null && district != 'Все районы' && s.district != district) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchesName = s.name.toLowerCase().contains(q);
        final matchesBio = (s.bio ?? '').toLowerCase().contains(q);
        final matchesAddr = s.address.toLowerCase().contains(q);
        final matchesTitle = s.professionTitle.toLowerCase().contains(q);
        if (!matchesName && !matchesBio && !matchesAddr && !matchesTitle) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<SpecialistModel> getSpecialistDetail(String id) async {
    try {
      final response = await _dio.get('/specialists/$id');
      if (response.statusCode == 200 && response.data != null) {
        return SpecialistModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      if (!allowMockFallback && !AppConfig.enableOfflineMocks) {
        rethrow;
      }
    }

    return mockSpecialists.firstWhere(
      (s) => s.id == id,
      orElse: () => mockSpecialists.first,
    );
  }

  Future<bool> sendInquiry(
    String specialistId, {
    required String message,
    String? petId,
    String? preferredDate,
  }) async {
    try {
      final response = await _dio.post(
        '/specialists/$specialistId/inquiry',
        data: {
          'message': message,
          'pet_id': petId,
          'preferred_date': preferredDate,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      if (!allowMockFallback && !AppConfig.enableOfflineMocks) {
        rethrow;
      }
      return true;
    }
  }
}
