import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';
import '../../data/mock_data.dart';

enum _Role { user, ai, typing }

class _Msg {
  _Msg(this.role, {this.text = '', this.source = '', this.ring = false, this.words = 0});
  final _Role role;
  final String text;
  final String source;
  final bool ring;
  int words;

  List<String> get all => text.split(' ');
  bool get done => words >= all.length;
}

class AskHrScreen extends StatefulWidget {
  const AskHrScreen({super.key});

  @override
  State<AskHrScreen> createState() => _AskHrScreenState();
}

class _AskHrScreenState extends State<AskHrScreen> {
  final _input = TextEditingController();
  final _asked = <String>{'How many sick days do I have?'};
  late final List<_Msg> _msgs;
  Timer? _reply;
  Timer? _type;

  @override
  void initState() {
    super.initState();
    final a = Mock.askAnswers['How many sick days do I have?']!;
    _msgs = [
      _Msg(_Role.user, text: 'How many sick days do I have?'),
      _Msg(_Role.ai, text: a.$1, source: a.$2, ring: a.$3, words: 999),
    ];
  }

  @override
  void dispose() {
    _reply?.cancel();
    _type?.cancel();
    _input.dispose();
    super.dispose();
  }

  void _ask(String q) {
    final text = q.trim();
    if (text.isEmpty) return;
    final a = Mock.askAnswers[text] ??
        ("I couldn't find that in the policy documents. Want me to connect you with someone from People?",
            'No matching policy', false);
    final typing = _Msg(_Role.typing);
    setState(() {
      _msgs.add(_Msg(_Role.user, text: text));
      _msgs.add(typing);
      _asked.add(text);
      _input.clear();
    });
    _reply?.cancel();
    _reply = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      final ai = _Msg(_Role.ai, text: a.$1, source: a.$2, ring: a.$3);
      setState(() => _msgs[_msgs.indexOf(typing)] = ai);
      _type?.cancel();
      _type = Timer.periodic(const Duration(milliseconds: 50), (t) {
        if (!mounted) return t.cancel();
        setState(() => ai.words++);
        if (ai.done) t.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final chips = Mock.askAnswers.keys.where((q) => !_asked.contains(q)).toList();
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: c.bgCanvas,
      resizeToAvoidBottomInset: true,
      body: HrmBackground(
        child: Column(
          children: [
            Glass(
              radius: 0,
              shadow: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(Sp.s4, top + 6, Sp.s3, 10),
                child: Row(
                  children: [
                    HrmIconButton(
                        icon: LucideIcons.chevronLeft,
                        label: 'Back',
                        onTap: () => context.pop()),
                    const SizedBox(width: Sp.s3),
                    const _Orb(size: 36),
                    const SizedBox(width: Sp.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ask HR', style: T.bodyStrong.col(c.textPrimary)),
                          Text('AI assistant · answers cite policy',
                              style: T.caption.col(c.textSecondary)),
                        ],
                      ),
                    ),
                    HrmButton('Talk to a human',
                        kind: BtnKind.ghost,
                        size: BtnSize.sm,
                        expand: false,
                        onPressed: () => showHrmToast(context, 'Connecting you to People')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(Sp.s4, Sp.s3, Sp.s4, Sp.s3),
                itemCount: _msgs.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: Sp.s3),
                itemBuilder: (context, i) {
                  if (i == _msgs.length) return const _Intro();
                  return _Bubble(_msgs[_msgs.length - 1 - i]).animate().fadeIn(duration: 300.ms);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  Sp.s4, Sp.s2, Sp.s4, MediaQuery.paddingOf(context).bottom + Sp.s3),
              child: Column(
                spacing: Sp.s3,
                children: [
                  if (chips.isNotEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: chips.length,
                        separatorBuilder: (_, _) => const SizedBox(width: Sp.s2),
                        itemBuilder: (_, i) =>
                            HrmChip(chips[i], height: 40, onTap: () => _ask(chips[i])),
                      ),
                    ),
                  Row(
                    spacing: Sp.s3,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          onSubmitted: _ask,
                          textInputAction: TextInputAction.send,
                          style: T.body.col(c.textPrimary),
                          cursorColor: c.primary500,
                          decoration: InputDecoration(
                            hintText: 'Ask about leave, pay or policies',
                            hintStyle: T.body.col(c.textTertiary),
                            filled: true,
                            fillColor: c.bgSurface,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: Sp.s5, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: Rd.rFull,
                                borderSide: BorderSide(color: c.borderStrong)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: Rd.rFull,
                                borderSide: BorderSide(color: c.primary500, width: 2)),
                          ),
                        ),
                      ),
                      PressScale(
                        onTap: () => _ask(_input.text),
                        scale: 0.94,
                        semanticLabel: 'Send',
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration:
                              BoxDecoration(color: c.primary500, shape: BoxShape.circle),
                          child: Icon(LucideIcons.arrowRight, color: c.textOnPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                  colors: [c.heroFrom, c.secondary500, c.heroTo, c.heroFrom]),
            ),
          ).animate(onPlay: (ctl) => ctl.repeat()).rotate(duration: 6.seconds),
          Icon(LucideIcons.sparkles, size: size * 0.45, color: Colors.white),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(top: Sp.s2, bottom: Sp.s4),
      child: Column(
        children: [
          const _Orb(size: 88),
          const SizedBox(height: Sp.s3),
          Text('What can I help with?', style: T.h2.col(c.textPrimary)),
          const SizedBox(height: Sp.s1),
          SizedBox(
            width: 260,
            child: Text(
              "I answer from your company's policies. AI can make mistakes, so check the source.",
              textAlign: TextAlign.center,
              style: T.caption.col(c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.m);
  final _Msg m;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final maxW = MediaQuery.sizeOf(context).width * 0.86;
    switch (m.role) {
      case _Role.user:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxW),
            padding: const EdgeInsets.symmetric(horizontal: Sp.s4, vertical: Sp.s3),
            decoration: BoxDecoration(
              color: c.primary500,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(m.text, style: T.body.col(c.textOnPrimary)),
          ),
        );
      case _Role.typing:
        return Align(
          alignment: Alignment.centerLeft,
          child: _aiShell(
            c,
            maxW,
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              color: c.textSecondary, shape: BoxShape.circle))
                      .animate(delay: (i * 160).ms, onPlay: (ctl) => ctl.repeat(reverse: true))
                      .scale(begin: const Offset(.6, .6), end: const Offset(1, 1), duration: 500.ms),
              ],
            ),
          ),
        );
      case _Role.ai:
        final shown = m.all.take(m.words).join(' ');
        return Align(
          alignment: Alignment.centerLeft,
          child: _aiShell(
            c,
            maxW,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Sp.s3,
              children: [
                Text(shown, style: T.body.col(c.textPrimary)),
                if (m.ring && m.words >= 3)
                  Container(
                    padding: const EdgeInsets.all(Sp.s3),
                    decoration:
                        BoxDecoration(color: c.bgSubtle, borderRadius: Rd.rMd),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ProgressRing(
                            value: 0.3, color: HrmColors.leaveSick, size: 52, stroke: 8),
                        const SizedBox(width: Sp.s3),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('3 / 10', style: T.h2.col(c.textPrimary).tnum),
                            Text('Sick days left', style: T.caption.col(c.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (m.done)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: Sp.s3),
                    decoration:
                        BoxDecoration(color: c.bgSubtle, borderRadius: Rd.rFull),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.fileText, size: 16, color: c.textPrimary),
                      const SizedBox(width: 6),
                      Flexible(
                          child: Text(m.source,
                              overflow: TextOverflow.ellipsis,
                              style: T.caption.col(c.textPrimary))),
                    ]),
                  ).animate().fadeIn(),
              ],
            ),
          ),
        );
    }
  }

  Widget _aiShell(HrmColors c, double maxW, Widget child) => Container(
        constraints: BoxConstraints(maxWidth: maxW),
        padding: const EdgeInsets.symmetric(horizontal: Sp.s4, vertical: Sp.s3),
        decoration: BoxDecoration(
          color: c.bgSurface,
          border: Border.all(color: c.borderDefault),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
        ),
        child: child,
      );
}
