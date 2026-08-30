import 'package:flutter/material.dart';

/// Конфигурация цветовой темы карты PawConnect
/// Здесь можно напрямую менять HEX-цвета любых элементов карты
class MapThemeConfig {
  // 1. 🌲 Парки, скверы и зеленые зоны
  static const Color parkFill = Color(0xFF1E432E);       // Насыщенный благородный изумруд
  static const Color parkOutline = Color(0xFF2E6B47);    // Контур парков

  // 2. 🌊 Водоемы (Река Обь, водохранилище, озера)
  static const Color water = Color(0xFF0C1622);          // Глубокий темно-синий

  // 3. 🛣 Дорожная сеть
  static const Color roadPrimary = Color(0xFF2C2C32);    // Красный проспект, магистрали
  static const Color roadSecondary = Color(0xFF1F1F24);  // Второстепенные улицы и аллеи
  static const Color roadPedestrian = Color(0xFF24332A); // Пешеходные дорожки в парках

  // 4. 🏢 Застройка
  static const Color building = Color(0xFF141418);       // Контуры домов
  static const Color buildingBorder = Color(0xFF1C1C22); // Грани зданий

  // 5. 🌑 Фоновое полотно
  static const Color background = Color(0xFF0A0A0C);     // Фирменный Obsidian Black
}
