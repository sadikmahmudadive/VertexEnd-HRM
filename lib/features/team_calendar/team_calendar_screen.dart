import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class TeamCalendarScreen extends StatefulWidget {
  const TeamCalendarScreen({super.key});

  @override
  State<TeamCalendarScreen> createState() => _TeamCalendarScreenState();
}

class _TeamCalendarScreenState extends State<TeamCalendarScreen> {
  int _week = 0;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _long = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Color _tint(HrmColors c, String type) {
    final base = switch (type) {
      'sick' => HrmColors.leaveSick,
      'wfh' => HrmColors.leaveWfh,
      _ => HrmColors.leaveAnnual,
    };
    return Color.alphaBlend(base.withValues(alpha: type == 'wfh' ? 0.38 : 0.3), c.bgSurface);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final wk = Mock.calendarWeeks[_week];
    final counts = List.filled(7, 0);
    for (final r in wk.rows) {
      for (final b in r.bars) {
        for (var k = b.col; k < b.col + b.span; k++) {
          counts[k - 1]++;
        }
      }
    }
    final max = counts.reduce((a, b) => a > b ? a : b);
    final hi = counts.indexOf(max);

    return HrmScreen(
      title: 'Team calendar',
      children: [
        Row(children: [
          HrmIconButton(
              icon: LucideIcons.chevronLeft,
              label: 'Previous week',
              onTap: () => setState(() => _week = 0)),
          Expanded(
            child: Column(children: [
              Text(wk.range, style: T.h3.col(c.textPrimary)),
              Text(wk.relative, style: T.caption.col(c.textSecondary)),
            ]),
          ),
          HrmIconButton(
              icon: LucideIcons.chevronRight,
              label: 'Next week',
              onTap: () => setState(() => _week = 1)),
        ]).rise(1),
        HrmCard(
          padding: const EdgeInsets.all(Sp.s3),
          child: Column(
            key: ValueKey(_week),
            children: [
              Row(children: [
                const SizedBox(width: 96),
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Column(children: [
                      Text(_days[i],
                          style: T.overline
                              .copyWith(letterSpacing: 0.4)
                              .col(c.textSecondary.withValues(alpha: i > 4 ? 0.7 : 1))),
                      const SizedBox(height: 2),
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: wk.todayIndex == i ? c.primary500 : Colors.transparent,
                            shape: BoxShape.circle),
                        child: Text('${wk.startDay + i}',
                            style: T.label
                                .weight(FontWeight.w600)
                                .col(wk.todayIndex == i ? c.textOnPrimary : c.textPrimary)
                                .tnum),
                      ),
                    ]),
                  ),
              ]),
              const SizedBox(height: 6),
              for (final r in wk.rows) _Row(r, (t) => _tint(c, t)),
              const SizedBox(height: Sp.s2),
              Row(children: [
                SizedBox(width: 96, child: Text('Off', style: T.caption.col(c.textSecondary))),
                for (final n in counts)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: n >= 3 ? c.warningSoft : c.bgSubtle,
                          shape: BoxShape.circle,
                          border: n >= 3 ? Border.all(color: c.warning) : null,
                        ),
                        child: Text('$n', style: T.caption.col(c.textPrimary).tnum),
                      ),
                    ),
                  ),
              ]),
            ],
          ),
        ).rise(2),
        Wrap(spacing: Sp.s3, runSpacing: Sp.s2, children: [
          _Legend(HrmColors.leaveAnnual, 'Annual'),
          _Legend(HrmColors.leaveSick, 'Sick'),
          _Legend(HrmColors.leaveWfh, 'Work from home'),
          _Legend(c.info, 'Holiday'),
        ]).rise(3),
        if (max >= 3)
          StatusBanner(
            tone: Tone.warning,
            text:
                '$max people are off on ${_long[hi]} ${wk.startDay + hi} Nov. Check cover before you approve more.',
          ).rise(4),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.r, this.tint);
  final CalendarRow r;
  final Color Function(String) tint;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Row(children: [
              HrmAvatar(r.initials, size: 24, variant: r.variant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: T.caption.weight(FontWeight.w600).col(c.textPrimary)),
              ),
            ]),
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, box) {
              final col = box.maxWidth / 7;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: col * 5,
                    right: 0,
                    top: 2,
                    bottom: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          color: c.bgSubtle.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  for (final b in r.bars)
                    Positioned(
                      left: col * (b.col - 1) + 2,
                      width: col * b.span - 4,
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            color: tint(b.type), borderRadius: Rd.rFull),
                        child: Text(b.span > 1 ? b.label : '',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: T.caption.weight(FontWeight.w600).col(const Color(0xFF0F172A))),
                      )
                          .animate()
                          .scaleX(
                              begin: 0,
                              end: 1,
                              alignment: Alignment.centerLeft,
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Motion.standard),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.text);
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: T.caption.col(context.c.textSecondary)),
      ]);
}
