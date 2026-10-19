import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class SpecialistServiceItemModel {
  final String title;
  final int price;

  SpecialistServiceItemModel({
    required this.title,
    required this.price,
  });

  factory SpecialistServiceItemModel.fromJson(Map<String, dynamic> json) {
    return SpecialistServiceItemModel(
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
      };
}

class SpecialistModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String profession; // 'cynologist', 'dogsitter', 'groomer', 'vet_specialist'
  final String professionTitle;
  final double rating;
  final int reviewsCount;
  final int experienceYears;
  final int priceFrom;
  final String priceUnit;
  final bool isVerified;
  final String district;
  final String address;
  final double latitude;
  final double longitude;
  final String? bio;
  final String? phone;
  final String? telegram;
  final List<SpecialistServiceItemModel> services;

  SpecialistModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.profession,
    required this.professionTitle,
    required this.rating,
    required this.reviewsCount,
    required this.experienceYears,
    required this.priceFrom,
    required this.priceUnit,
    this.isVerified = true,
    required this.district,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.bio,
    this.phone,
    this.telegram,
    this.services = const [],
  });

  factory SpecialistModel.fromJson(Map<String, dynamic> json) {
    final rawServices = (json['services'] as List<dynamic>?) ?? [];
    return SpecialistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      profession: json['profession'] ?? 'cynologist',
      professionTitle: json['profession_title'] ?? json['professionTitle'] ?? 'Специалист',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? (json['reviewsCount'] as num?)?.toInt() ?? 0,
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? (json['experienceYears'] as num?)?.toInt() ?? 1,
      priceFrom: (json['price_from'] as num?)?.toInt() ?? (json['priceFrom'] as num?)?.toInt() ?? 1000,
      priceUnit: json['price_unit'] ?? json['priceUnit'] ?? '₽ / занятие',
      isVerified: json['is_verified'] ?? json['isVerified'] ?? true,
      district: json['district'] ?? 'Центральный',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 55.03,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 82.92,
      bio: json['bio'],
      phone: json['phone'],
      telegram: json['telegram'],
      services: rawServices
          .map((s) => SpecialistServiceItemModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
        'profession': profession,
        'profession_title': professionTitle,
        'rating': rating,
        'reviews_count': reviewsCount,
        'experience_years': experienceYears,
        'price_from': priceFrom,
        'price_unit': priceUnit,
        'is_verified': isVerified,
        'district': district,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'bio': bio,
        'phone': phone,
        'telegram': telegram,
        'services': services.map((s) => s.toJson()).toList(),
      };

  SpecialistModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? profession,
    String? professionTitle,
    double? rating,
    int? reviewsCount,
    int? experienceYears,
    int? priceFrom,
    String? priceUnit,
    bool? isVerified,
    String? district,
    String? address,
    double? latitude,
    double? longitude,
    String? bio,
    String? phone,
    String? telegram,
    List<SpecialistServiceItemModel>? services,
  }) {
    return SpecialistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profession: profession ?? this.profession,
      professionTitle: professionTitle ?? this.professionTitle,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      experienceYears: experienceYears ?? this.experienceYears,
      priceFrom: priceFrom ?? this.priceFrom,
      priceUnit: priceUnit ?? this.priceUnit,
      isVerified: isVerified ?? this.isVerified,
      district: district ?? this.district,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      telegram: telegram ?? this.telegram,
      services: services ?? this.services,
    );
  }

  String get formattedPrice {
    final formattedNum = priceFrom.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return 'от $formattedNum $priceUnit';
  }

  String get formattedRating => '★ ${rating.toStringAsFixed(1)} ($reviewsCount)';

  IconData get professionIcon {
    switch (profession) {
      case 'cynologist':
        return Icons.psychology_rounded;
      case 'dogsitter':
        return Icons.home_rounded;
      case 'groomer':
        return Icons.content_cut_rounded;
      case 'vet_specialist':
        return Icons.local_hospital_rounded;
      default:
        return Icons.verified_user_rounded;
    }
  }

  Color get professionColor {
    switch (profession) {
      case 'cynologist':
        return AppColors.accentYellow;
      case 'dogsitter':
        return AppColors.accentGreen;
      case 'groomer':
        return const Color(0xFFF472B6);
      case 'vet_specialist':
        return AppColors.accentBlue;
      default:
        return AppColors.accentGreen;
    }
  }
}
