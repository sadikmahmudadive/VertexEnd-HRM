import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/ui.dart';
import '../../core/widgets/charts.dart';

enum _Reveal { hidden, verifying, shown }

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  _Reveal _state = _Reveal.hidden;
  Timer? _timer;
  int _month = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    switch (_state) {
      case _Reveal.hidden:
        HapticFeedback.lightImpact();
        setState(() => _state = _Reveal.verifying);
        _timer = Timer(const Duration(milliseconds: 1100), () {
          if (!mounted) return;
          HapticFeedback.mediumImpact();
          setState(() => _state = _Reveal.shown);
        });
      case _Reveal.shown:
        setState(() => _state = _Reveal.hidden);
      case _Reveal.verifying:
        break;
    }
  }

  String _money(int v) {
    if (_state != _Reveal.shown) return '৳ ••••';
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '৳ $buf';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final shown = _state == _Reveal.shown;
    return HrmScreen(
      title: 'Payroll',
      showBack: false,
      bottomPad: 140,
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < 5; i++) ...[
                HrmChip(['Oct 2026', 'Sep', 'Aug', 'Jul', 'Jun'][i],
                    selected: _month == i, onTap: () => setState(() => _month = i)),
                const SizedBox(width: Sp.s2),
              ],
            ],
          ),
        ).rise(1),
        HeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.s3,
            children: [
              Text('Net pay · October 2026',
                  style: T.body.col(Colors.white.withValues(alpha: 0.92))),
              Row(
                children: [
                  Expanded(
                    child: shown
                        ? CountUp(56600,
                            duration: const Duration(milliseconds: 900),
                            style: T.display.copyWith(fontSize: 40, height: 1.15, color: Colors.white).tnum,
                            format: (n) => _money(n).replaceAll('••••', '$n'))
                        : Text('৳ ••••••',
                            style: T.display
                                .copyWith(
                                    fontSize: 40,
                                    height: 1.15,
                                    letterSpacing: 4,
                                    color: Colors.white)),
                  ),
                  _EyeButton(state: _state, onTap: _toggle),
                ],
              ),
              if (_state == _Reveal.verifying)
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: Sp.s2),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: Rd.rFull),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle))
                        .animate(onPlay: (ctl) => ctl.repeat(reverse: true))
                        .fade(begin: .3, end: 1, duration: 500.ms),
                    const SizedBox(width: Sp.s2),
                    Text('Verifying with Face ID', style: T.caption.col(Colors.white)),
                  ]),
                ).animate().fadeIn()
              else
                Text(
                  _state == _Reveal.hidden
                      ? 'Tap the eye to reveal. Hidden again when you leave this screen.'
                      : 'Paid 30 Oct to account ••4821',
                  style: T.caption.col(Colors.white.withValues(alpha: 0.9)),
                ),
            ],
          ),
        ).rise(2),
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s3,
            children: [
              SegmentBar(segments: [
                (0.913, c.primary500),
                (0.087, c.warning),
              ]),
              Row(
                children: [
                  _Legend(c.primary500, 'Take-home 91%'),
                  const Spacer(),
                  _Legend(c.warning, 'Deductions 9%'),
                ],
              ),
              _Breakdown(
                title: 'Earnings',
                total: _money(62000),
                open: true,
                rows: [
                  ('Basic', _money(36000)),
                  ('House rent', _money(18000)),
                  ('Medical', _money(4000)),
                  ('Conveyance', _money(4000)),
                ],
              ),
              _Breakdown(
                title: 'Deductions',
                total: _money(5400),
                rows: [('Income tax', _money(1800)), ('Provident fund', _money(3600))],
              ),
              Divider(height: 1, color: c.borderDefault),
              Row(
                spacing: Sp.s2,
                children: [
                  Expanded(
                      child: HrmButton('Download PDF',
                          kind: BtnKind.secondary,
                          size: BtnSize.md,
                          icon: LucideIcons.download,
                          onPressed: () => showHrmToast(context, 'October payslip saved to Files'))),
                  HrmButton('Share',
                      kind: BtnKind.ghost, size: BtnSize.md, expand: false, onPressed: () {}),
                ],
              ),
            ],
          ),
        ).rise(3),
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.s3,
            children: [
              Text('Net pay, last 6 months', style: T.label.col(c.textSecondary)),
              MiniBarChart(
                values: const [54.2, 54.2, 55.0, 56.6, 56.6, 56.6],
                labels: const ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
                valueLabels: [for (final v in const [54, 54, 55, 57, 57, 57]) shown ? '${v}k' : '•••'],
                highlight: 5,
                height: 112,
                min: 50,
              ),
            ],
          ),
        ).rise(4),
        const SectionHeader('Earlier payslips').rise(5),
        HrmList(children: [
          HrmListTile(
            minHeight: 72,
            leading: const LeadIcon(LucideIcons.receipt),
            title: 'September 2026',
            subtitle: 'Paid 30 Sep',
            trailing: Text(_money(56600), style: T.body.col(c.textSecondary).tnum),
          ),
          HrmListTile(
            minHeight: 72,
            leading: const LeadIcon(LucideIcons.receipt),
            title: 'August 2026',
            subtitle: 'Paid 31 Aug',
            trailing: Text(_money(56600), style: T.body.col(c.textSecondary).tnum),
          ),
        ]).rise(5),
      ],
    );
  }
}

class _EyeButton extends StatelessWidget {
  const _EyeButton({required this.state, required this.onTap});
  final _Reveal state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = switch (state) {
      _Reveal.hidden => EyesMood.watchful,
      _Reveal.verifying => EyesMood.scanning,
      _Reveal.shown => EyesMood.happy,
    };

    return PressScale(
      onTap: onTap,
      scale: 0.92,
      semanticLabel: state == _Reveal.shown ? 'Hide net pay' : 'Show net pay',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: state == _Reveal.verifying ? 0.28 : 0.20),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: state == _Reveal.verifying ? 0.45 : 0.26),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            if (state == _Reveal.verifying)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Center(
          child: AnimatedEyes(
            mood: mood,
            width: 32,
            height: 20,
            pupilColor: const Color(0xFF2E1065),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.text);
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: T.caption.col(context.c.textSecondary)),
      ]);
}

class _Breakdown extends StatefulWidget {
  const _Breakdown({
    required this.title,
    required this.total,
    required this.rows,
    this.open = false,
  });
  final String title;
  final String total;
  final List<(String, String)> rows;
  final bool open;

  @override
  State<_Breakdown> createState() => _BreakdownState();
}

class _BreakdownState extends State<_Breakdown> {
  late bool _open = widget.open;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        Divider(height: 1, color: c.borderDefault),
        PressScale(
          onTap: () => setState(() => _open = !_open),
          scale: 0.99,
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(child: Text(widget.title, style: T.bodyStrong.col(c.textPrimary))),
                Text(widget.total, style: T.body.col(c.textPrimary).tnum),
                const SizedBox(width: Sp.s2),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: Motion.base,
                  child: Icon(LucideIcons.chevronDown, size: 18, color: c.textSecondary),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: Motion.base,
          curve: Motion.standard,
          alignment: Alignment.topCenter,
          child: _open
              ? Column(
                  children: [
                    for (final r in widget.rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(r.$1, style: T.label.weight(FontWeight.w400).col(c.textSecondary))),
                            Text(r.$2, style: T.label.weight(FontWeight.w400).col(c.textPrimary).tnum),
                          ],
                        ),
                      ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
