import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';
import '../../data/mock_data.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = Mock.people.firstWhere((e) => e.id == id, orElse: () => Mock.people[2]);
    final first = p.name.split(' ').first;
    final present = p.presence == Presence.inOffice || p.presence == Presence.onBreak;

    return HrmScreen(
      actions: [HrmIconButton(icon: LucideIcons.ellipsis, label: 'More', onTap: () {})],
      children: [
        Column(
          children: [
            HrmAvatar(p.initials,
                size: 96, variant: p.variant, presence: p.presence, ringColor: c.bgCanvas),
            const SizedBox(height: Sp.s3),
            Text(p.name, style: T.h2.col(c.textPrimary)),
            Text('${p.role} · ${p.dept}', style: T.body.col(c.textSecondary)),
            const SizedBox(height: Sp.s3),
            Wrap(spacing: Sp.s2, runSpacing: Sp.s2, alignment: WrapAlignment.center, children: [
              HrmBadge(p.status,
                  tone: present
                      ? Tone.success
                      : p.presence == Presence.onLeave
                          ? Tone.info
                          : Tone.neutral),
              const HrmBadge('Local time 2:14 PM'),
            ]),
          ],
        ).rise(1),
        Row(
          children: [
            _Action(LucideIcons.phone, 'Call', 'Call $first'),
            _Action(LucideIcons.messageCircle, 'Message', 'Message $first'),
            _Action(LucideIcons.mail, 'Email', 'Email $first'),
            _Action(LucideIcons.video, 'Video', 'Video call $first'),
          ],
        ).rise(2),
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Sp.s4,
            children: [
              Text('Team', style: T.label.col(c.textSecondary)),
              const Center(child: _OrgChart()),
            ],
          ),
        ).rise(3),
        HrmList(children: [
          _Kv('Department', p.dept),
          const _Kv('Location', 'Head Office, Dhaka'),
          const _Kv('Works', '9:00 – 18:00'),
          const _Kv('Joined', '3 Mar 2021'),
          const _Kv('Birthday', '14 Aug'),
        ]).rise(4),
        const SectionHeader('Skills').rise(5),
        const Wrap(spacing: Sp.s2, runSpacing: Sp.s2, children: [
          _Skill('Team leadership'),
          _Skill('System design'),
          _Skill('Mentoring'),
          _Skill('Hiring'),
        ]).rise(5),
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Back to directory', style: T.label.col(c.primary500)),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, this.semantic);
  final IconData icon;
  final String label;
  final String semantic;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: PressScale(
        onTap: () => showHrmToast(context, '$label is not connected yet', bottom: 32),
        scale: 0.92,
        semanticLabel: semantic,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: c.primary50, shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: c.primary600),
            ),
            const SizedBox(height: 6),
            Text(label, style: T.caption.col(c.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  const _Kv(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.s4),
        child: Row(
          children: [
            Expanded(child: Text(k, style: T.label.weight(FontWeight.w400).col(c.textSecondary))),
            Text(v, style: T.label.weight(FontWeight.w400).col(c.textPrimary).tnum),
          ],
        ),
      ),
    );
  }
}

class _Skill extends StatelessWidget {
  const _Skill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: Sp.s3),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.bgSubtle, borderRadius: Rd.rFull),
      child: Text(text, style: T.caption.col(c.textPrimary)),
    );
  }
}

class _OrgChart extends StatelessWidget {
  const _OrgChart();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget node(String initials, String name, String role,
            {int variant = 0, bool me = false}) =>
        Container(
          padding: const EdgeInsets.fromLTRB(6, 6, Sp.s3, 6),
          decoration: BoxDecoration(
            color: me ? c.primary50 : c.bgSurface,
            borderRadius: Rd.rFull,
            border: Border.all(color: me ? c.primary500 : c.borderDefault),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HrmAvatar(initials, size: 32, variant: variant),
              const SizedBox(width: Sp.s2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name, style: T.caption.weight(FontWeight.w600).col(me ? c.primary600 : c.textPrimary)),
                  Text(role, style: T.overline.copyWith(fontSize: 11, letterSpacing: 0).col(me ? c.primary600 : c.textSecondary)),
                ],
              ),
            ],
          ),
        );
    Widget kid(String i, String n, String r, int v) => Container(
          width: 100,
          padding: const EdgeInsets.all(Sp.s2),
          decoration: BoxDecoration(
            color: c.bgSurface,
            borderRadius: Rd.rLg,
            border: Border.all(color: c.borderDefault),
          ),
          child: Column(
            children: [
              HrmAvatar(i, size: 32, variant: v),
              const SizedBox(height: 4),
              Text(n, style: T.caption.weight(FontWeight.w600).col(c.textPrimary)),
              Text(r, style: T.caption.col(c.textSecondary)),
            ],
          ),
        );
    return Column(
      children: [
        node('AH', 'Anwar Hossain', 'Chief technology officer', variant: 2),
        Container(width: 2, height: 24, color: c.borderStrong)
            .animate()
            .scaleY(begin: 0, end: 1, alignment: Alignment.topCenter, duration: 600.ms),
        node('KA', 'Karim Ahmed', 'Engineering manager', variant: 1, me: true),
        SizedBox(
          width: 316,
          height: 36,
          child: CustomPaint(painter: _ForkPainter(c.borderStrong)),
        ).animate().fadeIn(delay: 300.ms),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Sp.s2,
          children: [
            kid('SH', 'Sadia H.', 'QA lead', 2).popIn(3),
            kid('TL', 'Tanvir A.', 'Backend', 0).popIn(4),
            kid('+4', '4 more', 'Engineers', 1).popIn(5),
          ],
        ),
      ],
    );
  }
}

class _ForkPainter extends CustomPainter {
  _ForkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final mid = size.width / 2;
    canvas.drawPath(
      Path()
        ..moveTo(mid, 0)
        ..lineTo(mid, 14)
        ..moveTo(50, size.height)
        ..lineTo(50, 14)
        ..lineTo(size.width - 50, 14)
        ..lineTo(size.width - 50, size.height),
      p,
    );
  }

  @override
  bool shouldRepaint(_ForkPainter old) => old.color != color;
}
