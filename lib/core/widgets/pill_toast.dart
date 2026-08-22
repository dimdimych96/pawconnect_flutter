import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Тип уведомления, определяет цвет иконки-плашки.
enum ToastType {
  success,
  info,
  alert,
}

/// Стеклянная «пилюля» - капсула Liquid Glass.
/// Тёмное стекло, тонкая рамка, единственный цветовой акцент - иконка события.
class PillToast extends StatelessWidget {
  final String title;
  final String? subtitle;
  final ToastType type;
  final VoidCallback? onClose;

  const PillToast({
    super.key,
    required this.title,
    this.subtitle,
    this.type = ToastType.success,
    this.onClose,
  });

  Color get _accent {
    switch (type) {
      case ToastType.success:
        return AppColors.accentGreen;
      case ToastType.info:
        return AppColors.accentBlue;
      case ToastType.alert:
        return AppColors.accentRed;
    }
  }

  IconData get _icon {
    switch (type) {
      case ToastType.success:
        return Icons.check_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.alert:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xE1121814),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Круглая иконка-плашка в цвете события
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  color: accent,
                  size: 15,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onClose != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Сервис показа пилюль-тостов поверх всего приложения.
/// Использует корневой Overlay, поэтому тост виден на любом слое.
class PawToast {
  static OverlayEntry? _current;
  static final ValueNotifier<bool> isVisible = ValueNotifier(false);

  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 2),
    double? topOffset,
  }) {
    final overlay = _findOverlay(context);
    if (overlay == null) return;

    _dismiss();

    late OverlayEntry entry;
    var dismissed = false;

    void close() {
      if (dismissed) return;
      dismissed = true;
      isVisible.value = false;
      if (entry.mounted) entry.remove();
      if (_current == entry) _current = null;
    }

    entry = OverlayEntry(
      builder: (context) => _PillToastOverlay(
        topOffset: topOffset,
        toast: PillToast(
          title: title,
          subtitle: subtitle,
          type: type,
          onClose: close,
        ),
        onDismiss: close,
      ),
    );

    _current = entry;
    isVisible.value = true;
    overlay.insert(entry);

    Future.delayed(duration, close);
  }

  static void _dismiss() {
    final entry = _current;
    _current = null;
    if (entry != null && entry.mounted) {
      entry.remove();
    }
    isVisible.value = false;
  }

  static OverlayState? _findOverlay(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    return navigator.context.findAncestorStateOfType<OverlayState>() ??
        Overlay.maybeOf(context);
  }
}

class _PillToastOverlay extends StatefulWidget {
  final PillToast toast;
  final VoidCallback onDismiss;
  final double? topOffset;

  const _PillToastOverlay({
    required this.toast,
    required this.onDismiss,
    this.topOffset,
  });

  @override
  State<_PillToastOverlay> createState() => _PillToastOverlayState();
}

class _PillToastOverlayState extends State<_PillToastOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topOffset ?? 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: widget.topOffset != null ? 8 : 8,
          ),
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 300) {
                widget.onDismiss();
              }
            },
            child: Align(
              alignment: Alignment.center,
              child: widget.toast,
            ),
          ),
        ),
      ),
    );
  }
}
