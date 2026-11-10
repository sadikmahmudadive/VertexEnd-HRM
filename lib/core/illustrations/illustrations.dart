import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/typography.dart';

/// Flat, rounded illustrations drawn in code with the brand palette.
class OnboardingArt extends StatefulWidget {
  const OnboardingArt({super.key, required this.scene});
  final int scene;

  @override
  State<OnboardingArt> createState() => _OnboardingArtState();
}

class _OnboardingArtState extends State<OnboardingArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AspectRatio(
      aspectRatio: 300 / 260,
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (context, _) => CustomPaint(
          painter: _ScenePainter(widget.scene, c, _ctl.value),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.c, this.t);
  final int scene;
  final HrmColors c;
  final double t;

  double get _wave => math.sin(t * math.pi * 2);
  double _bob(double phase) => math.sin((t + phase) * math.pi * 2) * 5;

  @override
  void paint(Canvas cv, Size size) {
    cv.save();
    cv.scale(size.width / 300, size.height / 260);
    _fillCircle(cv, const Offset(150, 132), 112, c.primary50);
    switch (scene) {
      case 0:
        _clockScene(cv);
      case 1:
        _leaveScene(cv);
      default:
        _payScene(cv);
    }
    cv.restore();
  }

  Paint _fill(Color col) => Paint()..color = col;
  Paint _stroke(Color col, double w) => Paint()
    ..color = col
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _fillCircle(Canvas cv, Offset o, double r, Color col) =>
      cv.drawCircle(o, r, _fill(col));

  void _rr(Canvas cv, double x, double y, double w, double h, double r, Paint p) =>
      cv.drawRRect(RRect.fromLTRBR(x, y, x + w, y + h, Radius.circular(r)), p);

  void _clockScene(Canvas cv) {
    cv.save();
    cv.translate(0, _wave * -6);
    _rr(cv, 96, 36, 108, 192, 24, _fill(c.bgSurface));
    _rr(cv, 96, 36, 108, 192, 24, _stroke(c.borderStrong, 2));
    _rr(cv, 126, 48, 48, 8, 4, _fill(c.bgSubtle));
    const ring = Offset(150, 116);
    cv.drawCircle(ring, 38, _stroke(c.borderDefault, 8));
    cv.drawArc(Rect.fromCircle(center: ring, radius: 38), -math.pi / 2,
        math.pi * 1.5, false, _stroke(c.primary500, 8));
    final hands = Path()
      ..moveTo(150, 98)
      ..lineTo(150, 116)
      ..lineTo(162, 124);
    cv.drawPath(hands, _stroke(c.textPrimary, 5));
    _rr(cv, 112, 180, 76, 28, 14, _fill(c.bgSubtle));
    final nudge = math.max(0.0, math.sin(t * math.pi * 2 * 1.5)) * 7;
    _fillCircle(cv, Offset(126 + nudge, 194), 11, c.primary500);
    final arrow = Path()
      ..moveTo(122 + nudge, 194)
      ..lineTo(130 + nudge, 194)
      ..moveTo(127 + nudge, 191)
      ..lineTo(130 + nudge, 194)
      ..lineTo(127 + nudge, 197);
    cv.drawPath(arrow, _stroke(c.textOnPrimary, 2));
    _rr(cv, 140, 191, 34, 6, 3, _fill(c.borderStrong));
    cv.restore();
    // confirmed badge
    _fillCircle(cv, const Offset(204, 84), 17, c.success);
    final tick = Path()
      ..moveTo(196, 84)
      ..lineTo(201.5, 89.5)
      ..lineTo(212, 78);
    cv.drawPath(tick, _stroke(Colors.white, 3.5));
    // geofence pin with ripple
    final rip = (t * 2) % 1;
    cv.drawCircle(
        const Offset(244, 150),
        9 + rip * 14,
        _stroke(c.secondary500.withValues(alpha: (1 - rip) * 0.7), 2));
    _fillCircle(cv, const Offset(244, 150), 9, c.secondary500);
    // floating bits
    _fillCircle(cv, Offset(52, 88 + _bob(0)), 9, c.heroTo);
    _rr(cv, 236, 196 + _bob(.3), 16, 16, 5, _fill(HrmColors.leaveWfh));
    _plus(cv, 62, 193 + _bob(.6));
    _fillCircle(cv, Offset(70, 140 + _bob(.8)), 5, c.secondary500);
  }

  void _plus(Canvas cv, double x, double y) {
    final p = Path()
      ..moveTo(x, y - 7)
      ..lineTo(x, y + 7)
      ..moveTo(x - 7, y)
      ..lineTo(x + 7, y);
    cv.drawPath(p, _stroke(HrmColors.primary400, 3));
  }

  void _leaveScene(Canvas cv) {
    _fillCircle(cv, Offset(236, 66 + _bob(0)), 22, HrmColors.leaveWfh);
    cv.drawOval(const Rect.fromLTWH(44, 197, 184, 34),
        _fill(c.secondary500.withValues(alpha: 0.4)));
    final trunk = Path()
      ..moveTo(126, 214)
      ..relativeCubicTo(6, -40, 4, -70, 14, -104);
    cv.drawPath(trunk, _stroke(c.textSecondary, 8));
    cv.save();
    cv.translate(140, 110);
    cv.rotate(_wave * 0.05);
    cv.translate(-140, -110);
    void leaf(List<double> a, Color col) {
      final p = Path()
        ..moveTo(140, 110)
        ..relativeCubicTo(a[0], a[1], a[2], a[3], a[4], a[5])
        ..relativeCubicTo(a[6], a[7], a[8], a[9], a[10], a[11])
        ..close();
      cv.drawPath(p, _fill(col));
    }

    leaf([-26, -26, -58, -20, -72, 0, 26, -8, 46, -6, 72, 0], c.secondary500);
    leaf([26, -26, 58, -20, 72, 0, -26, -8, -46, -6, -72, 0], c.secondary500);
    leaf([-14, -34, -44, -42, -64, -30, 22, 2, 42, 14, 64, 30],
        HrmColors.leaveParental);
    leaf([14, -34, 44, -42, 64, -30, -22, 2, -42, 14, -64, 30],
        HrmColors.leaveParental);
    leaf([-6, -26, 0, -46, 12, -56, 2, 22, -2, 40, -12, 56], c.secondary500);
    cv.restore();
    // calendar card
    cv.save();
    cv.translate(0, _wave * -5);
    _rr(cv, 170, 112, 100, 112, 18, _fill(c.bgSurface));
    _rr(cv, 170, 112, 100, 112, 18, _stroke(c.borderStrong, 2));
    cv.save();
    cv.clipRRect(RRect.fromLTRBR(170, 112, 270, 224, const Radius.circular(18)));
    cv.drawRect(const Rect.fromLTWH(170, 112, 100, 24), _fill(c.primary500));
    cv.restore();
    _rr(cv, 182, 156, 76, 22, 11, _fill(HrmColors.primary100));
    for (final o in const [
      Offset(190, 167), Offset(238, 167), Offset(190, 198),
      Offset(214, 198), Offset(238, 198),
    ]) {
      _fillCircle(cv, o, 3, c.borderStrong);
    }
    _fillCircle(cv, const Offset(206, 167), 4, c.primary500);
    _fillCircle(cv, const Offset(222, 167), 4, c.primary500);
    cv.restore();
    // balance ring
    cv.save();
    cv.translate(0, math.sin((t + .3) * math.pi * 2) * -5);
    _fillCircle(cv, const Offset(60, 168), 30, c.bgSurface);
    cv.drawCircle(const Offset(60, 168), 30, _stroke(c.borderDefault, 2));
    cv.drawCircle(const Offset(60, 168), 22, _stroke(c.borderDefault, 7));
    cv.drawArc(Rect.fromCircle(center: const Offset(60, 168), radius: 22),
        -math.pi / 2, math.pi * 2 * (2 / 3), false,
        _stroke(HrmColors.leaveAnnual, 7));
    final tp = TextPainter(
      text: TextSpan(
          text: '8', style: T.h3.copyWith(color: c.textPrimary, fontSize: 17)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(cv, Offset(60 - tp.width / 2, 168 - tp.height / 2));
    cv.restore();
    _plus(cv, 70, 77 + _bob(.4));
  }

  void _payScene(Canvas cv) {
    cv.save();
    cv.translate(0, _wave * -6);
    final card = RRect.fromLTRBR(64, 64, 236, 176, const Radius.circular(22));
    cv.drawRRect(
        card,
        Paint()
          ..shader = LinearGradient(colors: [c.heroFrom, c.heroTo])
              .createShader(card.outerRect));
    _rr(cv, 82, 82, 52, 8, 4, _fill(Colors.white.withValues(alpha: 0.7)));
    for (var i = 0; i < 5; i++) {
      _fillCircle(cv, Offset(90 + i * 18.0, 122), 5, Colors.white);
    }
    // eye
    final eye = Path()
      ..moveTo(200, 114)
      ..cubicTo(210, 105, 222, 105, 232, 114)
      ..cubicTo(222, 123, 210, 123, 200, 114);
    cv.drawPath(eye, _stroke(Colors.white, 3));
    _fillCircle(cv, const Offset(216, 114), 3.5, Colors.white);
    _rr(cv, 82, 148, 84, 8, 4, _fill(Colors.white.withValues(alpha: 0.45)));
    cv.restore();
    // lock badge
    _fillCircle(cv, const Offset(236, 178), 26, c.bgSurface);
    cv.drawCircle(const Offset(236, 178), 26, _stroke(c.borderDefault, 2));
    _rr(cv, 226, 176, 20, 16, 4, _fill(c.primary500));
    final shackle = Path()
      ..moveTo(230, 176)
      ..lineTo(230, 171)
      ..arcToPoint(const Offset(242, 171), radius: const Radius.circular(6))
      ..lineTo(242, 176);
    cv.drawPath(shackle, _stroke(c.primary500, 3.5));
    // coins
    for (var i = 0; i < 3; i++) {
      _rr(cv, 60 + (i == 1 ? 6 : (i == 2 ? 2 : 0)), 196 + i * 16.0 + _bob(i * .2),
          58, 13, 6.5, _fill(HrmColors.leaveWfh));
    }
    // bars
    for (var i = 0; i < 3; i++) {
      final h = [22.0, 34.0, 48.0][i];
      final grow = Curves.easeOutCubic.transform(((t * 3 + i * .15) % 1).clamp(0, 1));
      final hh = h * (0.6 + 0.4 * grow);
      _rr(cv, 150 + i * 20.0, 236 - hh, 14, hh, 5, _fill(c.secondary500));
    }
    _plus(cv, 44, 127 + _bob(.5));
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.t != t || old.c != c || old.scene != scene;
}

/// Big drawn check badge with ripples and a confetti burst.
class SuccessBadge extends StatelessWidget {
  const SuccessBadge({super.key});

  static const _pieces = <(double, double, double, double, bool, int)>[
    (-120, -86, 220, 12, false, 0), (-72, -124, -160, 9, true, 1),
    (20, -132, 140, 14, false, 2), (96, -100, -200, 10, true, 3),
    (134, -30, 260, 12, false, 4), (126, 56, -120, 9, true, 0),
    (70, 120, 190, 13, false, 1), (-18, 128, -240, 10, true, 2),
    (-92, 100, 150, 12, false, 3), (-134, 26, -210, 9, true, 4),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final palette = [c.heroTo, HrmColors.leaveWfh, c.secondary500, c.primary500, HrmColors.leaveSick];
    return SizedBox(
      width: 300,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 2; i++)
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.success, width: 2)),
            )
                .animate(
                    delay: (900 + i * 800).ms,
                    onPlay: (ctl) => ctl.repeat())
                .scale(
                    begin: const Offset(.7, .7),
                    end: const Offset(1.9, 1.9),
                    duration: 2400.ms,
                    curve: Curves.easeOut)
                .fadeOut(duration: 2400.ms, begin: .5),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(color: c.success, shape: BoxShape.circle),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: 900.ms,
              curve: Curves.easeInOut,
              builder: (context, v, _) => CustomPaint(painter: _TickPainter(v)),
            ),
          ).animate().scale(
              begin: const Offset(.5, .5),
              end: const Offset(1, 1),
              duration: 700.ms,
              curve: Curves.easeOutBack),
          for (final p in _pieces)
            Container(
              width: p.$4,
              height: p.$4,
              decoration: BoxDecoration(
                color: palette[p.$6],
                shape: p.$5 ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: p.$5 ? null : BorderRadius.circular(3),
              ),
            )
                .animate(delay: 550.ms)
                .scale(
                    begin: const Offset(.2, .2),
                    end: const Offset(1, 1),
                    duration: 300.ms)
                .move(
                    begin: Offset.zero,
                    end: Offset(p.$1, p.$2),
                    duration: 1500.ms,
                    curve: Curves.easeOutCubic)
                .rotate(end: p.$3 / 360, duration: 1500.ms)
                .fadeOut(delay: 700.ms, duration: 800.ms),
        ],
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.v);
  final double v;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    final path = Path()
      ..moveTo(16 * s, 33 * s)
      ..lineTo(27 * s, 44 * s)
      ..lineTo(49 * s, 20 * s);
    final metric = path.computeMetrics().first;
    final start = ((v - 0.35) / 0.65).clamp(0.0, 1.0);
    canvas.drawPath(
      metric.extractPath(0, metric.length * start),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_TickPainter old) => old.v != v;
}

