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
          borderRadius: BorderRadius.circular(22.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFF141416).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(
                  color: modeColor.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: modeColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 1. Live Indicator Beacon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: modeColor.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.temperament.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

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
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: modeColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                modeLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: modeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
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
                            const SizedBox(width: 5),
                            Text(
                              _formatTimer(_elapsed),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '• На радаре',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 3. Finish Walk Button
                  GestureDetector(
                    onTap: widget.onStopWalk,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stop_rounded,
                            size: 14,
                            color: AppColors.accentRed,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Завершить',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
