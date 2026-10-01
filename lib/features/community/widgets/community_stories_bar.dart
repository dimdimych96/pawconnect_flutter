import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/pet_story_model.dart';

/// Horizontal stories rail displaying active and official pet stories
/// with Apple Liquid Glass aesthetic and gradient status rings.
class CommunityStoriesBar extends StatelessWidget {
  final List<PetStoryModel> stories;
  final void Function(PetStoryModel story, int index)? onTapStory;
  final VoidCallback? onTapAddStory;
  final String? currentUserAvatar;

  const CommunityStoriesBar({
    super.key,
    required this.stories,
    this.onTapStory,
    this.onTapAddStory,
    this.currentUserAvatar,
  });

  // Official PawConnect story gradient (Azure/Emerald)
  static const LinearGradient _officialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF34D399),
      Color(0xFF3B82F6),
    ],
  );

  // Active walking pet gradient (Orange/Coral)
  static const LinearGradient _activePetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF8A00),
      Color(0xFFE52E71),
    ],
  );

  String _getStoryLabel(PetStoryModel story) {
    if (story.isOfficial) {
      if (story.petName != null && story.petName!.isNotEmpty) {
        return story.petName!;
      }
      return 'PawConnect';
    }

    if (story.petName != null && story.petName!.isNotEmpty) {
      return story.petName!;
    }

    return story.authorName.isNotEmpty ? story.authorName : 'Питомец';
  }

  @override
  Widget build(BuildContext context) {
    final showAddTile = onTapAddStory != null;
    if (stories.isEmpty && !showAddTile) {
      return const SizedBox.shrink();
    }

    final totalCount = stories.length + (showAddTile ? 1 : 0);

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalCount,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (showAddTile && index == 0) {
            return GestureDetector(
              key: const ValueKey('add_story_button'),
              onTap: onTapAddStory,
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.glassBorderSubtle,
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: const BoxDecoration(
                              color: AppColors.obsidianBackground,
                              shape: BoxShape.circle,
                            ),
                            child: PawAvatar(
                              url: currentUserAvatar,
                              radius: 26,
                              fallbackIcon: Icons.person_rounded,
                              fallbackColor: AppColors.accentBlue,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: AppColors.accentBlue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x663B82F6),
                                  blurRadius: 6,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ваша история',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final storyIndex = showAddTile ? index - 1 : index;
          final story = stories[storyIndex];
          final label = _getStoryLabel(story);

          return GestureDetector(
            onTap: () => onTapStory?.call(story, index),
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with gradient/viewed ring and optional verified badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Ring Container
                      Container(
                        width: 66,
                        height: 66,
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: story.isViewed
                              ? null
                              : (story.isOfficial ? _officialGradient : _activePetGradient),
                          border: story.isViewed
                              ? Border.all(color: const Color(0x4094A3B8), width: 2.0)
                              : null,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: const BoxDecoration(
                            color: AppColors.obsidianBackground,
                            shape: BoxShape.circle,
                          ),
                          child: PawAvatar(
                            url: story.authorAvatar,
                            radius: 26,
                            fallbackIcon: story.isOfficial ? Icons.pets_rounded : Icons.pets_rounded,
                            fallbackColor: story.isOfficial ? AppColors.accentBlue : AppColors.accentGreen,
                          ),
                        ),
                      ),

                      // Verified badge overlay for official stories
                      if (story.isOfficial)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: AppColors.obsidianBackground,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Label below avatar
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: story.isViewed ? FontWeight.normal : FontWeight.w500,
                      color: story.isViewed ? AppColors.textTertiary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
