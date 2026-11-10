import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctl = PageController();
  int _page = 0;

  static const _slides = [
    ('Clock in with a swipe',
        'Check in from the office in two taps. We confirm your location, so you don\'t have to explain it.'),
    ('Leave without the back and forth',
        'See your balance, pick your dates, and know who approves it before you send.'),
    ('Your pay, kept private',
        'Payslips stay hidden until you reveal them with Face ID or your fingerprint.'),
  ];

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _ctl.nextPage(duration: Motion.slow, curve: Motion.standard);
    } else {
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final last = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: c.bgCanvas,
      body: HrmBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.s6, Sp.s2, Sp.s3, 0),
                child: Row(
                  children: [
                    Expanded(child: Text('HRM', style: T.h2.col(c.textPrimary))),
                    TextButton(
                      onPressed: () => context.go('/signin'),
                      child: Text('Skip', style: T.label.col(c.textSecondary)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ctl,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.s6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: OnboardingArt(scene: i).rise(),
                        )),
                        const SizedBox(height: Sp.s6),
                        Text(_slides[i].$1,
                                style: T.h1.col(c.textPrimary))
                            .rise(1),
                        const SizedBox(height: Sp.s2),
                        Text(_slides[i].$2,
                                style: T.bodyLg.col(c.textSecondary))
                            .rise(2),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.s6, 0, Sp.s6, Sp.s6),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _slides.length; i++)
                          AnimatedContainer(
                            duration: Motion.base,
                            curve: Motion.standard,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _page ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _page ? c.primary500 : c.borderStrong,
                              borderRadius: Rd.rFull,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Sp.s6),
                    HrmButton(last ? 'Get started' : 'Next', onPressed: _next),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
