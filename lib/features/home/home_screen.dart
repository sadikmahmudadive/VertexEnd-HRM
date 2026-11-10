import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_state.dart';
import '../../core/ui.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final clock = ref.watch(clockProvider);
    final unread = ref.watch(unreadCountProvider);
    final pending = ref.watch(pendingApprovalsProvider);
    final presence = switch (clock.phase) {
      ClockPhase.working => Presence.inOffice,
      ClockPhase.onBreak => Presence.onBreak,
      _ => Presence.none,
    };

    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      >= 5 && < 12 => 'Good morning, Rahim 👋',
      >= 12 && < 17 => 'Good afternoon, Rahim ☀️',
      >= 17 && < 21 => 'Good evening, Rahim 🌇',
      _ => 'Good evening, Rahim 🌙',
    };

    return HrmScreen(
      showBack: false,
      bottomPad: 140,
      titleWidget: Row(
        children: [
          HrmAvatar('RA', presence: presence, ringColor: c.bgCanvas),
          const SizedBox(width: Sp.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tue, 3 Nov', style: T.caption.col(c.textSecondary)),
                Text(greeting,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.h3.col(c.textPrimary)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        HrmIconButton(
          icon: LucideIcons.bell,
          label: 'Notifications, $unread unread',
          count: unread,
          onTap: () => context.push('/notifications'),
        ),
      ],
      children: [
        _ClockCard(clock: clock).rise(1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Sp.s3,
          children: [
            Expanded(child: const _LeaveTile().rise(2)),
            Expanded(child: const _PaydayTile().rise(3)),
          ],
        ),
        HrmCard(
          onTap: () => context.push('/team-calendar'),
          child: Row(
            children: [
              const AvatarStack(['NR', 'KA', 'SH', '+3']),
              const SizedBox(width: Sp.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Who's off today", style: T.bodyStrong.col(c.textPrimary)),
                    Text('6 people on leave · 2 in your team',
                        style: T.caption.col(c.textSecondary)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 20, color: c.textSecondary),
            ],
          ),
        ).rise(4),
        if (pending > 0)
          HrmCard(
            onTap: () => context.push('/approvals'),
            child: Row(
              children: [
                const LeadIcon(LucideIcons.circleCheck),
                const SizedBox(width: Sp.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pending approvals',
                          style: T.bodyStrong.col(c.textPrimary)),
                      Text('$pending waiting for you',
                          style: T.caption.col(c.textSecondary)),
                    ],
                  ),
                ),
                CountBadge(pending),
              ],
            ),
          ).rise(5),
        _AskHrBar().rise(5),
        const SectionHeader('Quick actions').rise(6),
        const _QuickActions().rise(6),
        SectionHeader('Announcements',
                action: 'See all', onAction: () => context.push('/announcements'))
            .rise(7),
        const _AnnouncementRow().rise(7),
      ],
    );
  }
}

class _ClockCard extends ConsumerStatefulWidget {
  const _ClockCard({required this.clock});
  final ClockState clock;