/// Empty-inbox illustration (all caught up).
class InboxArt extends StatelessWidget {
  const InboxArt({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: 260,
      height: 190,
      child: CustomPaint(painter: _InboxPainter(c)),
    )
        .animate(onPlay: (ctl) => ctl.repeat(reverse: true))
        .moveY(begin: 0, end: -6, duration: 2500.ms, curve: Curves.easeInOut);
  }
}

class _InboxPainter extends CustomPainter {
  _InboxPainter(this.c);
  final HrmColors c;

  @override
  void paint(Canvas cv, Size size) {
    cv.scale(size.width / 300, size.height / 220);
    final fill = Paint()..color = c.primary50;
    cv.drawCircle(const Offset(150, 112), 96, fill);
    final tray = Path()
      ..moveTo(82, 120)
      ..lineTo(104, 82)
      ..quadraticBezierTo(108, 77, 113, 77)
      ..lineTo(187, 77)
      ..quadraticBezierTo(192, 77, 196, 82)
      ..lineTo(218, 120)
      ..lineTo(218, 164)
      ..quadraticBezierTo(218, 178, 204, 178)
      ..lineTo(96, 178)
      ..quadraticBezierTo(82, 178, 82, 164)
      ..close();
    cv.drawPath(tray, Paint()..color = c.bgSurface);
    final line = Paint()
      ..color = c.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    cv.drawPath(tray, line);
    final slot = Path()
      ..moveTo(82, 120)
      ..lineTo(132, 120)
      ..quadraticBezierTo(140, 120, 140, 128)
      ..arcToPoint(const Offset(160, 128), radius: const Radius.circular(10), clockwise: false)
      ..quadraticBezierTo(160, 120, 168, 120)
      ..lineTo(218, 120);
    cv.drawPath(slot, line);
    cv.drawCircle(const Offset(150, 94), 20, Paint()..color = c.success);
    final tick = Path()
      ..moveTo(140, 95)
      ..lineTo(147, 102)
      ..lineTo(161, 87);
    cv.drawPath(
        tick,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    cv.drawCircle(const Offset(68, 60), 8, Paint()..color = c.heroTo);
    cv.drawRRect(
        RRect.fromLTRBR(226, 52, 242, 68, const Radius.circular(5)),
        Paint()..color = HrmColors.leaveWfh);
    cv.drawCircle(const Offset(240, 146), 6, Paint()..color = c.secondary500);
  }

  @override
  bool shouldRepaint(_InboxPainter old) => old.c != c;
}

/// Ambient floating sparkles and subtle contour rings for Hero cards.
class HeroCardDecorations extends StatelessWidget {
  const HeroCardDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _HeroDecorationsPainter(),
        ),
      ),
    );
  }
}

