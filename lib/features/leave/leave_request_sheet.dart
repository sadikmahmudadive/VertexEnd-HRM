import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_state.dart';
import '../../core/ui.dart';
import '../../data/mock_data.dart';

/// Bottom-sheet style leave request, shown as a transparent route.
class LeaveRequestSheet extends ConsumerStatefulWidget {
  const LeaveRequestSheet({super.key});

  @override
  ConsumerState<LeaveRequestSheet> createState() => _LeaveRequestSheetState();
}

class _LeaveRequestSheetState extends ConsumerState<LeaveRequestSheet> {
  String _type = 'annual';
  int? _start = 12;
  int? _end = 16;
  bool _half = false;
  final _reason = TextEditingController(text: 'Family function in Chattogram.');

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  int get _leftOfType => switch (_type) {
        'sick' => 3,
        'wfh' => 3,
        _ => 8,
      };

  double get _days {
    if (_start == null) return 0;
    final e = _end ?? _start!;
    var n = 0;
    for (var d = _start!; d <= e; d++) {
      if (!Mock.isWeekendNov(d)) n++;
    }
    if (_half && _start == e && n == 1) return 0.5;
    return n.toDouble();
  }

  void _pick(int d) {
    if (d < 3) return;
    setState(() {
      if (_start == null || _end != null) {
        _start = d;
        _end = null;
      } else if (d < _start!) {
        _start = d;
      } else {
        _end = d;
      }
    });
  }