  @override
  ConsumerState<_ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends ConsumerState<_ClockCard> {
  ShiftTimeOfDay? _previewTimeOfDay;

  void _cycleTimeOfDay() {
    HapticFeedback.selectionClick();
    setState(() {
      _previewTimeOfDay = switch (_previewTimeOfDay) {
        null => ShiftTimeOfDay.morning,
        ShiftTimeOfDay.morning => ShiftTimeOfDay.afternoon,
        ShiftTimeOfDay.afternoon => ShiftTimeOfDay.evening,
        ShiftTimeOfDay.evening => ShiftTimeOfDay.night,
        ShiftTimeOfDay.night => null,
      };
    });
  }

  void _showLocationSheet(BuildContext context, ClockState clock, ClockNotifier notifier) {
    HapticFeedback.selectionClick();
    final c = context.c;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: c.bgSurfaceRaised,
          borderRadius: Rd.sheetTop,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: c.borderStrong,
                  borderRadius: Rd.rFull,
                ),
              ),
            ),
            const SizedBox(height: Sp.s3),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Work Mode & Location', style: T.h2.col(c.textPrimary)),
                      Text(
                        'Select where you are working today',
                        style: T.caption.col(c.textSecondary),
                      ),
                    ],
                  ),
                ),
                HrmIconButton(
                  icon: LucideIcons.x,
                  label: 'Close',
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: Sp.s4),
            _LocationOption(
              icon: LucideIcons.building2,
              title: 'In-Office (Head Office)',
              subtitle: 'Within office geofence · Automated attendance verification',
              selected: !clock.isOutwork,
              accentColor: const Color(0xFF10B981),
              onTap: () {
                notifier.setOutwork(isOutwork: false);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: Sp.s2),
            _LocationOption(
              icon: LucideIcons.briefcase,
              title: 'Outwork / Field Duty',
              subtitle: 'Client site, customer meeting, or external duty outside geofence',
              selected: clock.isOutwork,
              accentColor: const Color(0xFFEA580C),
              onTap: () {
                notifier.setOutwork(isOutwork: true);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: Sp.s3),
            HrmButton(
              'Submit Detailed Outwork Request',
              kind: BtnKind.secondary,
              icon: LucideIcons.filePlus,
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/outwork/request');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clock = widget.clock;
    final notifier = ref.read(clockProvider.notifier);
    final phase = clock.phase;
    final idle = phase == ClockPhase.idle || phase == ClockPhase.confirming;
    final label = switch (phase) {
      ClockPhase.idle => clock.isOutwork ? 'Outwork idle' : 'Not clocked in',
      ClockPhase.confirming => 'Confirming',
      ClockPhase.working => clock.isOutwork ? 'Working · Outwork' : 'Working',
      ClockPhase.onBreak => 'On break',
    };
    final effectiveTimeOfDay = _previewTimeOfDay ?? resolveShiftTimeOfDay();
    final timeBadge = switch (_previewTimeOfDay) {
      null => 'Shift 9:00 – 18:00',
      ShiftTimeOfDay.morning => 'Shift · ☀️ Morning',
      ShiftTimeOfDay.afternoon => 'Shift · 🌤️ Afternoon',
      ShiftTimeOfDay.evening => 'Shift · 🌅 Evening',
      ShiftTimeOfDay.night => 'Shift · 🌙 Night',
    };

    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _cycleTimeOfDay,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _previewTimeOfDay == null ? 0.16 : 0.28),
                    borderRadius: Rd.rFull,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: _previewTimeOfDay == null ? 0.22 : 0.45),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.calendarClock, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        timeBadge,
                        style: T.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _Pill(label, phase: phase, isOutwork: clock.isOutwork),
            ],
          ),
          const SizedBox(height: Sp.s4),
          Center(
            child: GestureDetector(
              onTap: _cycleTimeOfDay,
              behavior: HitTestBehavior.opaque,
              child: ProgressRing(
                value: clock.progress,
                size: 174,
                stroke: 6.5,
                color: Colors.white,
                track: Colors.white.withValues(alpha: 0.18),
                duration: 1.seconds,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShiftIllustration(
                      phase: phase,
                      timeOfDay: effectiveTimeOfDay,
                      size: 52,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      clock.text,
                      style: T.h1.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ).tnum,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      idle ? (clock.isOutwork ? 'Outwork · Ready when you are' : 'Ready when you are') : 'of a 9h shift',
                      style: T.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Sp.s4),
          if (idle)
            SwipeToConfirm(
              label: clock.isOutwork
                  ? 'Swipe to clock in (Outwork)'
                  : 'Swipe to clock in',
              confirming: phase == ClockPhase.confirming,
              onConfirmed: notifier.clockIn,
            )
          else
            Row(
              spacing: Sp.s3,
              children: [
                Expanded(
                  child: _HeroButton(
                    phase == ClockPhase.onBreak ? 'End break' : 'Take break',
                    onTap: notifier.toggleBreak,
                  ),
                ),
                Expanded(
                  child: _HeroButton('Clock out',
                      filled: true, onTap: notifier.clockOut),
                ),
              ],
            ),
          const SizedBox(height: Sp.s3),
          Center(
            child: GestureDetector(
              onTap: () => _showLocationSheet(context, clock, notifier),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: clock.isOutwork
                      ? const Color(0xFFEA580C).withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: Rd.rFull,
                  border: Border.all(
                    color: clock.isOutwork
                        ? const Color(0xFFFDBA74).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: clock.isOutwork
                            ? const Color(0xFFFB923C)
                            : const Color(0xFF34D399),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: clock.isOutwork
                                ? const Color(0x99FB923C)
                                : const Color(0x8034D399),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      clock.isOutwork ? LucideIcons.briefcase : LucideIcons.mapPin,
                      size: 13.5,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      clock.isOutwork
                          ? 'Outwork · ${clock.location}'
                          : 'Head Office · Geofence verified',
                      style: T.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  const _LocationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(Sp.s3),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: c.isDark ? 0.2 : 0.08)
              : c.bgSurface,
          borderRadius: Rd.rMd,
          border: Border.all(
            color: selected
                ? accentColor.withValues(alpha: c.isDark ? 0.5 : 0.4)
                : c.borderDefault,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? accentColor : c.bgSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : c.textSecondary,
              ),
            ),
            const SizedBox(width: Sp.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: T.bodyStrong.copyWith(
                      color: c.textPrimary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: T.caption.col(c.textSecondary)),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.circleCheck, size: 20, color: accentColor)
            else
              Icon(LucideIcons.circle, size: 20, color: c.borderStrong),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {this.phase = ClockPhase.idle, this.isOutwork = false});
  final String label;
  final ClockPhase phase;
  final bool isOutwork;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (phase) {
      ClockPhase.working =>
        isOutwork ? const Color(0xFFFB923C) : const Color(0xFF34D399),
      ClockPhase.onBreak => const Color(0xFFFBBF24),
      _ => isOutwork ? const Color(0xFFFB923C) : Colors.white.withValues(alpha: 0.75),
    };
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: Rd.rFull,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: T.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton(this.label, {required this.onTap, this.filled = false});
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: onTap,
      haptic: true,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: Rd.rMd,
        ),
        child: Text(label,
            style: T.label.col(filled ? c.heroFrom : Colors.white)),
      ),
    );
  }
}

