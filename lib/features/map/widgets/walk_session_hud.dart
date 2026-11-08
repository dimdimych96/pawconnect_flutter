import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../models/walk_session_model.dart';

class WalkSessionHud extends StatefulWidget {
  final WalkSessionModel session;
  final DogTemperament temperament;
  final VoidCallback onStopWalk;

  const WalkSessionHud({
    super.key,
    required this.session,
    required this.temperament,
    required this.onStopWalk,
  });

  @override
  State<WalkSessionHud> createState() => _WalkSessionHudState();
}

class _WalkSessionHudState extends State<WalkSessionHud> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateElapsed();
        });
      }
    });
  }

  void _updateElapsed() {
    final now = DateTime.now();
    final started = widget.session.startedAt.isAfter(now)
        ? now
        : widget.session.startedAt;
    _elapsed = now.difference(started);
    if (_elapsed.isNegative) _elapsed = Duration.zero;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTimer(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = widget.session.walkMode == 'private';
    final isTraining = widget.session.walkMode == 'training';
    final modeColor = isPrivate
        ? const Color(0xFFA78BFA)
        : (isTraining ? const Color(0xFFFBBF24) : AppColors.accentGreen);
    final modeLabel = isPrivate
        ? 'Приватный'
        : (isTraining ? 'Тренировка' : 'Открытый');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.obsidianCardTranslucent,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 1. Live Indicator Beacon (Clean vector icon in temperament color)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.temperament.color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.temperament.color.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.pets_rounded,
                        size: 18,
                        color: widget.temperament.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Pet info and timer
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.session.petName ?? 'Питомец',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: modeColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                modeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: modeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: modeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTimer(_elapsed),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '• На радаре',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 3. Finish Walk Button (38px height comfortable hit target)
                  GestureDetector(
                    onTap: widget.onStopWalk,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stop_rounded,
                            size: 16,
                            color: AppColors.accentRed,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Завершить',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