class _HeroDecorationsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Faint concentric arcs on top right
    canvas.drawCircle(Offset(size.width + 20, -10), 120, strokePaint);
    canvas.drawCircle(Offset(size.width + 20, -10), 170, strokePaint);

    // Faint sparkle stars in background
    void drawTinyCross(Offset pos, double r) {
      final p = Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(pos.dx - r, pos.dy), Offset(pos.dx + r, pos.dy), p);
      canvas.drawLine(Offset(pos.dx, pos.dy - r), Offset(pos.dx, pos.dy + r), p);
    }

    drawTinyCross(const Offset(32, 28), 3.5);
    drawTinyCross(Offset(size.width - 50, 48), 4);
    drawTinyCross(Offset(size.width - 36, size.height - 40), 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Time-of-day periods that drive the dynamic shift illustration.
enum ShiftTimeOfDay {
  morning,   // 5:00 AM – 11:59 AM
  afternoon, // 12:00 PM – 4:59 PM
  evening,   // 5:00 PM – 7:59 PM
  night,     // 8:00 PM – 4:59 AM
}

/// Automatically resolves the current time of day period.
ShiftTimeOfDay resolveShiftTimeOfDay([DateTime? time]) {
  final hour = (time ?? DateTime.now()).hour;
  if (hour >= 5 && hour < 12) return ShiftTimeOfDay.morning;
  if (hour >= 12 && hour < 17) return ShiftTimeOfDay.afternoon;
  if (hour >= 17 && hour < 20) return ShiftTimeOfDay.evening;
  return ShiftTimeOfDay.night;
}

/// Animated vector illustration for the Hero Clock Card that adapts smoothly
/// to the current shift state AND the time of day:
/// - Morning: Rising sunrise, morning desk clock, fresh steaming coffee
/// - Afternoon: High golden sun, desk clock, fresh desktop plant
/// - Evening: Setting sunset glow, evening clock, wind-down tea
/// - Night: Glowing crescent moon with halo, night clock, starry constellation
/// - Working: Pulsing emerald focus core with orbiting satellite beacon
/// - Break: Cozy break mug with floating steam and relaxation moon
class ShiftIllustration extends StatefulWidget {
  const ShiftIllustration({
    super.key,
    required this.phase,
    this.timeOfDay,
    this.size = 52,
  });

  final ClockPhase phase;
  final ShiftTimeOfDay? timeOfDay;
  final double size;

  @override
  State<ShiftIllustration> createState() => _ShiftIllustrationState();
}

class _ShiftIllustrationState extends State<ShiftIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tod = widget.timeOfDay ?? resolveShiftTimeOfDay();
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, _) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ShiftPainter(widget.phase, tod, _ctl.value),
        ),
      ),
    );
  }
}

