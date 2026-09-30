import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/pet_story_model.dart';

/// Fullscreen Instagram-style Story Player for pet stories.
///
/// Features:
/// - Segmented progress bars with 5-second automatic progression.
/// - Left 1/3 tap goes to previous story; Right 2/3 tap advances.
/// - Long-press pauses and releases resume playback.
/// - Vertical swipe down dismisses the player.
/// - Verified author badges, district pill, and status overlay.
class StoryPlayerScreen extends StatefulWidget {
  final List<PetStoryModel> stories;
  final int initialIndex;
  final ValueChanged<String>? onStoryViewed;

  const StoryPlayerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.onStoryViewed,
  });

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animController;
  double _accumulatedDrag = 0.0;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();

    if (widget.stories.isNotEmpty) {
      _currentIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    } else {
      _currentIndex = 0;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onStoryTimeCompleted();
      }
    });

    if (widget.stories.isNotEmpty) {
      _animController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.stories.isNotEmpty) {
          widget.onStoryViewed?.call(widget.stories[_currentIndex].id);
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onStoryTimeCompleted() {
    if (!mounted || _isDismissed) return;

    if (_currentIndex < widget.stories.length - 1) {
      _goToNextStory();
    } else {
      _dismiss();
    }
  }

  void _goToNextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      widget.onStoryViewed?.call(widget.stories[_currentIndex].id);
      _animController.reset();
      _animController.forward();
    } else {
      _dismiss();
    }
  }

  void _goToPreviousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      widget.onStoryViewed?.call(widget.stories[_currentIndex].id);
      _animController.reset();
      _animController.forward();
    } else {
      _animController.reset();
      _animController.forward();
    }
  }

  void _dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;
    _animController.stop();
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < width / 3) {
      _goToPreviousStory();
    } else {
      _goToNextStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.obsidianBackground,
        body: Center(
          child: Text(
            'Нет историй',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final currentStory = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background media
          _buildStoryMedia(currentStory),

          // Top and bottom gradients for legibility
          _buildGradients(),

          // Gestures layer: taps, pause, swipe down to close
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: _handleTapUp,
            onLongPressStart: (_) => _animController.stop(),
            onLongPressEnd: (_) => _animController.forward(),
            onLongPressCancel: () => _animController.forward(),
            onVerticalDragStart: (_) {
              _accumulatedDrag = 0.0;
            },
            onVerticalDragUpdate: (details) {
              _accumulatedDrag += details.primaryDelta ?? 0.0;
              if (_accumulatedDrag > 100.0) {
                _dismiss();
              }
            },
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0.0) > 250.0 ||
                  details.velocity.pixelsPerSecond.dy > 100.0) {
                _dismiss();
              }
              _accumulatedDrag = 0.0;
            },
          ),

          // Top overlays: progress bars & author header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  _buildProgressBars(),
                  const SizedBox(height: 10),
                  _buildTopHeader(currentStory),
                ],
              ),
            ),
          ),

          // Bottom status overlay pill
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: _buildBottomStatusPill(currentStory),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryMedia(PetStoryModel story) {
    if (story.mediaUrl.isNotEmpty) {
      return Image.network(
        story.mediaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildFallbackBackground(story),
      );
    }
    return _buildFallbackBackground(story);
  }

  Widget _buildFallbackBackground(PetStoryModel story) {
    return Container(
      color: AppColors.obsidianBackground,
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.obsidianCard,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Icon(
            story.isOfficial ? Icons.pets_rounded : Icons.pets_rounded,
            size: 48,
            color: story.isOfficial ? AppColors.accentBlue : AppColors.accentGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildGradients() {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top subtle dark gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom subtle dark gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: List.generate(widget.stories.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  double value = 0.0;
                  if (index < _currentIndex) {
                    value = 1.0;
                  } else if (index == _currentIndex) {
                    value = _animController.value;
                  } else {
                    value = 0.0;
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: SizedBox(
                      key: ValueKey('story_progress_bar_$index'),
                      height: 3.0,
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withValues(alpha: 0.28),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopHeader(PetStoryModel story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          // Author Avatar
          PawAvatar(
            url: story.authorAvatar,
            radius: 18,
            fallbackColor: story.isOfficial ? AppColors.accentBlue : AppColors.accentGreen,
          ),
          const SizedBox(width: 10),

          // Author Name & District
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        story.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (story.isOfficial) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 15,
                        color: Color(0xFF3B82F6),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        story.district,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            key: const ValueKey('story_close_button'),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
            splashRadius: 20,
            onPressed: _dismiss,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatusPill(PetStoryModel story) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.obsidianCardTranslucent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story.petName != null && story.petName!.isNotEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: story.isOfficial
                          ? AppColors.accentBlue.withValues(alpha: 0.2)
                          : AppColors.accentGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          story.isOfficial ? Icons.verified : Icons.pets_rounded,
                          size: 12,
                          color: story.isOfficial ? AppColors.accentBlue : AppColors.accentGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          story.petName!,
                          style: TextStyle(
                            color: story.isOfficial ? AppColors.accentBlue : AppColors.accentGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              story.statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
