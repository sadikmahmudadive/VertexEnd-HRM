import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_state.dart';
import '../../core/ui.dart';
import '../../core/widgets/charts.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return HrmScreen(
      title: 'Attendance',
      showBack: false,
      bottomPad: 140,
      actions: [
        HrmIconButton(
          icon: LucideIcons.briefcase,
          label: 'Outwork Request',
          onTap: () => context.push('/outwork/request'),
        ),
        HrmIconButton(icon: LucideIcons.slidersHorizontal, label: 'Filters', onTap: () {}),
      ],
      children: [
        HrmSegmented(
          labels: const ['Today', 'History'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ).rise(1),
        AnimatedSwitcher(
          duration: Motion.base,
          switchInCurve: Motion.standard,
          child: _tab == 0
              ? const _Today(key: ValueKey('today'))
              : const _History(key: ValueKey('hist')),
        ),
      ],
    );
  }
}

class _Today extends ConsumerWidget {
  const _Today({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final clock = ref.watch(clockProvider);
    final isOutwork = clock.isOutwork;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Sp.s3,
      children: [
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.s3,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tue, 3 Nov', style: T.caption.col(c.textSecondary)),
                      Text('3h 42m', style: T.display.col(c.textPrimary).tnum),
                    ],
                  ),
                ),
                HrmBadge(
                  isOutwork ? 'Outwork' : 'Working',
                  tone: isOutwork ? Tone.warning : Tone.success,
                ),
              ]),
              const ProgressBar(value: 0.41),
              Row(children: [
                Text('0h', style: T.caption.col(c.textSecondary)),
                const Spacer(),
                Text('9h shift', style: T.caption.col(c.textSecondary)),
              ]),
            ],
          ),
        ).rise(2),
        if (isOutwork)
          Container(
            padding: const EdgeInsets.all(Sp.s3),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: c.isDark ? 0.2 : 0.08),
              borderRadius: Rd.rMd,
              border: Border.all(
                color: const Color(0xFFF97316).withValues(alpha: c.isDark ? 0.35 : 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.briefcase, size: 16, color: Colors.white),
                ),
                const SizedBox(width: Sp.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Outwork Duty Active', style: T.bodyStrong.col(c.textPrimary)),
                      Text('${clock.location} · Geofence exempt',
                          style: T.caption.col(c.textSecondary)),
                    ],
                  ),
                ),
                HrmButton(
                  'Change Site',
                  kind: BtnKind.ghost,
                  size: BtnSize.sm,
                  expand: false,
                  onPressed: () => context.push('/outwork/request'),
                ),
              ],
            ),
          ).rise(3),
        Row(
          children: [
            Expanded(child: Text('Punches', style: T.h3.col(c.textPrimary))),
            const HrmBadge('Late 14 min', tone: Tone.warning),
          ],
        ).rise(3),
        _Timeline(clock: clock).rise(3),
        const GeofenceMap().rise(4),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.clock});
  final ClockState clock;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isOutwork = clock.isOutwork;
    final items = [
      (
        clock.phase == ClockPhase.working
            ? (isOutwork ? 'Outwork active' : 'Working now')
            : 'Working now',
        'Since 1:10 PM',
        'now',
      ),
      ('Break ended · 1:10 PM', '40 min break', 'break'),
      ('Break started · 12:30 PM', 'Lunch', 'break'),
      (
        isOutwork ? 'Clocked in (Outwork) · 9:14 AM' : 'Clocked in · 9:14 AM',
        isOutwork
            ? '${clock.location.isNotEmpty ? clock.location : 'Client Site, Gulshan 2'} · Field duty'
            : 'Head Office, within geofence',
        isOutwork ? 'outwork' : 'in',
      ),
    ];
    return Stack(
      children: [
        Positioned(
          left: 7,
          top: 8,
          bottom: 8,
          child: Container(width: 2, color: c.borderDefault)
              .animate()
              .scaleY(
                  begin: 0,
                  end: 1,
                  alignment: Alignment.topCenter,
                  duration: 1.seconds,
                  curve: Motion.standard),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Sp.s4,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -28,
                      top: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: items[i].$3 == 'now'
                              ? (isOutwork ? const Color(0xFFEA580C) : c.primary500)
                              : c.bgSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: items[i].$3 == 'break'
                                ? c.warning
                                : items[i].$3 == 'outwork'
                                    ? const Color(0xFFEA580C)
                                    : c.primary500,
                            width: 3,
                          ),
                          boxShadow: items[i].$3 == 'now'
                              ? [
                                  BoxShadow(
                                      color: (isOutwork
                                              ? const Color(0xFFEA580C)
                                              : c.primary500)
                                          .withValues(alpha: 0.22),
                                      spreadRadius: 5)
                                ]
                              : null,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].$1, style: T.bodyStrong.col(c.textPrimary)),
                        Text(items[i].$2, style: T.caption.col(c.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ).rise(i),
          ],
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({super.key});

  // October 2026 starts on a Thursday.
  static const _late = [6, 22];
  static const _absent = [13];
  static const _leave = [19, 20, 21];

  (String, Tone?) _status(int d) {
    final dow = (3 + d - 1) % 7;
    if (dow >= 5) return ('Weekend', null);
    if (_late.contains(d)) return ('Late', Tone.warning);
    if (_absent.contains(d)) return ('Absent', Tone.danger);
    if (_leave.contains(d)) return ('On leave', Tone.info);
    return ('Present', Tone.success);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Sp.s3,
      children: [
        Row(children: [
          HrmIconButton(icon: LucideIcons.chevronLeft, label: 'Previous month', onTap: () {}),
          Expanded(
              child: Text('October 2026',
                  textAlign: TextAlign.center, style: T.h3.col(c.textPrimary))),
          HrmIconButton(icon: LucideIcons.chevronRight, label: 'Next month', onTap: () {}),
        ]),
        const Wrap(spacing: 6, runSpacing: 6, children: [
          HrmBadge('Present', tone: Tone.success),
          HrmBadge('Late', tone: Tone.warning),
          HrmBadge('Absent', tone: Tone.danger),
          HrmBadge('On leave', tone: Tone.info),
          HrmBadge('Weekend'),
        ]),
        HrmCard(
          child: Column(
            children: [
              Row(
                children: [
                  for (final d in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
                    Expanded(
                        child: Center(
                            child: Text(d, style: T.caption.col(c.textSecondary)))),
                ],
              ),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: [
                  for (var b = 0; b < 3; b++) const SizedBox.shrink(),
                  for (var d = 1; d <= 31; d++) _cell(context, d),
                ],
              ),
            ],
          ),
        ),
        Row(
          spacing: Sp.s2,
          children: const [
            Expanded(child: _Stat('19', 'Present')),
            Expanded(child: _Stat('2', 'Late')),
            Expanded(child: _Stat('1', 'Absent')),
            Expanded(child: _Stat('3', 'On leave')),
          ],
        ),
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.s3,
            children: [
              Text('Hours per week', style: T.label.col(c.textSecondary)),
              const MiniBarChart(
                values: [41, 44, 38, 42],
                labels: ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
                valueLabels: ['41', '44', '38', '42'],
                min: 30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, int d) {
    final c = context.c;
    final (label, tone) = _status(d);
    final (bg, dot) = tone == null ? (c.neutralSoft, null) : toneColors(c, tone);
    return Semantics(
      label: '$d October, $label',
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: Rd.rXs),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('$d',
                style: T.caption
                    .col(tone == null ? c.textSecondary : c.textPrimary)
                    .tnum),
            if (dot != null)
              Positioned(
                bottom: 4,
                child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              ),
          ],
        ),
      ).popIn(((d + 3) ~/ 7) + (3 + d - 1) % 7),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(Sp.s3),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: Rd.rMd,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountUp(int.parse(value), style: T.h2.col(c.textPrimary).tnum),
          Text(label, style: T.caption.col(c.textSecondary)),
        ],
      ),
    );
  }
}
