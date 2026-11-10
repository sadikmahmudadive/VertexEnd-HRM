import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final rows = _tab == 0 ? Mock.upcomingLeave : Mock.pastLeave;
    return HrmScreen(
      title: 'Leave',
      showBack: false,
      bottomPad: 140,
      actions: [
        HrmIconButton(
          icon: LucideIcons.calendarDays,
          label: 'Team calendar',
          onTap: () => context.push('/team-calendar'),
        ),
      ],
      children: [
        SizedBox(
          height: 152,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            children: [
              for (final t in Mock.leaveTypes) ...[
                _BalanceCard(t),
                const SizedBox(width: Sp.s3),
              ],
            ],
          ),
        ).rise(1),
        HrmButton('Request leave',
                icon: LucideIcons.plus,
                onPressed: () => context.push('/leave/request'))
            .rise(2),
        HrmCard(
          child: Row(
            children: [
              const SizedBox(width: 70, height: 60, child: _PalmArt()),
              const SizedBox(width: Sp.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const HrmBadge('Pending', tone: Tone.warning),
                    Text('Annual leave · 3 days',
                        style: T.bodyStrong.col(c.textPrimary)),
                    Text('12 – 16 Nov · Tahmina is reviewing',
                        style: T.caption.col(c.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ).rise(3),
        HrmSegmented(
          labels: const ['Upcoming', 'Past'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ).rise(4),
        AnimatedSwitcher(
          duration: Motion.base,
          child: HrmList(
            key: ValueKey(_tab),
            children: [for (final e in rows) _EntryTile(e)],
          ),
        ).rise(4),
        const SectionHeader('Public holidays').rise(5),
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: const [
              _Holiday('16', 'Dec', 'Victory Day', 'Wednesday'),
              SizedBox(width: Sp.s3),
              _Holiday('25', 'Dec', 'Christmas Day', 'Friday'),
            ],
          ),
        ).rise(5),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(this.t);
  final LeaveType t;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: 132,
      child: HrmCard(
        padding: const EdgeInsets.symmetric(vertical: Sp.s4, horizontal: Sp.s3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProgressRing(
                value: t.left / t.total, color: t.color, size: 64, stroke: 9),
            const SizedBox(height: Sp.s2),
            Text('${t.left} / ${t.total} days',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: T.bodyStrong.col(c.textPrimary).tnum),
            Text(t.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: T.caption.col(c.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.e);
  final LeaveEntry e;

  @override
  Widget build(BuildContext context) => HrmListTile(
        minHeight: 72,
        leading: DateBlock(e.day, e.month),
        title: e.title,
        subtitle: e.sub,
        trailing: HrmBadge(e.status, tone: e.tone),
      );
}

class _Holiday extends StatelessWidget {
  const _Holiday(this.day, this.month, this.name, this.weekday);
  final String day;
  final String month;
  final String name;
  final String weekday;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 184,
      padding: const EdgeInsets.symmetric(horizontal: Sp.s3, vertical: Sp.s2),
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: Rd.rLg,
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        children: [
          DateBlock(day, month, info: true),
          const SizedBox(width: Sp.s3),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.label.col(c.textPrimary),
                ),
                Text(
                  weekday,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: T.caption.col(c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PalmArt extends StatelessWidget {
  const _PalmArt();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PalmPainter(context.c));
}

class _PalmPainter extends CustomPainter {
  _PalmPainter(this.c);
  final HrmColors c;

  @override
  void paint(Canvas cv, Size size) {
    cv.scale(size.width / 96, size.height / 80);
    cv.drawCircle(const Offset(70, 22), 12, Paint()..color = HrmColors.leaveWfh);
    cv.drawOval(const Rect.fromLTWH(6, 60, 80, 16),
        Paint()..color = c.secondary500.withValues(alpha: 0.4));
    cv.drawPath(
        Path()
          ..moveTo(42, 68)
          ..relativeCubicTo(3, -14, 2, -24, 6, -36),
        Paint()
          ..color = c.textSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
    final leaf = Paint()..color = c.secondary500;
    void l(double dx, double dy) => cv.drawPath(
        Path()
          ..moveTo(48, 32)
          ..relativeQuadraticBezierTo(dx * .5, dy - 8, dx, 0)
          ..relativeQuadraticBezierTo(-dx * .5, -2, -dx, 0)
          ..close(),
        leaf);
    l(-27, -10);
    l(27, -10);
    l(-25, -18);
    l(25, -18);
  }

  @override
  bool shouldRepaint(_PalmPainter old) => old.c != c;
}
