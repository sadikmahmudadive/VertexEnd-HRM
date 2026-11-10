import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'components.dart';
import 'primitives.dart';

/// Canvas background with the soft mesh blobs.
class HrmBackground extends StatelessWidget {
  const HrmBackground({super.key, required this.child, this.blobLeft = true});
  final Widget child;
  final bool blobLeft;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ColoredBox(
      color: c.bgCanvas,
      child: Stack(
        children: [
          BlobBackdrop(left: blobLeft),
          child,
        ],
      ),
    );
  }
}

/// Standard scrolling screen: optional header, then a spaced column.
class HrmScreen extends StatelessWidget {
  const HrmScreen({
    super.key,
    this.title,
    this.children = const [],
    this.actions = const [],
    this.showBack,
    this.bottomPad = 32,
    this.blobLeft = true,
    this.titleWidget,
    this.floating,
    this.controller,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget> children;
  final List<Widget> actions;
  final bool? showBack;
  final double bottomPad;
  final bool blobLeft;
  final Widget? floating;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final back = showBack ?? context.canPop();
    return Scaffold(
      backgroundColor: context.c.bgCanvas,
      body: HrmBackground(
        blobLeft: blobLeft,
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(Sp.s4, Sp.s2, Sp.s4, bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Sp.s3,
                  children: [
                    if (title != null || titleWidget != null || back)
                      ScreenHeader(
                        title: title,
                        titleWidget: titleWidget,
                        back: back,
                        actions: actions,
                      ).rise(),
                    ...children,
                  ],
                ),
              ),
            ),
            ?floating,
          ],
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.back = false,
    this.actions = const [],
  });
  final String? title;
  final Widget? titleWidget;
  final bool back;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          if (back) ...[
            HrmIconButton(
              icon: LucideIcons.chevronLeft,
              label: 'Back',
              onTap: () => context.pop(),
            ),
            const SizedBox(width: Sp.s3),
          ],
          Expanded(
            child: titleWidget ??
                Text(title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.h1.col(c.textPrimary)),
          ),
          for (final a in actions) ...[const SizedBox(width: Sp.s2), a],
        ],
      ),
    );
  }
}
