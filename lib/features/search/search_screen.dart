import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../providers/map_provider.dart';
import '../../models/map_marker_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all'; // 'all', 'lost_pet', 'playground', 'vet', 'companion'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTileTap(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = 'all';
      } else {
        _selectedCategory = category;
      }
    });
  }

  void _navigateToMapAndFocus(MapMarkerModel marker) {
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    mapNotifier.selectMarker(marker);
    context.go('/map');
  }

  void _navigateToMapAndBuildRoute(MapMarkerModel marker) async {
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    context.go('/map');
    await mapNotifier.buildRouteTo(
      LatLng(marker.latitude, marker.longitude),
      marker.title,
      type: marker.type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final allMarkers = mapState.markers;
    final query = _searchController.text.trim().toLowerCase();

    // Filter markers based on query and selected category tile
    final filtered = allMarkers.where((m) {
      final titleMatch = m.title.toLowerCase().contains(query);
      final descMatch = (m.description ?? '').toLowerCase().contains(query);
      final addrMatch = (m.address ?? '').toLowerCase().contains(query);
      final matchesQuery = query.isEmpty || titleMatch || descMatch || addrMatch;

      final matchesCategory = _selectedCategory == 'all' || m.type == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    // Counts for tiles
    final lostCount = allMarkers.where((m) => m.type == 'lost_pet').length;
    final playgroundCount = allMarkers.where((m) => m.type == 'playground').length;
    final companionCount = allMarkers.where((m) => m.type == 'companion').length;

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean Header Title (No district selector needed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Поиск',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Места, площадки и объявления поблизости',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Liquid Glass Search Bar Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  borderRadius: 22,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Введите имя питомца, клинику или место...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 3. Interactive 2x2 Category Grid Tiles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Tile 1: Lost Pets (SOS)
                  Expanded(
                    child: _CategoryTile(
                      icon: Icons.warning_amber_rounded,
                      title: 'Пропажи',
                      subtitle: '$lostCount рядом',
                      activeColor: AppColors.accentRed,
                      isSelected: _selectedCategory == 'lost_pet',
                      onTap: () => _onTileTap('lost_pet'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tile 2: Playgrounds
                  Expanded(
                    child: _CategoryTile(
                      icon: Icons.park_rounded,
                      title: 'Площадки',
                      subtitle: '$playgroundCount мест',
                      activeColor: AppColors.accentGreen,
                      isSelected: _selectedCategory == 'playground',
                      onTap: () => _onTileTap('playground'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Tile 3: Vet Clinics
                  Expanded(
                    child: _CategoryTile(
                      icon: Icons.local_hospital_rounded,
                      title: 'Ветклиники',
                      subtitle: '24/7 скорая',
                      activeColor: AppColors.accentBlue,
                      isSelected: _selectedCategory == 'vet',
                      onTap: () => _onTileTap('vet'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tile 4: Companions
                  Expanded(
                    child: _CategoryTile(
                      icon: Icons.people_alt_rounded,
                      title: 'Компаньоны',
                      subtitle: '$companionCount онлайн',
                      activeColor: AppColors.accentYellow,
                      isSelected: _selectedCategory == 'companion',
                      onTap: () => _onTileTap('companion'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'lost_pet'
                        ? '🐾 Объявления о пропажах'
                        : (_selectedCategory == 'playground'
                            ? '🐶 Площадки для собак'
                            : (_selectedCategory == 'vet'
                                ? '🏥 Круглосуточные клиники'
                                : (_selectedCategory == 'companion'
                                    ? '🎾 Поиск компаньонов'
                                    : '📍 Результаты рядом со мной'))),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${filtered.length} найдено',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 4. Filtered Activity / Search Results Stream
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 44,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ничего не найдено',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final marker = filtered[index];
                        final isSos = marker.type == 'lost_pet';
                        final isPark = marker.type == 'playground';
                        final activeColor = isSos
                            ? AppColors.accentRed
                            : (isPark ? AppColors.accentGreen : AppColors.accentBlue);

                        final locationText = marker.address ?? marker.description ?? 'Новосибирск';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            accentColor: activeColor,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        marker.title,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: activeColor.withValues(alpha: 0.20),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: activeColor.withValues(alpha: 0.45),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        isSos ? 'ПОТЕРЯН' : (isPark ? 'ПЛОЩАДКА' : 'МЕТКА'),
                                        style: TextStyle(
                                          color: activeColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  locationText,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassCapsule(
                                        isActive: true,
                                        activeColor: activeColor,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        onTap: () {
                                          if (isPark) {
                                            _navigateToMapAndBuildRoute(marker);
                                          } else {
                                            _navigateToMapAndFocus(marker);
                                          }
                                        },
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isPark ? Icons.directions_rounded : Icons.map_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isPark ? 'Построить маршрут 🧭' : 'Показать на карте 📍',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color activeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.activeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.20) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.30),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.85),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