class _ShiftPainter extends CustomPainter {
  _ShiftPainter(this.phase, this.timeOfDay, this.t);

  final ClockPhase phase;
  final ShiftTimeOfDay timeOfDay;
  final double t;

  @override
  void paint(Canvas cv, Size size) {
    cv.save();
    cv.scale(size.width / 60, size.height / 60);

    switch (phase) {
      case ClockPhase.idle:
      case ClockPhase.confirming:
        switch (timeOfDay) {
          case ShiftTimeOfDay.morning:
            _drawMorningScene(cv);
          case ShiftTimeOfDay.afternoon:
            _drawAfternoonScene(cv);
          case ShiftTimeOfDay.evening:
            _drawEveningScene(cv);
          case ShiftTimeOfDay.night:
            _drawNightScene(cv);
        }
      case ClockPhase.working:
        _drawWorkingScene(cv);
      case ClockPhase.onBreak:
        _drawBreakScene(cv);
    }

    cv.restore();
  }

  void _drawSparkle(Canvas cv, Offset pos, double radius, double alpha) {
    if (alpha <= 0.05) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(pos.dx, pos.dy - radius)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx + radius, pos.dy)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy + radius)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx - radius, pos.dy)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy - radius)
      ..close();
    cv.drawPath(path, paint);
  }

  void _drawClockBase(Canvas cv, {required Offset hourHandTo, required Offset minuteHandTo}) {
    // Twin bell top striker / handle arch
    final bellHandle = Path()
      ..moveTo(20, 16)
      ..quadraticBezierTo(24, 12, 28, 16);
    cv.drawPath(
      bellHandle,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // Twin Bells with subtle metallic sheen
    cv.drawCircle(const Offset(16.5, 17.5), 3.5, Paint()..color = Colors.white.withValues(alpha: 0.92));
    cv.drawCircle(const Offset(31.5, 17.5), 3.5, Paint()..color = Colors.white.withValues(alpha: 0.92));

    // Legs
    final legPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    cv.drawLine(const Offset(18, 44), const Offset(15, 48), legPaint);
    cv.drawLine(const Offset(30, 44), const Offset(33, 48), legPaint);

    // Clock Body Drop Shadow
    const clockCenter = Offset(24, 32);
    cv.drawCircle(
      const Offset(24, 33.5),
      16,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    // Clock Body Face
    cv.drawCircle(
      clockCenter,
      16,
      Paint()..color = Colors.white,
    );
    cv.drawCircle(
      clockCenter,
      16,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Inner subtle bezel inset
    cv.drawCircle(
      clockCenter,
      14.5,
      Paint()
        ..color = const Color(0xFFF8FAFC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // 4 Cardinal hour dot ticks
    final dotPaint = Paint()..color = const Color(0xFF94A3B8);
    cv.drawCircle(const Offset(24, 19.5), 0.9, dotPaint);
    cv.drawCircle(const Offset(36.5, 32), 0.9, dotPaint);
    cv.drawCircle(const Offset(24, 44.5), 0.9, dotPaint);
    cv.drawCircle(const Offset(11.5, 32), 0.9, dotPaint);

    // Clock Hands (brand indigo)
    final handPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    cv.drawLine(clockCenter, hourHandTo, handPaint);
    cv.drawLine(clockCenter, minuteHandTo, handPaint);

    // Center pivot with white glint
    cv.drawCircle(clockCenter, 2.2, Paint()..color = const Color(0xFF4338CA));
    cv.drawCircle(clockCenter, 0.7, Paint()..color = Colors.white);
  }

  void _drawMug(
    Canvas cv, {
    required Color liquidColor,
    double yOffset = 0.0,
    double steamIntensity = 1.0,
  }) {
    // 1. Soft drop shadow separating mug from clock
    final shadowRRect = RRect.fromLTRBR(
      38,
      34.5 + yOffset,
      49,
      46.5 + yOffset,
      const Radius.circular(3.5),
    );
    cv.drawRRect(shadowRRect, Paint()..color = Colors.black.withValues(alpha: 0.16));

    // 2. Ceramic Mug Body with distinct 1px border
    final mugRRect = RRect.fromLTRBR(
      38,
      33.5 + yOffset,
      49,
      45.5 + yOffset,
      const Radius.circular(3.5),
    );
    cv.drawRRect(mugRRect, Paint()..color = Colors.white);
    cv.drawRRect(
      mugRRect,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 3. Top rim & liquid
    cv.drawOval(
      Rect.fromLTWH(38, 32 + yOffset, 11, 3.8),
      Paint()..color = const Color(0xFFF1F5F9),
    );
    cv.drawOval(
      Rect.fromLTWH(39, 32.8 + yOffset, 9, 2.4),
      Paint()..color = liquidColor,
    );
    // Foam / crema glint
    cv.drawCircle(
      Offset(43.5, 34 + yOffset),
      0.7,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    // 4. Mug handle
    final handlePath = Path()
      ..moveTo(49, 35.5 + yOffset)
      ..arcToPoint(
        Offset(49, 43 + yOffset),
        radius: const Radius.circular(4.5),
        clockwise: true,
      );
    cv.drawPath(
      handlePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
    cv.drawPath(
      handlePath,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round,
    );

    // 5. Dual animated rising steam wisps
    if (steamIntensity > 0) {
      for (var i = 0; i < 2; i++) {
        final shift = (t * 1.5 + i * 0.45) % 1.0;
        final alpha = (1.0 - shift) * 0.75 * steamIntensity;
        final sx = 41.5 + i * 4.0;
        final steamPath = Path()
          ..moveTo(sx + math.sin((t + i * 0.3) * math.pi * 2) * 1.5, 31 + yOffset - shift * 12)
          ..quadraticBezierTo(
            sx - 2,
            26 + yOffset - shift * 12,
            sx + 1.5,
            21 + yOffset - shift * 12,
          );
        cv.drawPath(
          steamPath,
          Paint()
            ..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _drawMorningScene(Canvas cv) {
    // 1. Gentle rising dawn sun with warm pulsing corona
    final sunPulse = math.sin(t * math.pi * 2) * 1.5;
    const sunCenter = Offset(40, 16);

    // Warm radial corona glow
    cv.drawCircle(
      sunCenter,
      14.5 + sunPulse * 0.8,
      Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.26),
    );
    // Sun golden outer ring
    cv.drawCircle(
      sunCenter,
      11.5 + sunPulse * 0.3,
      Paint()..color = const Color(0xFFF59E0B),
    );
    // Sun bright core
    cv.drawCircle(
      sunCenter,
      9.5,
      Paint()..color = const Color(0xFFFDE047),
    );

    // 6 Radiating sunbeams with harmonic breathing
    final rayPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: (0.7 + sunPulse * 0.15).clamp(0.0, 1.0))
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (math.pi / 6);
      final r1 = 13.0 + sunPulse * 0.5;
      final r2 = 17.0 + sunPulse;
      cv.drawLine(
        Offset(sunCenter.dx + math.cos(angle) * r1, sunCenter.dy + math.sin(angle) * r1),
        Offset(sunCenter.dx + math.cos(angle) * r2, sunCenter.dy + math.sin(angle) * r2),
        rayPaint,
      );
    }

    // 2. Modern twin-bell desk alarm clock pointing to 9:00 AM (shift start)
    _drawClockBase(cv, hourHandTo: const Offset(17.5, 32), minuteHandTo: const Offset(24, 21));

    // 3. Fresh morning coffee cup with steaming espresso
    _drawMug(cv, liquidColor: const Color(0xFF78350F));

    // 4. Twinkling morning sparkles
    _drawSparkle(cv, const Offset(9, 17), 3.5, 0.45 + 0.4 * math.sin(t * math.pi * 2));
    _drawSparkle(cv, const Offset(53, 27), 2.8, 0.4 + 0.4 * math.sin((t + 0.5) * math.pi * 2));
  }

  void _drawAfternoonScene(Canvas cv) {
    // 1. High radiant midday sun
    final sunPulse = math.sin(t * math.pi * 2) * 1.4;
    const sunCenter = Offset(40, 15);

    // Outer corona glow
    cv.drawCircle(
      sunCenter,
      15.5 + sunPulse * 0.9,
      Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.28),
    );
    // Sun core
    cv.drawCircle(
      sunCenter,
      11.8 + sunPulse * 0.3,
      Paint()..color = const Color(0xFFF59E0B),
    );
    cv.drawCircle(
      sunCenter,
      9.8,
      Paint()..color = const Color(0xFFFDE047),
    );

    // 8 expanding afternoon rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: (0.75 + sunPulse * 0.15).clamp(0.0, 1.0))
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final r1 = 13.5 + sunPulse * 0.5;
      final r2 = 17.5 + sunPulse;
      cv.drawLine(
        Offset(sunCenter.dx + math.cos(angle) * r1, sunCenter.dy + math.sin(angle) * r1),
        Offset(sunCenter.dx + math.cos(angle) * r2, sunCenter.dy + math.sin(angle) * r2),
        rayPaint,
      );
    }

    // 2. Desk clock pointing to ~2:00 PM
    _drawClockBase(cv, hourHandTo: const Offset(29.5, 27.5), minuteHandTo: const Offset(24, 21));

    // 3. Desktop Succulent / Plant in ceramic pot with shadow
    cv.drawRRect(
      RRect.fromLTRBR(39, 36.5, 48.5, 46.5, const Radius.circular(2.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );
    final potRRect = RRect.fromLTRBR(39, 35.5, 48.5, 45.5, const Radius.circular(2.5));
    cv.drawRRect(potRRect, Paint()..color = Colors.white);
    cv.drawRRect(
      potRRect,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    // Soil
    cv.drawOval(
      const Rect.fromLTWH(39.5, 35, 8.5, 2.5),
      Paint()..color = const Color(0xFF78350F),
    );

    // Plant leaves with subtle sway
    final sway = math.sin(t * math.pi * 2) * 1.2;
    final leafPaint = Paint()..color = const Color(0xFF10B981);
    final leftLeaf = Path()
      ..moveTo(43.5, 35.5)
      ..quadraticBezierTo(38 + sway, 30.5, 39, 26)
      ..quadraticBezierTo(43, 29.5, 43.5, 35.5);
    cv.drawPath(leftLeaf, leafPaint);

    final rightLeaf = Path()
      ..moveTo(43.5, 35.5)
      ..quadraticBezierTo(48 + sway, 29.5, 48, 24)
      ..quadraticBezierTo(45, 28.5, 43.5, 35.5);
    cv.drawPath(rightLeaf, Paint()..color = const Color(0xFF34D399));

    // 4. Sparkles
    _drawSparkle(cv, const Offset(10, 16), 3.2, 0.45 + 0.4 * math.sin(t * math.pi * 2));
    _drawSparkle(cv, const Offset(52, 32), 2.8, 0.35 + 0.4 * math.cos(t * math.pi * 2));
  }

  void _drawEveningScene(Canvas cv) {
    // 1. Setting sunset sun dipping into horizon
    final sunPulse = math.sin(t * math.pi * 2) * 1.2;
    const sunCenter = Offset(40, 20);

    // Warm sunset aura
    cv.drawCircle(
      sunCenter,
      14.5 + sunPulse * 0.6,
      Paint()..color = const Color(0xFFFB923C).withValues(alpha: 0.26),
    );
    // Sunset gradient sun
    cv.drawCircle(
      sunCenter,
      11.5 + sunPulse * 0.3,
      Paint()..color = const Color(0xFFFB923C),
    );
    cv.drawCircle(
      sunCenter,
      9.0,
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Dusk horizon arcs
    final duskPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    cv.drawLine(const Offset(34, 33), const Offset(51, 33), duskPaint);
    cv.drawLine(const Offset(37, 36), const Offset(49, 36), duskPaint..color = Colors.white.withValues(alpha: 0.20));

    // 2. Evening clock pointing to 6:00 PM / 18:00 (shift end)
    _drawClockBase(cv, hourHandTo: const Offset(24, 38.5), minuteHandTo: const Offset(24, 21));

    // 3. Evening tea mug with chamomile amber liquid
    _drawMug(cv, liquidColor: const Color(0xFFB45309), yOffset: 1.0);

    // 4. Twilight stars
    _drawSparkle(cv, const Offset(11, 16), 3.4, 0.4 + 0.4 * math.sin(t * math.pi * 2));
    _drawSparkle(cv, const Offset(49, 12), 2.8, 0.5 + 0.4 * math.cos(t * math.pi * 2));
  }

  void _drawNightScene(Canvas cv) {
    // 1. Luminous crescent moon with celestial glow
    const moonCenter = Offset(40, 16);
    final moonPulse = math.sin(t * math.pi * 2) * 1.2;

    // Moonlight halo
    cv.drawCircle(
      moonCenter,
      16 + moonPulse * 0.8,
      Paint()..color = const Color(0xFF93C5FD).withValues(alpha: 0.22),
    );

    // Crescent Moon geometry
    final moonOuter = Path()..addOval(Rect.fromCircle(center: moonCenter, radius: 10.5));
    final moonCut = Path()..addOval(Rect.fromCircle(center: const Offset(36.5, 13.0), radius: 9.5));
    final crescent = Path.combine(PathOperation.difference, moonOuter, moonCut);

    cv.drawPath(
      crescent,
      Paint()..color = const Color(0xFFFEF08A),
    );

    // 2. Bedside night clock pointing to ~11:00 PM
    _drawClockBase(cv, hourHandTo: const Offset(20, 26), minuteHandTo: const Offset(24, 21));

    // 3. Cozy nighttime warm drink (cocoa / warm milk)
    _drawMug(cv, liquidColor: const Color(0xFF451A03), steamIntensity: 0.85);

    // 4. Night stars constellation
    _drawSparkle(cv, const Offset(10, 15), 3.6, 0.4 + 0.45 * math.sin(t * math.pi * 2));
    _drawSparkle(cv, const Offset(28, 10), 2.6, 0.35 + 0.4 * math.cos(t * math.pi * 2));
    _drawSparkle(cv, const Offset(52, 28), 3.0, 0.4 + 0.4 * math.sin((t + 0.4) * math.pi * 2));
    _drawSparkle(cv, const Offset(13, 46), 2.4, 0.3 + 0.35 * math.cos((t + 0.6) * math.pi * 2));
  }

  void _drawWorkingScene(Canvas cv) {
    const center = Offset(30, 30);

    // 1. Concentric pulsing energy rings
    final pulse = (t * 1.8) % 1.0;
    cv.drawCircle(
      center,
      17 + pulse * 9,
      Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: (0.45 * (1 - pulse)).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // 2. Central white badge with emerald glow
    cv.drawCircle(
      center,
      17,
      Paint()..color = Colors.white,
    );
    cv.drawCircle(
      center,
      17,
      Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Bold Focus / Zap icon inside
    final zapPath = Path()
      ..moveTo(32, 18)
      ..lineTo(24, 30)
      ..lineTo(29, 30)
      ..lineTo(27, 42)
      ..lineTo(36, 28)
      ..lineTo(31, 28)
      ..close();
    cv.drawPath(zapPath, Paint()..color = const Color(0xFF10B981));

    // 3. Orbiting active satellite beacon
    final angle = t * math.pi * 2;
    final beacon = Offset(
      center.dx + math.cos(angle) * 23.5,
      center.dy + math.sin(angle) * 23.5,
    );
    cv.drawCircle(beacon, 5.0, Paint()..color = Colors.white.withValues(alpha: 0.35));
    cv.drawCircle(beacon, 2.8, Paint()..color = Colors.white);

    // 4. Sparkles
    _drawSparkle(cv, const Offset(11, 14), 3.2, 0.5 + 0.4 * math.sin(t * math.pi * 2));
    _drawSparkle(cv, const Offset(49, 44), 3.0, 0.4 + 0.4 * math.cos(t * math.pi * 2));
  }

  void _drawBreakScene(Canvas cv) {
    // 1. Saucer
    cv.drawOval(
      Rect.fromCenter(center: const Offset(29, 46), width: 30, height: 6),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // 2. Mug
    final mugRRect = RRect.fromLTRBR(18, 26, 38, 44, const Radius.circular(5.5));
    cv.drawRRect(mugRRect, Paint()..color = Colors.white);

    // Handle
    final handle = Path()
      ..moveTo(38, 29)
      ..arcToPoint(const Offset(38, 41), radius: const Radius.circular(6), clockwise: true);
    cv.drawPath(
      handle,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // 3. Dual waving steam curls
    final s1 = (t * 1.5) % 1.0;
    final p1 = Path()
      ..moveTo(24 + math.sin((t + 0.2) * math.pi * 2) * 2, 24 - s1 * 12)
      ..quadraticBezierTo(22, 19 - s1 * 12, 25, 14 - s1 * 12);
    cv.drawPath(
      p1,
      Paint()
        ..color = Colors.white.withValues(alpha: (0.75 * (1 - s1)).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    final s2 = ((t + 0.5) * 1.5) % 1.0;
    final p2 = Path()
      ..moveTo(32 + math.cos((t + 0.4) * math.pi * 2) * 2, 24 - s2 * 12)
      ..quadraticBezierTo(34, 19 - s2 * 12, 31, 14 - s2 * 12);
    cv.drawPath(
      p2,
      Paint()
        ..color = Colors.white.withValues(alpha: (0.75 * (1 - s2)).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // 4. Restful amber crescent moon or sun depending on time
    const moonCenter = Offset(47, 16);
    final moon = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: 7.5));
    final cut = Path()
      ..addOval(Rect.fromCircle(center: const Offset(44.5, 14.5), radius: 6.5));
    final crescent = Path.combine(PathOperation.difference, moon, cut);
    cv.drawPath(
      crescent,
      Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.95),
    );

    _drawSparkle(cv, const Offset(11, 20), 3.0, 0.4 + 0.4 * math.sin(t * math.pi * 2));
  }

  @override
  bool shouldRepaint(_ShiftPainter old) =>
      old.phase != phase || old.timeOfDay != timeOfDay || old.t != t;
}