  String _fmt(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final days = _days;
    final left = _leftOfType - days;
    final valid = days > 0 && left >= 0;
    final end = _end ?? _start;
    final range = _start == null
        ? 'Pick your dates'
        : (_start == end ? '$_start Nov 2026' : '$_start Nov – $end Nov 2026');
    final needsDoc = _type == 'sick' && days > 1;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.88,
          decoration: BoxDecoration(
            color: c.bgSurfaceRaised,
            borderRadius: Rd.sheetTop,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                          color: c.borderStrong, borderRadius: Rd.rFull)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('Request leave',
                                style: T.h2.col(c.textPrimary))),
                        HrmIconButton(
                            icon: LucideIcons.x,
                            label: 'Close',
                            onTap: () => context.pop()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 120 + bottom),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const Overline('Leave type'),
                        Wrap(
                          spacing: Sp.s2,
                          runSpacing: Sp.s2,
                          children: [
                            for (final t in Mock.leaveTypes.where((t) => t.id != 'comp'))
                              HrmChip(
                                t.name,
                                selected: _type == t.id,
                                dot: t.color,
                                sub: '${t.left} days',
                                height: 40,
                                onTap: () => setState(() => _type = t.id),
                              ),
                          ],
                        ),
                        if (needsDoc) ...[
                          const SizedBox(height: Sp.s3),
                          const StatusBanner(
                            tone: Tone.warning,
                            text:
                                'Sick leave over 1 day needs a medical certificate. Attach it below.',
                          ).rise(),
                        ],
                        const SizedBox(height: Sp.s4),
                        Row(
                          children: [
                            const Expanded(child: Overline('Dates')),
                            Text(range, style: T.caption.col(c.textSecondary).tnum),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Text('November 2026',
                                    style: T.bodyStrong.col(c.textPrimary))),
                            Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                    color: c.warning, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Teammates off', style: T.caption.col(c.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: Sp.s2),
                        _Calendar(start: _start, end: _end, onPick: _pick),
                        const SizedBox(height: Sp.s2),
                        Row(
                          children: [
                            Expanded(child: Text('Half day', style: T.label.weight(FontWeight.w500).col(c.textPrimary))),
                            HrmSwitch(
                                label: 'Half day',
                                value: _half,
                                onChanged: (v) => setState(() => _half = v)),
                          ],
                        ),
                        HrmField(
                          label: 'Reason (optional)',
                          controller: _reason,
                          maxLines: 3,
                          maxLength: 250,
                          helper: '${_reason.text.length} / 250',
                          onChanged: (_) => setState(() {}),
                        ),
                        if (needsDoc) ...[
                          const SizedBox(height: Sp.s4),
                          Container(
                            padding: const EdgeInsets.all(Sp.s5),
                            decoration: BoxDecoration(
                              borderRadius: Rd.rLg,
                              border: Border.all(color: c.borderStrong, width: 2),
                            ),
                            child: Column(
                              children: [
                                Icon(LucideIcons.fileText, size: 24, color: c.textSecondary),
                                const SizedBox(height: 4),
                                Text('Add a medical certificate',
                                    style: T.bodyStrong.col(c.textPrimary)),
                                Text('Drop a file, or take a photo',
                                    style: T.caption.col(c.textSecondary)),
                              ],
                            ),
                          ).rise(),
                        ],
                        const SizedBox(height: Sp.s4),
                        AnimatedContainer(
                          duration: Motion.base,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Sp.s4, vertical: Sp.s3),
                          decoration: BoxDecoration(
                            color: left < 0 ? c.dangerSoft : c.infoSoft,
                            borderRadius: Rd.rMd,
                          ),
                          child: Row(
                            children: [
                              Text(_fmt(days), style: T.h2.col(c.textPrimary).tnum),
                              const SizedBox(width: Sp.s3),
                              Expanded(
                                child: Text(
                                  left < 0
                                      ? 'Not enough balance. Pick fewer days.'
                                      : days == 0
                                          ? 'Pick a weekday to continue.'
                                          : '${days == 1 ? 'working day' : 'working days'} · Balance after: ${_fmt(left)} days',
                                  style: T.label.col(c.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 12 + bottom),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [c.bgSurfaceRaised, c.bgSurfaceRaised.withValues(alpha: 0)],
                      stops: const [0.7, 1],
                    ),
                  ),
                  child: HrmButton('Submit request',
                      onPressed: valid
                          ? () {
                              try {
                                final auth = ref.read(authServiceProvider);
                                final profile = ref.read(userProfileProvider);
                                final firestore = ref.read(firestoreServiceProvider);
                                firestore.createLeaveRequest(
                                  userId: auth.currentUserId,
                                  userName: profile.name,
                                  leaveType: _type,
                                  dates: range,
                                  length: '${_fmt(days)} days',
                                  reason: _reason.text.trim(),
                                );
                              } catch (_) {}
                              context.go('/leave/sent');
                            }
                          : null),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 650.ms, curve: Motion.spring);
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.start, required this.end, required this.onPick});
  final int? start;
  final int? end;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cells = <int?>[for (var i = 0; i < 6; i++) null, for (var d = 1; d <= 30; d++) d];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return Column(
      children: [
        Row(
          children: [
            for (final d in const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'])
              Expanded(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(d, style: T.overline.col(c.textSecondary)),
              ))),
          ],
        ),
        for (var r = 0; r < cells.length ~/ 7; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (var k = 0; k < 7; k++) Expanded(child: _day(context, cells[r * 7 + k])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _day(BuildContext context, int? d) {
    final c = context.c;
    if (d == null) return const SizedBox(height: 40);
    final e = end ?? start;
    final isStart = start == d;
    final isEnd = e == d;
    final mid = start != null && e != null && d > start! && d < e;
    final off = d < 3;
    final weekend = Mock.isWeekendNov(d);
    final dot = Mock.teamOffNov.contains(d);
    final selected = isStart || isEnd;
    BorderRadius? radius;
    if (selected) {
      final single = isStart && isEnd;
      radius = single
          ? Rd.rFull
          : isStart
              ? const BorderRadius.horizontal(left: Radius.circular(999))
              : const BorderRadius.horizontal(right: Radius.circular(999));
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: off ? null : () => onPick(d),
      child: Semantics(
        label: '$d November',
        button: !off,
        selected: selected,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: selected
                ? c.primary500
                : mid
                    ? c.primary50
                    : Colors.transparent,
            borderRadius: radius,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('$d',
                  style: T.label
                      .weight(selected ? FontWeight.w600 : FontWeight.w400)
                      .col(selected
                          ? c.textOnPrimary
                          : mid
                              ? c.primary600
                              : off
                                  ? c.textTertiary
                                  : weekend
                                      ? c.textSecondary
                                      : c.textPrimary)
                      .tnum),
              if (dot)
                Positioned(
                  bottom: 3,
                  child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                          color: selected ? c.textOnPrimary : c.warning,
                          shape: BoxShape.circle)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
