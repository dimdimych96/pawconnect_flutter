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
  String _selectedCategory = 'all';

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

  String _getSectionTitle() {
    switch (_selectedCategory) {
      case 'cynologist':
        return 'Кинологи и зоопсихологи';
      case 'dogsitter':
        return 'Догситтеры и передержка';
      case 'groomer':
        return 'Мастера груминга';
      case 'vet':
        return 'Ветеринарные центры';
      case 'playground':
        return 'Площадки для собак';
      case 'lost_pet':
        return 'Объявления о пропажах';
      case 'companion':
        return 'Поиск компаньонов';
      default:
        return 'Специалисты и места рядом';
    }
  }

  Widget _buildFilterChip(String categoryId, String label) {
    final isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        key: ValueKey('search_chip_$categoryId'),
        onTap: () => _onTileTap(categoryId),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentGreen.withValues(alpha: 0.14)
                : AppColors.obsidianGlassSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentGreen.withValues(alpha: 0.35)
                  : AppColors.glassBorder,
              width: 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerCard(MapMarkerModel marker) {
    final isSos = marker.type == 'lost_pet';
    final isPark = marker.type == 'playground';
    final activeColor = isSos
        ? AppColors.accentRed
        : (isPark ? AppColors.accentGreen : AppColors.accentBlue);
    final badgeLabel = isSos
        ? 'Пропал питомец'
        : (isPark ? 'Площадка' : 'Метка');
    final locationText = marker.address ?? marker.description ?? 'Новосибирск';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
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
                        Icon(Icons.location_on_outlined, size: 16, color: AppColors.accentBlue),
                        SizedBox(width: 6),
                        Text(
                          'На карте',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
                        Icon(Icons.directions_walk_rounded, size: 16, color: AppColors.accentGreen),
                        SizedBox(width: 6),
                        Text(
                          'Маршрут',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
        matchesCategory = false;
      } else {
        matchesCategory = m.type == _selectedCategory;
      }

      return matchesQuery && matchesCategory;
    }).toList();

    final totalCount = filteredSpecialists.length + filteredMarkers.length;
    final sectionTitle = _getSectionTitle();

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Clean Header Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Поиск и специалисты',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Проверенные кинологи, догситтеры, клиники и площадки',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Search Bar Field (single ClipRRect inside GlassContainer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                borderRadius: 12,
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Кинологи, клиники, догситтеры, места',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          padding: EdgeInsets.zero,
                          tooltip: 'Очистить поиск',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
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
                    _buildFilterChip('all', 'Все'),
                    _buildFilterChip('cynologist', 'Кинологи'),
                    _buildFilterChip('dogsitter', 'Догситтеры'),
                    _buildFilterChip('groomer', 'Груминг'),
                    _buildFilterChip('vet', 'Ветклиники'),
                    _buildFilterChip('playground', 'Площадки'),
                    _buildFilterChip('lost_pet', 'Пропажи'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Section Label & Total Count
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$totalCount найдено',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 5. Results Stream (Specialists + Places)
            Expanded(
              child: totalCount == 0
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.search_off_rounded,
                            color: AppColors.textTertiary,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ничего не найдено',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 96),
                      itemCount: totalCount,
                      itemBuilder: (context, index) {
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

                        final markerIndex = index - filteredSpecialists.length;
                        final marker = filteredMarkers[markerIndex];
                        return _buildMarkerCard(marker);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
