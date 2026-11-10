import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../illustrations/illustrations.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'primitives.dart';

// ---------------------------------------------------------------- Buttons

enum BtnKind { primary, secondary, outline, ghost, danger, ghostDanger }

enum BtnSize { lg, md, sm }

class HrmButton extends StatelessWidget {
  const HrmButton(
    this.label, {
    super.key,
    this.onPressed,
    this.kind = BtnKind.primary,
    this.size = BtnSize.lg,
    this.icon,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final BtnSize size;
  final IconData? icon;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg, border) = switch (kind) {
      BtnKind.primary => (c.primary500, c.textOnPrimary, null),
      BtnKind.secondary => (c.primary50, c.primary600, null),
      BtnKind.outline => (Colors.transparent, c.textPrimary, c.borderStrong),
      BtnKind.ghost => (Colors.transparent, c.primary500, null),
      BtnKind.danger => (c.danger, c.textOnPrimary, null),
      BtnKind.ghostDanger => (Colors.transparent, c.danger, null),
    };
    final h = switch (size) {
      BtnSize.lg => Sz.buttonLg,
      BtnSize.md => Sz.buttonMd,
      BtnSize.sm => Sz.buttonSm,
    };
    final hPad = switch (size) {
      BtnSize.lg => Sp.s6,
      BtnSize.md => Sp.s5,
      BtnSize.sm => Sp.s4,
    };
    final enabled = onPressed != null && !loading;
    final content = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg))
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: Sp.s2),
              ],
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.label.col(fg)),
              ),
            ],
          );
    return Opacity(
      opacity: onPressed == null ? Sz.disabledOpacity : 1,
      child: PressScale(
        onTap: enabled ? onPressed : null,
        haptic: true,
        semanticLabel: label,
        child: Container(
          height: h,
          width: expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: Rd.rMd,
            border: border == null ? null : Border.all(color: border),
          ),
          child: content,
        ),
      ),
    );
  }
}

class HrmIconButton extends StatelessWidget {
  const HrmIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.count = 0,
    this.filled = true,
    this.size = Sz.touchMin,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int count;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: label,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? c.bgSubtle : Colors.transparent),
              child: Icon(icon, size: 20, color: c.textPrimary),
            ),
            if (count > 0)
              Positioned(top: 2, right: 2, child: CountBadge(count)),
          ],
        ),
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  const CountBadge(this.count, {super.key, this.onPrimary = false});
  final int count;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: onPrimary ? c.textOnPrimary : c.danger,
        borderRadius: Rd.rFull,
      ),
      child: Text('$count',
          style: T.overline.copyWith(
              letterSpacing: 0,
              color: onPrimary ? c.primary500 : c.textOnPrimary)),
    );
  }
}

// ---------------------------------------------------------------- Surfaces

class HrmCard extends StatelessWidget {
  const HrmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.s4),
    this.onTap,
    this.color,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.bgSurface,
        borderRadius: Rd.rLg,
        border: Border.all(color: borderColor ?? c.borderDefault),
        boxShadow: c.isDark
            ? null
            : const [
                BoxShadow(
                    color: Color(0x0A0F172A), blurRadius: 2, offset: Offset(0, 1)),
                BoxShadow(
                    color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2)),
              ],
      ),
      child: child,
    );
    return onTap == null ? box : PressScale(onTap: onTap, child: box);
  }
}

/// Hero gradient card (one per screen).
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.child, this.padding = const EdgeInsets.all(Sp.s5)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        borderRadius: Rd.rLg,
        boxShadow: [
          BoxShadow(
            color: c.heroFrom.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: Rd.rLg,
        child: Container(
          decoration: BoxDecoration(
            gradient: c.heroGradient,
            borderRadius: Rd.rLg,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -60,
                top: -70,
                child: _Orb(180),
              ),
              Positioned(
                left: -40,
                bottom: -50,
                child: _Orb(120),
              ),
              const HeroCardDecorations(),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb(this.size);
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
      );
}

class HrmList extends StatelessWidget {
  const HrmList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: Rd.rLg,
        border: Border.all(color: c.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: c.borderDefault),
            children[i],
          ],
        ],
      ),
    );
  }
}

class HrmListTile extends StatelessWidget {
  const HrmListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.minHeight = 64,
    this.titleColor,
    this.chevron = false,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double minHeight;
  final Color? titleColor;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.s4, vertical: Sp.s2),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: Sp.s3)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: T.bodyStrong.col(titleColor ?? c.textPrimary)),
                  if (subtitle != null)
                    Text(subtitle!, style: T.caption.col(c.textSecondary)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: Sp.s2), trailing!],
            if (chevron) ...[
              const SizedBox(width: Sp.s1),
              Icon(LucideIcons.chevronRight, size: 20, color: c.textSecondary),
            ],
          ],
        ),
      ),
    );
    return onTap == null ? row : PressScale(onTap: onTap, scale: 0.99, child: row);
  }
}

