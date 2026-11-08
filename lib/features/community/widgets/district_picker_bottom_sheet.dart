import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Modal Bottom Sheet for selecting a Novosibirsk district.
/// Uses Apple Liquid Glass modal styling with acrylic blur and root navigator presentation.
class DistrictPickerBottomSheet extends StatelessWidget {
  final String currentDistrict;
  final ValueChanged<String> onSelect;

  static const List<String> novosibirskDistricts = [
    'Все районы',
    'Центральный',
    'Заельцовский',
    'Дзержинский',
    'Железнодорожный',
    'Калининский',
    'Кировский',
    'Ленинский',
    'Октябрьский',
    'Первомайский',
    'Советский (Академгородок)',
  ];

  const DistrictPickerBottomSheet({
    super.key,
    required this.currentDistrict,
    required this.onSelect,
  });

  /// Static helper to display the district picker with root navigator.
  static Future<String?> show(
    BuildContext context, {
    required String currentDistrict,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => DistrictPickerBottomSheet(
        currentDistrict: currentDistrict,
        onSelect: (district) => Navigator.of(context).pop(district),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: AppColors.obsidianBackground.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1.0,
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.accentGreen,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Район Новосибирска',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        key: const ValueKey('district_picker_close_button'),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 16),

                // District list
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shrinkWrap: true,
                    itemCount: novosibirskDistricts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final district = novosibirskDistricts[index];
                      final isSelected = district == currentDistrict;
                      final isAll = district == 'Все районы';

                      return InkWell(
                        key: ValueKey('district_option_$district'),
                        onTap: () => onSelect(district),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.obsidianGlassSurface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.glassBorder
                                  : Colors.transparent,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isAll ? Icons.apartment_rounded : Icons.place_rounded,
                                size: 18,
                                color: isSelected
                                    ? AppColors.accentGreen
                                    : AppColors.textTertiary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isAll ? 'Все районы города' : district,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.accentGreen,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
