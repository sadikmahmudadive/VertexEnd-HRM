import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Rounded bar chart with direct value labels and no gridlines.
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.valueLabels,
    this.highlight,
    this.height = 96,
    this.min,
  });

  final List<double> values;
  final List<String> labels;
  final List<String> valueLabels;
  final int? highlight;
  final double height;
  final double? min;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lo = min ?? 0;
    final hi = values.reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < values.length; i++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(valueLabels[i],
                          style: T.caption.col(c.textSecondary).tnum),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 800 + i * 80),
                        curve: Motion.standard,
                        builder: (context, v, _) {
                          final f = hi == lo
                              ? 1.0
                              : 0.35 + 0.65 * ((values[i] - lo) / (hi - lo));
                          return Container(
                            width: 34,
                            height: (height - 28) * f * v,
                            decoration: BoxDecoration(
                              color: highlight == null || highlight == i
                                  ? c.primary500
                                  : HrmColors.primary200,
                              borderRadius: BorderRadius.circular(9),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Container(height: 1, color: c.borderStrong),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final l in labels)
              Expanded(
                child: Text(l,
                    textAlign: TextAlign.center,
                    style: T.caption.col(c.textSecondary)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Stacked segment bar (for example approved vs pending).
class SegmentBar extends StatelessWidget {
  const SegmentBar({super.key, required this.segments, this.height = 12});
  final List<(double, Color)> segments;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Motion.standard,
      builder: (context, v, _) => ClipRRect(
        borderRadius: Rd.rFull,
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, box) => Row(
                children: [
                  for (var i = 0; i < segments.length; i++) ...[
                    if (i > 0) const SizedBox(width: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Motion.standard,
                      width: ((box.maxWidth - 2 * (segments.length - 1)) *
                              segments[i].$1 *
                              v)
                          .clamp(0, double.infinity),
                      color: segments[i].$2,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Abstract map showing the office geofence and the user's pin.
class GeofenceMap extends StatelessWidget {
  const GeofenceMap({super.key, this.height = 132});
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.bgSubtle,
        borderRadius: Rd.rLg,
        border: Border.all(color: c.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPainter(c))),
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: Sp.s2),
              decoration: BoxDecoration(
                  color: c.bgSurface, borderRadius: Rd.rFull),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: c.success, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Head Office · within geofence',
                      style: T.caption.col(c.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.c);
  final HrmColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = c.borderStrong.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    canvas.drawPath(
        Path()
          ..moveTo(-10, h * 0.73)
          ..cubicTo(w * .2, h * .64, w * .35, h * .76, w * .53, h * .53)
          ..cubicTo(w * .7, h * .3, w * .85, h * .3, w + 10, h * .42),
        road);
    canvas.drawPath(
        Path()
          ..moveTo(w * .27, -10)
          ..cubicTo(w * .29, h * .3, w * .25, h * .7, w * .31, h + 10),
        road);
    canvas.drawPath(
        Path()
          ..moveTo(w * .7, -10)
          ..cubicTo(w * .67, h * .25, w * .73, h * .6, w * .7, h + 10),
        road);
    final block = Paint()..color = c.bgSurface.withValues(alpha: 0.9);
    for (final r in [
      Rect.fromLTWH(w * .36, 12, 56, 30),
      Rect.fromLTWH(w * .76, h * .65, 64, 32),
      Rect.fromLTWH(12, 18, 54, 40),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)), block);
    }
    final center = Offset(w * .5, h * .5);
    canvas.drawCircle(center, 46, Paint()..color = c.primary500.withValues(alpha: 0.12));
    final dash = Paint()
      ..color = c.primary500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const steps = 36;
    for (var i = 0; i < steps; i += 2) {
      final a0 = i / steps * 6.2832, a1 = (i + 1) / steps * 6.2832;
      canvas.drawArc(Rect.fromCircle(center: center, radius: 46), a0, a1 - a0, false, dash);
    }
    canvas.drawCircle(center, 9, Paint()..color = c.primary500);
    canvas.drawCircle(center, 3.5, Paint()..color = c.textOnPrimary);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.c != c;
}
