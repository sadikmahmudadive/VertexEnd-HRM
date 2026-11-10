import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'components.dart';
import 'primitives.dart';

class DockItem {
  const DockItem(this.icon, this.label, {this.badge = 0});
  final IconData icon;
  final String label;
  final int badge;
}

/// Floating glass dock: icon-only tabs, the active tab grows into a labelled
/// pill. Detached from the screen edge, fully rounded.
class FloatingDock extends StatelessWidget {
  const FloatingDock({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  final List<DockItem> items;
  final int index;
  final ValueChanged<int> onTap;

  static const double _tab = 50;
  static const double _gap = 2;
  static const double _pad = 9;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
          padding: EdgeInsets.fromLTRB(16, 40, 16, bottom + 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [c.bgCanvas, c.bgCanvas.withValues(alpha: 0)],
              stops: const [0.4, 1],
            ),
          ),
          child: Glass(
            padding: const EdgeInsets.all(_pad),
            child: LayoutBuilder(builder: (context, box) {
              final inner = box.maxWidth;
              final others = items.length - 1;
              final active = inner - others * _tab - others * _gap;
              return Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    _Tab(
                      item: items[i],
                      selected: i == index,
                      width: i == index ? active : _tab,
                      onTap: () {
                        if (i != index) HapticFeedback.selectionClick();
                        onTap(i);
                      },
                    ),
                  ],
                ],
              );
            }),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.4, end: 0, duration: 700.ms, curve: Motion.spring);
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.width,
    required this.onTap,
  });
  final DockItem item;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = selected ? c.textOnPrimary : c.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: PressScale(
        onTap: onTap,
        scale: 0.9,
        child: AnimatedContainer(
          duration: Motion.slow,
          curve: Motion.standard,
          width: width,
          height: 50,
          decoration: BoxDecoration(
            color: selected ? c.primary500 : Colors.transparent,
            borderRadius: Rd.rFull,
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: c.primary500.withValues(alpha: 0.42),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: Rd.rFull,
            child: Stack(
              alignment: Alignment.center,
              children: [
                OverflowBox(
                  minWidth: 0,
                  maxWidth: 300,
                  minHeight: 0,
                  maxHeight: 50,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 24, color: fg),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Text(item.label,
                                maxLines: 1,
                                softWrap: false,
                                style: T.label
                                    .copyWith(
                                        fontSize: 13, fontWeight: FontWeight.w600)
                                    .col(fg))
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 150.ms),
                        if (item.badge > 0) ...[
                          const SizedBox(width: 6),
                          CountBadge(item.badge, onPrimary: true),
                        ],
                      ],
                    ],
                  ),
                ),
                if (!selected && item.badge > 0)
                  Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: c.bgSurfaceRaised, width: 2)),
                        child: CountBadge(item.badge),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
