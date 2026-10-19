import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/specialist_model.dart';

class SpecialistCard extends StatelessWidget {
  final SpecialistModel specialist;
  final VoidCallback onRoute;
  final VoidCallback onInquire;

  const SpecialistCard({
    super.key,
    required this.specialist,
    required this.onRoute,
    required this.onInquire,
  });

  @override
  Widget build(BuildContext context) {
    final profColor = specialist.professionColor;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.obsidianCardTranslucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorderSubtle,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Name, Trust Badge & Profession
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with verified badge ring
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  PawAvatar(
                    url: specialist.avatarUrl,
                    radius: 26,
                    fallbackColor: profColor,
                  ),
                  if (specialist.isVerified)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.obsidianBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.accentGreen,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Name, Title, Experience
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            specialist.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (specialist.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.accentGreen.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_rounded, size: 10, color: AppColors.accentGreen),
                                SizedBox(width: 3),
                                Text(
                                  'ВЕРИФИЦИРОВАН',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGreen,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(specialist.professionIcon, size: 14, color: profColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${specialist.professionTitle} • Стаж ${specialist.experienceYears} лет',
                            style: TextStyle(
                              fontSize: 12,
                              color: profColor,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Metrics pill bar (Rating, Price, District)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: AppColors.accentYellow),
                    const SizedBox(width: 4),
                    Text(
                      specialist.formattedRating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 16, color: AppColors.glassBorder),
                // Price
                Text(
                  specialist.formattedPrice,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGreen,
                  ),
                ),
                Container(width: 1, height: 16, color: AppColors.glassBorder),
                // District
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      specialist.district,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Address & Bio
          if (specialist.address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.map_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    specialist.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (specialist.bio != null && specialist.bio!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              specialist.bio!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Services chips
          if (specialist.services.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: specialist.services.take(2).map((srv) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.glassBorderSubtle),
                  ),
                  child: Text(
                    '${srv.title} · ${srv.price} ₽',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons: «Маршрут» and «Связаться»
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRoute,
                  icon: const Icon(Icons.directions_rounded, size: 16, color: AppColors.accentBlue),
                  label: const Text(
                    'Маршрут',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.glassBorder),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onInquire,
                  icon: const Icon(Icons.send_rounded, size: 14, color: Colors.black),
                  label: const Text(
                    'Связаться',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
