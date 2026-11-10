import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Shrinks slightly while pressed, with a light haptic on tap.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  final String? semanticLabel;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Entrance: fade and rise, staggered by [i].
extension RiseX on Widget {
  Widget rise([int i = 0]) => animate(delay: (70 * i).ms)
      .fadeIn(duration: 500.ms, curve: Motion.standard)
      .slideY(begin: 0.06, end: 0, duration: 600.ms, curve: Motion.standard);

  Widget popIn([int i = 0]) => animate(delay: (90 * i).ms)
      .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOutBack)
      .fadeIn(duration: 300.ms);
}

/// Soft blurred color blobs behind the top of a screen (mesh trend).
class BlobBackdrop extends StatelessWidget {
  const BlobBackdrop({super.key, this.left = true, this.secondary = true});
  final bool left;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget blob(double size, Color color, {double? l, double? r, double? t}) =>
        Positioned(
          left: l,
          right: r,
          top: t,
          child: IgnorePointer(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color, color.withValues(alpha: 0)],
                  stops: const [0.15, 1],
                ),
              ),
            )
                .animate(onPlay: (ctl) => ctl.repeat(reverse: true))
                .move(
                    begin: Offset.zero,
                    end: const Offset(18, -14),
                    duration: 7.seconds,
                    curve: Curves.easeInOut),
          ),
        );
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          blob(340, c.blob(c.primary500),
              l: left ? -120 : null, r: left ? null : -120, t: -150),
          if (secondary)
            blob(260, c.blob(c.secondary500),
                r: left ? -100 : null, l: left ? null : -100, t: -30),
        ],
      ),
    );
  }
}

/// Frosted-glass container (nav surfaces only).
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = Rd.full,
    this.padding,
    this.opacity = Sz.glassOpacity,
    this.shadow = true,
  });
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow && !c.isDark
            ? const [
                BoxShadow(
                    color: Color(0x290F172A), blurRadius: 34, offset: Offset(0, 14)),
                BoxShadow(
                    color: Color(0x0F0F172A), blurRadius: 6, offset: Offset(0, 2)),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
              sigmaX: Sz.glassBlur, sigmaY: Sz.glassBlur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: c.bgSurfaceRaised.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: c.borderDefault.withValues(alpha: 0.75)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A circular 40px-style icon container used in list rows.
class LeadIcon extends StatelessWidget {
  const LeadIcon(this.icon, {super.key, this.size = 40, this.bg, this.fg, this.circle = true});
  final IconData icon;
  final double size;
  final Color? bg;
  final Color? fg;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg ?? c.primary50,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.5, color: fg ?? c.primary600),
    );
  }
}

/// Circular determinate ring with rounded caps.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 64,
    this.stroke = 9,
    this.track,
    this.child,
    this.duration = const Duration(milliseconds: 1300),
    this.delay = const Duration(milliseconds: 350),
  });
  final double value;
  final Color color;
  final double size;
  final double stroke;
  final Color? track;
  final Widget? child;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: duration,
            curve: Motion.standard,
            builder: (context, v, _) => CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(v, color, track ?? c.borderDefault, stroke),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.color, this.track, this.stroke);
  final double v;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (v > 0) {
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = color);
      final tipAngle = -math.pi / 2 + math.pi * 2 * v;
      final center = rect.center;
      final radius = r.width / 2;
      final tipX = center.dx + math.cos(tipAngle) * radius;
      final tipY = center.dy + math.sin(tipAngle) * radius;
      canvas.drawCircle(Offset(tipX, tipY), stroke * 0.72, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(tipX, tipY),
        stroke * 1.25,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.v != v || old.color != color || old.track != track;
}

/// Linear progress with rounded ends and animated fill.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.height = 8, this.color});
  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ClipRRect(
      borderRadius: Rd.rFull,
      child: Container(
        height: height,
        color: c.borderDefault,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: 900.ms,
          curve: Motion.standard,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                color: color ?? c.primary500,
                borderRadius: Rd.rFull,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmering placeholder block.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.width, this.height = 14, this.radius = Rd.xs});
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.bgSubtle,
        borderRadius: BorderRadius.circular(radius),
      ),
    ).animate(onPlay: (ctl) => ctl.repeat()).shimmer(
          duration: 1200.ms,
          color: c.borderDefault.withValues(alpha: 0.8),
        );
  }
}

/// Section header: title on the left, optional action on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(top: Sp.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(title, style: T.h3.col(c.textPrimary))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(action!, style: T.label.col(c.primary500)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Counts up from zero to [end] the first time it appears.
class CountUp extends StatelessWidget {
  const CountUp(
    this.end, {
    super.key,
    required this.style,
    this.format,
    this.duration = const Duration(milliseconds: 1000),
  });
  final num end;
  final TextStyle style;
  final String Function(int)? format;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: end.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final n = v.round();
        return Text(format == null ? '$n' : format!(n), style: style);
      },
    );
  }
}

/// Collapses to nothing (slide + fade + shrink) when [visible] turns false.
class Collapsible extends StatelessWidget {
  const Collapsible({
    super.key,
    required this.visible,
    required this.child,
    this.slideTo = const Offset(0.15, 0),
  });
  final bool visible;
  final Widget child;
  final Offset slideTo;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: visible ? 1 : 0,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : slideTo,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeIn,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 260),
            child: child,
          ),
        ),
      ),
    );
  }
}

class Overline extends StatelessWidget {
  const Overline(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(Sp.s1, Sp.s3, 0, Sp.s1),
        child: Text(text.toUpperCase(),
            style: T.overline.col(context.c.textSecondary)),
      );
}
