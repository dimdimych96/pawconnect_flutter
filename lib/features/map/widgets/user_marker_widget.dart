import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';

class UserMarkerWidget extends StatefulWidget {
  final String ownerName;
  final String? avatarUrl;
  final VoidCallback onTap;

  const UserMarkerWidget({
    super.key,
    required this.ownerName,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  State<UserMarkerWidget> createState() => _UserMarkerWidgetState();
}

class _UserMarkerWidgetState extends State<UserMarkerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ringColor = AppColors.accentBlue;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ringColor.withValues(alpha: 0.5),
                  blurRadius: _pulseAnimation.value,
                  spreadRadius: _pulseAnimation.value / 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Cyan Glass Ring
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor,
                      width: 2.5,
                    ),
                  ),
                ),
                // Inner Avatar
                PawAvatar(
                  url: widget.avatarUrl,
                  radius: 22,
                  fallbackColor: ringColor,
                ),
                // Badge "Я"
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ringColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Я 📍',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