// ---------------------------------------------------------------- Status

enum Tone { success, warning, danger, info, neutral, primary }

class HrmBadge extends StatelessWidget {
  const HrmBadge(this.label, {super.key, this.tone = Tone.neutral});
  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, dot) = toneColors(c, tone);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: Sp.s2),
      decoration: BoxDecoration(color: bg, borderRadius: Rd.rFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: T.caption.col(c.textPrimary)),
        ],
      ),
    );
  }
}

(Color soft, Color solid) toneColors(HrmColors c, Tone t) => switch (t) {
      Tone.success => (c.successSoft, c.success),
      Tone.warning => (c.warningSoft, c.warning),
      Tone.danger => (c.dangerSoft, c.danger),
      Tone.info => (c.infoSoft, c.info),
      Tone.neutral => (c.neutralSoft, c.neutral),
      Tone.primary => (c.primary50, c.primary500),
    };

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.text,
    this.tone = Tone.info,
    this.icon,
    this.compact = false,
  });
  final String text;
  final Tone tone;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, solid) = toneColors(c, tone);
    final ic = icon ??
        switch (tone) {
          Tone.success => LucideIcons.circleCheck,
          Tone.warning || Tone.danger => LucideIcons.triangleAlert,
          _ => LucideIcons.info,
        };
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? Sp.s3 : Sp.s4, vertical: compact ? Sp.s2 : Sp.s3),
      decoration: BoxDecoration(color: bg, borderRadius: Rd.rMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(ic, size: compact ? 16 : 20, color: solid),
          const SizedBox(width: Sp.s3),
          Expanded(
              child: Text(text,
                  style: (compact ? T.caption : T.label).col(c.textPrimary))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Avatars

enum Presence { none, inOffice, onBreak, off, onLeave }

class HrmAvatar extends StatelessWidget {
  const HrmAvatar(
    this.initials, {
    super.key,
    this.size = 40,
    this.variant = 0,
    this.presence = Presence.none,
    this.ringColor,
    this.imageUrl,
  });
  final String initials;
  final double size;
  final int variant;
  final Presence presence;
  final Color? ringColor;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg, border) = switch (variant % 3) {
      0 => (HrmColors.primary100, HrmColors.primary800, null),
      1 => (
          Color.alphaBlend(
              c.secondary500.withValues(alpha: 0.28), const Color(0xFFFFFFFF)),
          const Color(0xFF0F172A),
          null
        ),
      _ => (c.neutralSoft, c.textPrimary, c.borderDefault),
    };
    final dot = switch (presence) {
      Presence.none => null,
      Presence.inOffice => c.success,
      Presence.onBreak => c.warning,
      Presence.off => c.neutral,
      Presence.onLeave => c.info,
    };
    final dotSize = (size * 0.27).clamp(8.0, 24.0);
    final fallbackInitials = Text(
      initials,
      style: T.label.copyWith(
        fontSize: (size * 0.34).clamp(10, 32),
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: border == null ? null : Border.all(color: border),
            ),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(child: fallbackInitials),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(child: fallbackInitials);
                      },
                    ),
                  )
                : fallbackInitials,
          ),
          if (dot != null)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor ?? c.bgSurface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AvatarStack extends StatelessWidget {
  const AvatarStack(this.items, {super.key, this.size = 32});
  final List<String> items;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final step = size - 8;
    return SizedBox(
      width: step * (items.length - 1) + size,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.bgSurface, width: 2)),
                child: HrmAvatar(items[i], size: size - 4, variant: i),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Controls

class HrmChip extends StatelessWidget {
  const HrmChip(
    this.label, {
    super.key,
    this.selected = false,
    this.onTap,
    this.sub,
    this.dot,
    this.height = Sz.buttonSm,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? sub;
  final Color? dot;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = selected ? c.primary600 : c.textPrimary;
    return PressScale(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      scale: 0.95,
      child: AnimatedContainer(
        duration: Motion.fast,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: Sp.s3),
        decoration: BoxDecoration(
          color: selected ? c.primary50 : c.bgSurface,
          borderRadius: Rd.rFull,
          border: Border.all(
              color: selected ? c.primary500 : c.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(LucideIcons.check, size: 16, color: fg),
              const SizedBox(width: 6),
            ] else if (dot != null) ...[
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 6),
            ],
            Text(label, style: T.label.col(fg)),
            if (sub != null) ...[
              const SizedBox(width: 6),
              Text(sub!,
                  style: T.label.weight(FontWeight.w400).col(
                      selected ? c.primary600 : c.textSecondary).tnum),
            ],
          ],
        ),
      ),
    );
  }
}

