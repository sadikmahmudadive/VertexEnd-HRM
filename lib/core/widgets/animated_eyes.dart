import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The gaze / emotion state of the animated eyes.
enum EyesMood {
  /// Watchful privacy mode: looking towards the hidden salary dots, natural blinking.
  watchful,

  /// Active biometric scanning: darting back and forth while verifying Face ID.
  scanning,

  /// Happy revealed state: gazing happily at the visible pay with shiny catchlights.
  happy,
}

/// A delightful, physics-inspired pair of animated cartoon eyes.
/// Features involuntary blinking, micro-saccadic eye tracking,
/// glossy specular catchlights, and adaptive gaze states.
class AnimatedEyes extends StatefulWidget {
  const AnimatedEyes({
    super.key,
    this.mood = EyesMood.watchful,
    this.width = 34,
    this.height = 22,
    this.pupilColor = const Color(0xFF2E1065),
  });

  final EyesMood mood;
  final double width;
  final double height;
  final Color pupilColor;

  @override
  State<AnimatedEyes> createState() => _AnimatedEyesState();
}

class _AnimatedEyesState extends State<AnimatedEyes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: _EyesPainter(
            mood: widget.mood,
            t: _controller.value,
            pupilColor: widget.pupilColor,
          ),
        ),
      ),
    );
  }
}

class _EyesPainter extends CustomPainter {
  _EyesPainter({
    required this.mood,
    required this.t,
    required this.pupilColor,
  });

  final EyesMood mood;
  final double t;
  final Color pupilColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Scale canonical 40x24 coordinates to actual widget size
    canvas.scale(size.width / 40.0, size.height / 24.0);

    // Compute blink factor [0.0 = wide open, 1.0 = fully closed]
    final double blink;
    if (mood == EyesMood.scanning) {
      // Wide open during biometric scan with rare micro-blink
      blink = 0.0;
    } else {
      // Natural blink at the end of the loop (last 12% of duration ~ 430ms)
      if (t < 0.88) {
        blink = 0.0;
      } else {
        final phase = (t - 0.88) / 0.12;
        // Cubic ease in/out for organic eyelid motion
        final p = phase < 0.5 ? phase * 2.0 : (1.0 - phase) * 2.0;
        blink = Curves.easeInOutCubic.transform(p);
      }
    }

    // Compute pupil gaze offset (dx, dy)
    final Offset gaze;
    switch (mood) {
      case EyesMood.watchful:
        // Attentive guard looking left towards the hidden salary dots:
        // subtle micro-saccades make the eyes feel conscious
        if (t < 0.45) {
          // Locked on dots
          gaze = const Offset(-2.4, 0.0);
        } else if (t < 0.70) {
          // Glance up slightly as if wondering
          final p = Curves.easeInOut.transform((t - 0.45) / 0.25);
          gaze = Offset(-2.4 + p * 0.8, -p * 1.0);
        } else if (t < 0.88) {
          // Return gaze to dots
          final p = Curves.easeInOut.transform((t - 0.70) / 0.18);
          gaze = Offset(-1.6 - p * 0.8, -1.0 + p * 1.0);
        } else {
          gaze = const Offset(-2.4, 0.0);
        }

      case EyesMood.scanning:
        // Scanning biometric face left and right
        final scanDx = math.sin(t * math.pi * 10) * 3.2;
        final scanDy = math.cos(t * math.pi * 5) * 1.0;
        gaze = Offset(scanDx, scanDy);

      case EyesMood.happy:
        // Cheerful gaze looking at the revealed amount with gentle breathing
        final floatDx = math.sin(t * math.pi * 2) * 0.6;
        final floatDy = math.cos(t * math.pi * 2) * 0.4;
        gaze = Offset(-1.6 + floatDx, 0.8 + floatDy);
    }

    // Left and Right eye centers in 40x24 space
    const leftCenter = Offset(13.0, 12.0);
    const rightCenter = Offset(27.0, 12.0);

    _drawSingleEye(canvas, leftCenter, gaze, blink, isLeft: true);
    _drawSingleEye(canvas, rightCenter, gaze, blink, isLeft: false);

    canvas.restore();
  }

  void _drawSingleEye(
    Canvas canvas,
    Offset center,
    Offset gaze,
    double blink, {
    required bool isLeft,
  }) {
    const eyeWidth = 10.5;
    const eyeHeight = 15.0;

    // When nearly or fully closed, draw sweet curved resting/smiling arch
    if (blink >= 0.85) {
      final archProgress = ((blink - 0.85) / 0.15).clamp(0.0, 1.0);
      final archPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      final path = Path()
        ..moveTo(center.dx - 4.8, center.dy + 0.5)
        ..quadraticBezierTo(
          center.dx,
          center.dy - 2.8 * archProgress,
          center.dx + 4.8,
          center.dy + 0.5,
        );
      canvas.drawPath(path, archPaint);
      return;
    }

    // Dynamic sclera height during blink
    final currentHeight = math.max(2.5, eyeHeight * (1.0 - blink));
    final cornerRadius = math.min(5.25, currentHeight / 2);

    final scleraRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: eyeWidth,
        height: currentHeight,
      ),
      Radius.circular(cornerRadius),
    );

    // Subtle drop shadow under sclera
    canvas.drawRRect(
      scleraRRect.shift(const Offset(0, 1.2)),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // White Sclera
    canvas.drawRRect(
      scleraRRect,
      Paint()..color = Colors.white,
    );

    // If eye is open enough to reveal pupil
    if (currentHeight > 4.5) {
      canvas.save();
      canvas.clipRRect(scleraRRect);

      // Pupil geometry
      const pupilRadius = 3.2;
      final pupilCenter = Offset(
        center.dx + gaze.dx,
        center.dy + gaze.dy,
      );

      // Dark Iris / Pupil
      canvas.drawCircle(
        pupilCenter,
        pupilRadius,
        Paint()..color = pupilColor,
      );

      // Primary Specular Highlight (top-right catchlight)
      canvas.drawCircle(
        Offset(pupilCenter.dx + 1.1, pupilCenter.dy - 1.1),
        1.1,
        Paint()..color = Colors.white,
      );

      // Secondary Specular Highlight (bottom-left bounce reflection)
      canvas.drawCircle(
        Offset(pupilCenter.dx - 0.9, pupilCenter.dy + 1.0),
        0.65,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );

      // Extra sparkle glint when in happy mode
      if (mood == EyesMood.happy) {
        canvas.drawCircle(
          Offset(pupilCenter.dx + 1.8, pupilCenter.dy + 0.3),
          0.5,
          Paint()..color = const Color(0xFFFEF08A),
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EyesPainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.t != t ||
      oldDelegate.pupilColor != pupilColor;
}