class _LeaveTile extends StatelessWidget {
  const _LeaveTile();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return HrmCard(
      onTap: () => context.go('/leave'),
      child: SizedBox(
        height: 124,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: HrmColors.leaveAnnual.withValues(alpha: c.isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.calendarDays, size: 14, color: HrmColors.leaveAnnual),
              ),
              const SizedBox(width: Sp.s2),
              Expanded(
                child: Text('Leave balance',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
              ),
            ]),
            const Spacer(),
            Row(
              children: [
                const ProgressRing(
                    value: 8 / 12, color: HrmColors.leaveAnnual, size: 56, stroke: 6.5),
                const SizedBox(width: Sp.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountUp(8, style: T.h1.col(c.textPrimary).tnum),
                      Text('of 12 days left',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.caption.col(c.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text('Annual leave', style: T.caption.copyWith(color: c.textTertiary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _PaydayTile extends StatelessWidget {
  const _PaydayTile();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return HrmCard(
      onTap: () => context.go('/payroll'),
      child: SizedBox(
        height: 124,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: c.isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.wallet, size: 14, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: Sp.s2),
              Expanded(
                child: Text('Next payday',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.label.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600)),
              ),
            ]),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                CountUp(27, style: T.h1.col(c.textPrimary).tnum),
                const SizedBox(width: 4),
                Text('days', style: T.label.col(c.textSecondary)),
              ],
            ),
            const SizedBox(height: Sp.s2),
            const ProgressBar(value: 0.12, height: 6),
            const Spacer(),
            Text('30 Nov 2026', style: T.caption.copyWith(color: c.textTertiary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _AskHrBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PressScale(
      onTap: () => context.push('/ask-hr'),
      semanticLabel: 'Ask HR, AI assistant',
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: Sp.s4),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: Rd.rLg,
          border: Border.all(
            color: c.primary500.withValues(alpha: c.isDark ? 0.35 : 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: c.primary500.withValues(alpha: c.isDark ? 0.12 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.primary500, c.heroTo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: c.primary500.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
            ),
            const SizedBox(width: Sp.s3),
            Expanded(
              child: Text(
                'How many sick days do I have left?',
                style: T.body.copyWith(
                  color: c.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate(onPlay: (ctl) => ctl.repeat())
                  .shimmer(duration: 3.seconds, color: c.textPrimary),
            ),
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.primary500, c.heroTo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: Rd.rFull,
              ),
              child: Text(
                'Ask AI',
                style: T.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final items = [
      (
        LucideIcons.calendarDays,
        'Leave',
        '/leave/request',
        c.isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
        const Color(0xFF6366F1),
      ),
      (
        LucideIcons.briefcase,
        'Outwork',
        '/outwork/request',
        c.isDark ? const Color(0xFF3B1A05) : const Color(0xFFFFF7ED),
        const Color(0xFFEA580C),
      ),
      (
        LucideIcons.house,
        'Work from home',
        '/leave/request',
        c.isDark ? const Color(0xFF3B2A05) : const Color(0xFFFEF3C7),
        const Color(0xFFF59E0B),
      ),
      (
        LucideIcons.receipt,
        'Expense',
        '/expenses',
        c.isDark ? const Color(0xFF052E16) : const Color(0xFFECFDF5),
        const Color(0xFF10B981),
      ),
      (
        LucideIcons.fileText,
        'Docs',
        '/documents',
        c.isDark ? const Color(0xFF082F49) : const Color(0xFFF0F9FF),
        const Color(0xFF0EA5E9),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            PressScale(
              onTap: () => context.push(items[i].$3),
              scale: 0.93,
              semanticLabel: items[i].$2,
              child: SizedBox(
                width: 68,
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: items[i].$4,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: items[i].$5.withValues(alpha: c.isDark ? 0.3 : 0.18),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: items[i].$5.withValues(alpha: c.isDark ? 0.15 : 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(items[i].$1, size: 24, color: items[i].$5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      items[i].$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: T.caption.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1) const SizedBox(width: Sp.s3),
          ],
        ],
      ),
    );
  }
}

class _AnnouncementRow extends StatelessWidget {
  const _AnnouncementRow();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget card({
      required Gradient gradient,
      required Tone tone,
      required String badge,
      required String title,
      required String meta,
    }) =>
        PressScale(
          onTap: () => context.push('/announcements'),
          child: Container(
            width: 260,
            decoration: BoxDecoration(
              color: c.bgSurface,
              borderRadius: Rd.rLg,
              border: Border.all(color: c.borderDefault),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 96,
                  decoration: BoxDecoration(gradient: gradient),
                  child: Stack(
                    children: [
                      Positioned(
                          right: -30,
                          top: -40,
                          child: _blob(120, 0.12, circle: true)),
                      Positioned(
                          left: 24, bottom: -14, child: _blob(60, 0.14, circle: false)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.s4, Sp.s3, Sp.s4, Sp.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      HrmBadge(badge, tone: tone),
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.bodyStrong.col(c.textPrimary)),
                      Text(meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.caption.col(c.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        children: [
          card(
            gradient: c.heroGradient,
            tone: Tone.warning,
            badge: 'Needs acknowledgement',
            title: 'Updated remote work policy',
            meta: 'Farhana Islam · Yesterday',
          ),
          const SizedBox(width: Sp.s3),
          card(
            gradient: LinearGradient(colors: [c.secondary500, c.primary500]),
            tone: Tone.info,
            badge: 'Event',
            title: 'Year-end party, 18 Dec',
            meta: 'People team · 2 days ago',
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, double alpha, {required bool circle}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: alpha),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(18),
        ),
      );
}
