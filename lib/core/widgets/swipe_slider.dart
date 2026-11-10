import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Modern, physics-based swipe-to-confirm slider.
/// Features a dynamic progress fill, shimmering label, gentle harmonic breathing
/// arrow, tactile thumb scaling, and smooth easing snap-back and completion.
class SwipeToConfirm extends StatefulWidget {
  const SwipeToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.confirming = false,
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool confirming;

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm>
    with TickerProviderStateMixin {
  static const double _thumb = 48;
  static const double _inset = 4;
  static const double _height = 56;
  static const double _confirmThreshold = 0.72;

  late final AnimationController _dragController;
  late final AnimationController _shimmerController;
  bool _dragging = false;
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.confirming ? 1.0 : 0.0,
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant SwipeToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.confirming != oldWidget.confirming) {
      if (widget.confirming) {
        _dragController.animateTo(1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic);
      } else {
        _dragController.animateTo(0.0,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic);
      }
    }
  }

  @override
  void dispose() {
    _dragController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.confirming) return;
    HapticFeedback.mediumImpact();
    _dragController.animateTo(1.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic);
    widget.onConfirmed();
  }

  void _onDragStart(DragStartDetails _) {
    if (widget.confirming) return;
    setState(() {
      _dragging = true;
      _hapticTriggered = false;
    });
  }

  void _onDragUpdate(DragUpdateDetails d, double travel) {
    if (widget.confirming || travel <= 0) return;
    final next = (_dragController.value + (d.delta.dx / travel)).clamp(0.0, 1.0);
    _dragController.value = next;

    if (next >= _confirmThreshold && !_hapticTriggered) {
      _hapticTriggered = true;
      HapticFeedback.selectionClick();
    } else if (next < _confirmThreshold) {
      _hapticTriggered = false;
    }
  }

  void _onDragEnd(DragEndDetails d, double travel) {
    if (widget.confirming) return;
    setState(() => _dragging = false);

    final velocity = d.primaryVelocity ?? 0.0;
    final passedThreshold = _dragController.value >= _confirmThreshold;
    final fastFling = velocity > 450;

    if (passedThreshold || fastFling) {
      HapticFeedback.mediumImpact();
      _dragController
          .animateTo(1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic)
          .then((_) {
        widget.onConfirmed();
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted && !widget.confirming) {
            _dragController.animateTo(0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic);
          }
        });
      });
    } else {
      HapticFeedback.lightImpact();
      _dragController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 320),
        curve: const Cubic(0.18, 0.9, 0.2, 1.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return LayoutBuilder(builder: (context, box) {
      final travel = math.max(0.0, box.maxWidth - _thumb - _inset * 2);

      return Semantics(
        button: true,
        label: widget.label,
        onTap: widget.confirming ? null : _onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.confirming ? null : _onTap,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, travel),
          onHorizontalDragEnd: (d) => _onDragEnd(d, travel),
          child: AnimatedBuilder(
            animation: Listenable.merge([_dragController, _shimmerController]),
            builder: (context, _) {
              final progress = _dragController.value;
              final pos = travel * progress;
              final shimmer = _shimmerController.value;
              final isDone = progress >= 0.9 || widget.confirming;

              // Gentle harmonic breathing offset for idle state
              final breathingNudge =
                  _dragging || isDone ? 0.0 : math.sin(shimmer * math.pi * 2) * 3.5;

              return Container(
                height: _height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.24),
                      Colors.white.withValues(alpha: 0.14),
                    ],
                  ),
                  borderRadius: Rd.rFull,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Dynamic progress fill track that grows as you swipe
                    if (progress > 0.005)
                      Positioned(
                        left: _inset,
                        top: _inset,
                        bottom: _inset,
                        width: math.max(_thumb, _thumb + pos),
                        child: Opacity(
                          opacity: (progress * 3.0).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.38),
                                  Colors.white.withValues(alpha: 0.20),
                                ],
                              ),
                              borderRadius: Rd.rFull,
                            ),
                          ),
                        ),
                      ),

                    // Centered shimmering prompt text
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _thumb),
                        child: Opacity(
                          opacity: (1.0 - (progress * 1.6)).clamp(0.0, 1.0),
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) {
                              final shift = shimmer * 1.6 - 0.3;
                              final s1 = (shift - 0.25).clamp(0.0, 1.0);
                              final s2 = shift.clamp(0.0, 1.0);
                              final s3 = (shift + 0.25).clamp(0.0, 1.0);
                              return LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.72),
                                  Colors.white,
                                  Colors.white.withValues(alpha: 0.72),
                                ],
                                stops: [s1, s2, s3],
                              ).createShader(bounds);
                            },
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: T.label.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Chevrons hint that fades as slider moves
                    Positioned(
                      right: 18,
                      child: Opacity(
                        opacity: (1.0 - (progress * 2.5)).clamp(0.0, 0.45),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: Colors.white.withValues(
                                  alpha: 0.3 + 0.3 * math.sin(shimmer * math.pi * 2).abs()),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: Colors.white.withValues(
                                  alpha: 0.5 + 0.4 * math.sin(shimmer * math.pi * 2).abs()),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tactile Thumb
                    Positioned(
                      left: _inset + pos,
                      top: _inset,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutCubic,
                        scale: _dragging ? 1.05 : 1.0,
                        child: Container(
                          width: _thumb,
                          height: _thumb,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 3,
                                offset: const Offset(0, -1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              transitionBuilder: (child, anim) => ScaleTransition(
                                scale: anim,
                                child: FadeTransition(opacity: anim, child: child),
                              ),
                              child: isDone
                                  ? Icon(
                                      LucideIcons.check,
                                      key: const ValueKey('check'),
                                      size: 24,
                                      color: c.heroFrom,
                                    )
                                  : Transform.translate(
                                      key: const ValueKey('arrow'),
                                      offset: Offset(breathingNudge, 0),
                                      child: Icon(
                                        LucideIcons.arrowRight,
                                        size: 24,
                                        color: c.heroFrom,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
