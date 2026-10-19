import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../models/map_marker_model.dart';
import '../../models/specialist_model.dart';
import '../../providers/map_provider.dart';
import '../../providers/specialist_provider.dart';
import 'widgets/specialist_card.dart';
import 'widgets/specialist_inquiry_modal.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all'; // 'all', 'cynologist', 'dogsitter', 'groomer', 'vet', 'playground', 'lost_pet', 'companion'

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

  void _navigateToMapAndBuildRouteToSpecialist(SpecialistModel specialist) async {
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    context.go('/map');
    await mapNotifier.buildRouteTo(
      LatLng(specialist.latitude, specialist.longitude),
      specialist.name,
      type: 'specialist',
    );
  }

  void _openSpecialistInquiry(SpecialistModel specialist) {
    SpecialistInquiryModal.show(
      context,
      specialist: specialist,
      onSubmit: (message) async {
        return ref.read(specialistsNotifierProvider.notifier).sendInquiry(
              specialist.id,
              message: message,
            );
      },
    );
  }

  Widget _buildFilterChip(String categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        key: ValueKey('search_chip_$categoryId'),
        onTap: () => _onTileTap(categoryId),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentGreen.withValues(alpha: 0.20)
                : AppColors.obsidianGlassSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentGreen
                  : Colors.white.withValues(alpha: 0.10),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.accentGreen : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapNotifierProvider);
    final allMarkers = mapState.markers;
    final query = _searchController.text.trim().toLowerCase();

    // Specialists from provider
    final specialistsState = ref.watch(specialistsNotifierProvider);
    final allSpecialists = specialistsState.specialistsAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <SpecialistModel>[],
    );

    // Filter specialists
    final filteredSpecialists = allSpecialists.where((s) {
      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          (s.bio ?? '').toLowerCase().contains(query) ||
          s.address.toLowerCase().contains(query) ||
          s.professionTitle.toLowerCase().contains(query);

      bool matchesCat;
      if (_selectedCategory == 'all') {
        matchesCat = true;
      } else if (_selectedCategory == 'vet') {
        matchesCat = s.profession == 'vet_specialist';
      } else {
        matchesCat = s.profession == _selectedCategory;
      }

      return matchesQuery && matchesCat;
    }).toList();

    // Filter markers based on query and selected category
    final filteredMarkers = allMarkers.where((m) {
      final titleMatch = m.title.toLowerCase().contains(query);
      final descMatch = (m.description ?? '').toLowerCase().contains(query);
      final addrMatch = (m.address ?? '').toLowerCase().contains(query);
      final matchesQuery = query.isEmpty || titleMatch || descMatch || addrMatch;

      bool matchesCategory;
      if (_selectedCategory == 'all') {
        matchesCategory = true;
      } else if (_selectedCategory == 'cynologist' ||
          _selectedCategory == 'dogsitter' ||
          _selectedCategory == 'groomer') {
        matchesCategory = false; // Only specialists for these categories
      } else {
        matchesCategory = m.type == _selectedCategory;
      }

      return matchesQuery && matchesCategory;
    }).toList();

    final totalCount = filteredSpecialists.length + filteredMarkers.length;

    // Counts for tiles
    final lostCount = allMarkers.where((m) => m.type == 'lost_pet').length;
    final playgroundCount = allMarkers.where((m) => m.type == 'playground').length;
    final companionCount = allMarkers.where((m) => m.type == 'companion').length;

    String sectionTitle;
    if (_selectedCategory == 'cynologist') {
      sectionTitle = '🐕 Кинологи & Зоопсихологи';
    } else if (_selectedCategory == 'dogsitter') {
      sectionTitle = '🏡 Догситтеры & Передержка';
    } else if (_selectedCategory == 'groomer') {
      sectionTitle = '✂️ Мастера груминга';
    } else if (_selectedCategory == 'vet') {
      sectionTitle = '🏥 Ветеринарные центры & Скорая';
    } else if (_selectedCategory == 'playground') {
      sectionTitle = '🐶 Площадки для собак';
    } else if (_selectedCategory == 'lost_pet') {
      sectionTitle = '🐾 Объявления о пропажах';
    } else if (_selectedCategory == 'companion') {
      sectionTitle = '🎾 Поиск компаньонов';
    } else {
      sectionTitle = '📍 Верифицированные специалисты и места';
    }

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean Header Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Поиск & Специалисты',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Верифицированные кинологи, догситтеры, клиники и площадки',
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
                            hintText: 'Поиск кинологов, клиник, догситтеров, мест...',
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

            const SizedBox(height: 12),

            // 3. Category Filter Chips Rail
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', '🐾 Все'),
                    _buildFilterChip('cynologist', '🐕 Кинологи'),
                    _buildFilterChip('dogsitter', '🏡 Догситтеры'),
                    _buildFilterChip('groomer', '✂️ Груминг'),
                    _buildFilterChip('vet', '🏥 Ветклиники'),
                    _buildFilterChip('playground', '🌳 Площадки'),
                    _buildFilterChip('lost_pet', '🚨 Пропажи'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 4. Quick 2x2 Category Grid Tiles (when on 'all' or quick browsing)
            if (_selectedCategory == 'all') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _CategoryTile(
                        icon: Icons.warning_amber_rounded,
                        title: 'Пропажи',
                        subtitle: '$lostCount рядом',
                        activeColor: AppColors.accentRed,
                        isSelected: false,
                        onTap: () => _onTileTap('lost_pet'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CategoryTile(
                        icon: Icons.park_rounded,
                        title: 'Площадки',
                        subtitle: '$playgroundCount мест',
                        activeColor: AppColors.accentGreen,
                        isSelected: false,
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
                    Expanded(
                      child: _CategoryTile(
                        icon: Icons.local_hospital_rounded,
                        title: 'Ветклиники',
                        subtitle: '24/7 скорая',
                        activeColor: AppColors.accentBlue,
                        isSelected: false,
                        onTap: () => _onTileTap('vet'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CategoryTile(
                        icon: Icons.people_alt_rounded,
                        title: 'Компаньоны',
                        subtitle: '$companionCount онлайн',
                        activeColor: AppColors.accentYellow,
                        isSelected: false,
                        onTap: () => _onTileTap('companion'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Section Label & Total Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sectionTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$totalCount найдено',
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

            // 5. Results Stream (Specialists + Places)
            Expanded(
              child: totalCount == 0
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
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 100),
                      itemCount: totalCount,
                      itemBuilder: (context, index) {
                        // Render Specialists first
                        if (index < filteredSpecialists.length) {
                          final specialist = filteredSpecialists[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SpecialistCard(
                              key: ValueKey('specialist_${specialist.id}'),
                              specialist: specialist,
                              onRoute: () => _navigateToMapAndBuildRouteToSpecialist(specialist),
                              onInquire: () => _openSpecialistInquiry(specialist),
                            ),
                          );
                        }

                        // Render Map Markers
                        final markerIndex = index - filteredSpecialists.length;
                        final marker = filteredMarkers[markerIndex];
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
                                        activeColor: AppColors.accentBlue,
                                        onTap: () => _navigateToMapAndFocus(marker),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.location_on_rounded, size: 14, color: AppColors.accentBlue),
                                            SizedBox(width: 4),
                                            Text(
                                              'На карте',
                                              style: TextStyle(
                                                color: AppColors.accentBlue,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GlassCapsule(
                                        isActive: true,
                                        activeColor: AppColors.accentGreen,
                                        onTap: () => _navigateToMapAndBuildRoute(marker),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.directions_walk_rounded, size: 14, color: AppColors.accentGreen),
                                            SizedBox(width: 4),
                                            Text(
                                              'Маршрут',
                                              style: TextStyle(
                                                color: AppColors.accentGreen,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : AppColors.obsidianGlassSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.50)
                : AppColors.glassBorderSubtle,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: activeColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: activeColor.withValues(alpha: 0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
