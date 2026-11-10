import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_state.dart';
import '../../core/ui.dart';
import '../../data/models.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);
    final shown = all.where((n) => _tab == 0 || n.unread || n.result.isNotEmpty).toList();

    final children = <Widget>[];
    var last = '';
    var i = 0;
    for (final n in shown) {
      if (n.group != last) {
        children.add(Overline(n.group));
        last = n.group;
      }
      children.add(_Tile(n).rise(i++));
    }

    return HrmScreen(
      title: 'Notifications',
      children: [
        Row(
          spacing: Sp.s2,
          children: [
            Expanded(
              child: HrmSegmented(
                labels: ['All', 'Unread ($unread)'],
                index: _tab,
                onChanged: (v) => setState(() => _tab = v),
              ),
            ),
            HrmButton('Mark all read',
                kind: BtnKind.ghost,
                size: BtnSize.md,
                expand: false,
                onPressed: () => ref.read(notificationsProvider.notifier).markAllRead()),
          ],
        ).rise(1),
        ...children,
        if (shown.isEmpty)
          const EmptyState(
            icon: LucideIcons.check,
            title: "You're all caught up",
            message: 'Nothing unread right now.',
          ),
      ],
    );
  }
}

class _Tile extends ConsumerWidget {
  const _Tile(this.n);
  final AppNotification n;

  (IconData, Tone) get _look => switch (n.kind) {
        NotifKind.request => (LucideIcons.calendarDays, Tone.info),
        NotifKind.payslip => (LucideIcons.wallet, Tone.success),
        NotifKind.announcement => (LucideIcons.megaphone, Tone.warning),
        NotifKind.approved => (LucideIcons.circleCheck, Tone.success),
        NotifKind.reminder => (LucideIcons.triangleAlert, Tone.warning),
        NotifKind.profile => (LucideIcons.user, Tone.primary),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final notifier = ref.read(notificationsProvider.notifier);
    final (icon, tone) = _look;
    final (bg, fg) = toneColors(c, tone);
    final (yes, no) = switch (n.action) {
      NotifAction.approve => ('Approve', 'Decline'),
      NotifAction.link => ('View payslip', ''),
      NotifAction.acknowledge => ('Acknowledge', ''),
      null => ('', ''),
    };
    return AnimatedContainer(
      duration: Motion.slow,
      padding: const EdgeInsets.all(Sp.s4),
      decoration: BoxDecoration(
        color: n.unread ? c.primary50 : c.bgSurface,
        borderRadius: Rd.rLg,
        border: Border.all(
            color: n.unread
                ? c.primary500.withValues(alpha: 0.35)
                : c.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: Sp.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.text, style: T.bodyStrong.col(c.textPrimary)),
                Text('${n.sub} · ${n.time}', style: T.caption.col(c.textSecondary)),
                if (n.action != null && n.result.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Sp.s3),
                    child: Row(
                      spacing: Sp.s2,
                      children: [
                        HrmButton(yes,
                            size: BtnSize.sm,
                            expand: false,
                            onPressed: () {
                              if (n.action == NotifAction.link) {
                                notifier.act(n.id, 'Opened');
                                context.go('/payroll');
                              } else {
                                notifier.act(
                                    n.id,
                                    n.action == NotifAction.acknowledge
                                        ? 'Acknowledged'
                                        : 'Approved');
                              }
                            }),
                        if (no.isNotEmpty)
                          HrmButton(no,
                              kind: BtnKind.outline,
                              size: BtnSize.sm,
                              expand: false,
                              onPressed: () => notifier.act(n.id, 'Declined')),
                      ],
                    ),
                  ),
                if (n.result.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: Sp.s2),
                    child: HrmBadge(n.result,
                            tone: n.result == 'Declined' ? Tone.danger : Tone.success)
                        .popIn(),
                  ),
              ],
            ),
          ),
          AnimatedScale(
            scale: n.unread ? 1 : 0,
            duration: Motion.base,
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4, left: Sp.s2),
              decoration: BoxDecoration(color: c.primary500, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
