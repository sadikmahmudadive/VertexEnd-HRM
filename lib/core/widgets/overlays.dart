import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'components.dart';

OverlayEntry? _toast;

/// Floating toast above the dock. Auto-dismisses after 4 seconds.
void showHrmToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  double bottom = 104,
}) {
  _toast?.remove();
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: Sp.s4,
      right: Sp.s4,
      bottom: bottom,
      child: Material(
        color: Colors.transparent,
        child: _ToastBody(
          message: message,
          actionLabel: actionLabel,
          onAction: () {
            onAction?.call();
            if (entry.mounted) entry.remove();
          },
          onDone: () {
            if (entry.mounted) entry.remove();
          },
        ),
      ),
    ),
  );
  _toast = entry;
  overlay.insert(entry);
  HapticFeedback.lightImpact();
}

class _ToastBody extends StatefulWidget {
  const _ToastBody({
    required this.message,
    required this.onDone,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDone;

  @override
  State<_ToastBody> createState() => _ToastBodyState();
}

class _ToastBodyState extends State<_ToastBody> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.s4, vertical: Sp.s2),
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        color: c.textPrimary,
        borderRadius: Rd.rMd,
        boxShadow: const [
          BoxShadow(color: Color(0x290F172A), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.check, size: 20, color: c.bgSurface),
          const SizedBox(width: Sp.s3),
          Expanded(
              child: Text(widget.message, style: T.label.col(c.bgSurface))),
          if (widget.actionLabel != null)
            GestureDetector(
              onTap: widget.onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(Sp.s2),
                child: Text(widget.actionLabel!,
                    style: T.label
                        .weight(FontWeight.w600)
                        .col(c.bgSurface)
                        .copyWith(decoration: TextDecoration.underline)),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.5, end: 0, duration: 450.ms, curve: Motion.standard);
  }
}

/// Confirmation dialog for destructive or irreversible actions.
Future<bool> showHrmConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = true,
}) async {
  final res = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: Sz.scrimOpacity),
    transitionDuration: Motion.slow,
    pageBuilder: (ctx, a, b) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      final c = ctx.c;
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.88, end: 1.0).animate(curved),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(Sp.s6),
              child: Material(
                color: c.bgSurfaceRaised,
                borderRadius: Rd.rXl,
                child: Padding(
                  padding: const EdgeInsets.all(Sp.s6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: T.h3.col(c.textPrimary)),
                      const SizedBox(height: Sp.s3),
                      Text(message, style: T.body.col(c.textSecondary)),
                      const SizedBox(height: Sp.s6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          HrmButton(cancelLabel,
                              kind: BtnKind.outline,
                              size: BtnSize.md,
                              expand: false,
                              onPressed: () => Navigator.of(ctx).pop(false)),
                          const SizedBox(width: Sp.s3),
                          HrmButton(confirmLabel,
                              kind: destructive ? BtnKind.danger : BtnKind.primary,
                              size: BtnSize.md,
                              expand: false,
                              onPressed: () => Navigator.of(ctx).pop(true)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  return res ?? false;
}