class HrmSegmented extends StatelessWidget {
  const HrmSegmented({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.icons,
  });
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final List<IconData>? icons;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.bgSubtle, borderRadius: Rd.rFull),
      child: LayoutBuilder(builder: (context, box) {
        final w = (box.maxWidth) / labels.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: Motion.base,
              curve: Motion.standard,
              left: w * index,
              width: w,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: c.bgSurface,
                  borderRadius: Rd.rFull,
                  border: Border.all(color: c.borderDefault),
                  boxShadow: c.isDark
                      ? null
                      : const [
                          BoxShadow(
                              color: Color(0x0F0F172A),
                              blurRadius: 4,
                              offset: Offset(0, 1))
                        ],
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (i != index) HapticFeedback.selectionClick();
                        onChanged(i);
                      },
                      child: SizedBox(
                        height: 36,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icons != null) ...[
                              Icon(icons![i],
                                  size: 16,
                                  color: i == index
                                      ? c.textPrimary
                                      : c.textSecondary),
                              const SizedBox(width: 6),
                            ],
                            AnimatedDefaultTextStyle(
                              duration: Motion.fast,
                              style: T.label.col(i == index
                                  ? c.textPrimary
                                  : c.textSecondary),
                              child: Text(labels[i]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class HrmSwitch extends StatelessWidget {
  const HrmSwitch({super.key, required this.value, required this.onChanged, this.label});
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        child: SizedBox(
          width: 51,
          height: Sz.touchMin,
          child: Center(
            child: AnimatedContainer(
              duration: Motion.fast,
              width: 51,
              height: 31,
              padding: const EdgeInsets.all(2),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value ? c.primary500 : c.neutral,
                borderRadius: Rd.rFull,
              ),
              child: Container(
                width: 27,
                height: 27,
                decoration:
                    BoxDecoration(color: c.bgSurface, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HrmCheck extends StatelessWidget {
  const HrmCheck({super.key, required this.checked, this.size = 26});
  final bool checked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AnimatedContainer(
      duration: Motion.base,
      curve: Motion.standard,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? c.success : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: checked ? c.success : c.neutral, width: 2),
      ),
      child: AnimatedOpacity(
        duration: Motion.fast,
        opacity: checked ? 1 : 0,
        child: Icon(LucideIcons.check,
            size: size * 0.62, color: c.textOnPrimary, weight: 3),
      ),
    );
  }
}

/// Filled text field with the label above it.
class HrmField extends StatelessWidget {
  const HrmField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefix,
    this.error,
    this.helper,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.initialValue,
    this.obscure = false,
    this.suffix,
  });
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final Widget? prefix;
  final String? error;
  final String? helper;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    OutlineInputBorder b(Color col, [double w = 1]) => OutlineInputBorder(
        borderRadius: Rd.rSm, borderSide: BorderSide(color: col, width: w));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: T.label.col(c.textSecondary)),
        const SizedBox(height: Sp.s1),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: T.body.col(c.textPrimary),
          cursorColor: c.primary500,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              null,
          decoration: InputDecoration(
            isDense: false,
            filled: true,
            fillColor: c.bgSubtle,
            hintText: hint,
            hintStyle: T.body.col(c.textTertiary),
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: EdgeInsets.symmetric(
                horizontal: Sp.s4, vertical: maxLines > 1 ? Sp.s3 : 15),
            enabledBorder: b(error != null ? c.danger : c.borderStrong),
            focusedBorder: b(error != null ? c.danger : c.primary500, 2),
            border: b(c.borderStrong),
          ),
        ),
        if (error != null || helper != null) ...[
          const SizedBox(height: Sp.s1),
          Row(children: [
            if (error != null) ...[
              Icon(LucideIcons.triangleAlert, size: 14, color: c.danger),
              const SizedBox(width: 4),
            ],
            Expanded(
                child: Text(error ?? helper!,
                    style: T.caption.col(error != null ? c.danger : c.textSecondary))),
          ]),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------- States

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.s8, horizontal: Sp.s4),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration:
                BoxDecoration(color: c.primary50, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: c.primary600),
          ).popIn(),
          const SizedBox(height: Sp.s4),
          Text(title, style: T.h3.col(c.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: Sp.s1),
          Text(message,
              style: T.body.col(c.textSecondary), textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: Sp.s4),
            HrmButton(action!,
                onPressed: onAction,
                kind: BtnKind.secondary,
                size: BtnSize.md,
                expand: false),
          ],
        ],
      ),
    );
  }
}

/// Date block used in leave lists: big day over a small month.
class DateBlock extends StatelessWidget {
  const DateBlock(this.day, this.month, {super.key, this.info = false});
  final String day;
  final String month;
  final bool info;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 48,
      height: 52,
      decoration: BoxDecoration(
        color: info ? c.infoSoft : c.primary50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day,
              style: T.h3.col(info ? c.textPrimary : c.primary600).tnum),
          Text(month.toUpperCase(),
              style: T.overline
                  .copyWith(fontSize: 10, letterSpacing: 0.8)
                  .col(info ? c.textPrimary : c.primary600)),
        ],
      ),
    );
  }
}
