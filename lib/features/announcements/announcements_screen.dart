import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _cat = 'All';
  bool _acked = false;
  bool _up = false;
  bool _party = false;
  String? _rsvp;

  bool _show(String k) => _cat == 'All' || _cat == k;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    var i = 2;
    return HrmScreen(
      title: 'Announcements',
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (final k in const ['All', 'Policy', 'Events', 'People']) ...[
                HrmChip(k, selected: _cat == k, onTap: () => setState(() => _cat = k)),
                const SizedBox(width: Sp.s2),
              ],
            ],
          ),
        ).rise(1),
        if (_show('Policy'))
          _Post(
            cover: _Cover(
              gradient: c.heroGradient,
              pin: true,
              child: Stack(children: [
                Positioned(right: -40, top: -50, child: _circle(130, 0.12)),
                Positioned(left: -30, bottom: -40, child: _circle(100, 0.12)),
                Center(
                  child: Container(
                    width: 94,
                    height: 58,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                        child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                                color: c.primary500, shape: BoxShape.circle))),
                  ).animate(onPlay: (ctl) => ctl.repeat(reverse: true)).moveY(
                      begin: 0, end: -6, duration: 2.seconds, curve: Curves.easeInOut),
                ),
              ]),
            ),
            badge: const HrmBadge('Needs acknowledgement', tone: Tone.warning),
            title: 'Updated remote work policy',
            body:
                'From 1 December, you can work from home up to two days a week with manager approval. Read the policy, then acknowledge it.',
            author: 'Farhana Islam',
            initials: 'FI',
            when: 'Yesterday',
            extra: [
              if (!_acked)
                HrmButton('Acknowledge', onPressed: () => setState(() => _acked = true))
              else
                Container(
                  padding: const EdgeInsets.all(Sp.s3),
                  decoration: BoxDecoration(color: c.successSoft, borderRadius: Rd.rMd),
                  child: Row(children: [
                    Icon(LucideIcons.check, size: 20, color: c.success),
                    const SizedBox(width: Sp.s2),
                    Expanded(
                        child: Text('You acknowledged this today, 10:02 AM',
                            style: T.label.weight(FontWeight.w400).col(c.textPrimary))),
                  ]),
                ).popIn(),
              Row(spacing: Sp.s2, children: [
                HrmChip('👍 ${12 + (_up ? 1 : 0)}',
                    selected: _up, onTap: () => setState(() => _up = !_up)),
                HrmChip('🎉 ${4 + (_party ? 1 : 0)}',
                    selected: _party, onTap: () => setState(() => _party = !_party)),
              ]),
            ],
          ).rise(i++),
        if (_show('Events'))
          _Post(
            cover: _Cover(
              gradient: LinearGradient(colors: [c.secondary500, c.primary500]),
              child: Stack(children: [
                Positioned(left: -20, top: -30, child: _circle(112, 0.12)),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.s5, vertical: Sp.s3),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('18 Dec',
                        style: T.h2.col(HrmColors.primary700)),
                  ),
                ),
                for (final p in const [
                  (150.0, 24.0, 16.0, false),
                  (230.0, 42.0, 10.0, true),
                  (270.0, 78.0, 14.0, false),
                  (110.0, 84.0, 12.0, true),
                ])
                  Positioned(
                    left: p.$1,
                    top: p.$2,
                    child: Container(
                      width: p.$3,
                      height: p.$3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: p.$4 ? BoxShape.circle : BoxShape.rectangle,
                        borderRadius: p.$4 ? null : BorderRadius.circular(4),
                      ),
                    ).animate(onPlay: (ctl) => ctl.repeat(reverse: true)).moveY(
                        begin: 0, end: 6, duration: 2.seconds, curve: Curves.easeInOut),
                  ),
              ]),
            ),
            badge: const HrmBadge('Event', tone: Tone.info),
            title: 'Year-end party',
            body: 'Friday 18 December, 6 PM at the Head Office rooftop. Bring a plus one.',
            author: 'People team',
            initials: 'PT',
            when: '2 days ago',
            extra: [
              Row(spacing: Sp.s2, children: [
                for (final k in const ['Going', 'Maybe', "Can't make it"])
                  HrmChip(k, selected: _rsvp == k, onTap: () => setState(() => _rsvp = k)),
              ]),
              Text('${38 + (_rsvp == 'Going' ? 1 : 0)} people going',
                  style: T.caption.col(c.textSecondary).tnum),
            ],
          ).rise(i++),
        if (_show('People'))
          HrmCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Sp.s3,
              children: [
                const Align(
                    alignment: Alignment.centerLeft,
                    child: HrmBadge('New joiners', tone: Tone.success)),
                Text('Welcome to the team', style: T.h3.col(c.textPrimary)),
                Row(children: [
                  const AvatarStack(['ZC', 'TL', 'MI'], size: 40),
                  const SizedBox(width: Sp.s3),
                  Expanded(
                      child: Text(
                          'Zara, Tanvir and Mehnaz joined this week. Say hello in the directory.',
                          style: T.label.weight(FontWeight.w400).col(c.textSecondary))),
                ]),
                HrmButton('Open directory',
                    kind: BtnKind.secondary,
                    size: BtnSize.md,
                    onPressed: () => context.push('/directory')),
              ],
            ),
          ).rise(i++),
      ],
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );
}

class _Cover extends StatelessWidget {
  const _Cover({required this.gradient, required this.child, this.pin = false});
  final Gradient gradient;
  final Widget child;
  final bool pin;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 132,
        child: Stack(
          children: [
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: gradient))),
            Positioned.fill(child: child),
            if (pin)
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: Sp.s2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: context.c.bgSurface, borderRadius: Rd.rFull),
                  child: Text('Pinned', style: T.caption.col(context.c.textPrimary)),
                ),
              ),
          ],
        ),
      );
}

class _Post extends StatelessWidget {
  const _Post({
    required this.cover,
    required this.badge,
    required this.title,
    required this.body,
    required this.author,
    required this.initials,
    required this.when,
    required this.extra,
  });
  final Widget cover;
  final Widget badge;
  final String title;
  final String body;
  final String author;
  final String initials;
  final String when;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: Rd.rLg,
        border: Border.all(color: c.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cover,
          Padding(
            padding: const EdgeInsets.all(Sp.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Sp.s3,
              children: [
                Align(alignment: Alignment.centerLeft, child: badge),
                Text(title, style: T.h3.col(c.textPrimary)),
                Text(body, style: T.label.weight(FontWeight.w400).col(c.textSecondary)),
                Row(children: [
                  HrmAvatar(initials, size: 24),
                  const SizedBox(width: Sp.s2),
                  Text('$author · $when', style: T.caption.col(c.textSecondary)),
                ]),
                ...extra,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
