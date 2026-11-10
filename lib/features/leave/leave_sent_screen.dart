import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui.dart';

class LeaveSentScreen extends StatelessWidget {
  const LeaveSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bgCanvas,
      body: HrmBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Sp.s6, 0, Sp.s6, Sp.s6),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: Sp.s4),
                        const SuccessBadge(),
                        Text('Leave request sent to Tahmina for approval',
                                textAlign: TextAlign.center,
                                style: T.h1.col(c.textPrimary))
                            .rise(3),
                        const SizedBox(height: Sp.s2),
                        Text("We'll tell you the moment she decides.",
                                style: T.body.col(c.textSecondary))
                            .rise(3),
                        const SizedBox(height: Sp.s6),
                        HrmCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: Sp.s3,
                            children: [
                              Row(children: [
                                const LeadIcon(LucideIcons.calendarDays),
                                const SizedBox(width: Sp.s3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Annual leave',
                                          style: T.bodyStrong.col(c.textPrimary)),
                                      Text('12 – 16 Nov 2026 · 3 working days',
                                          style: T.caption.col(c.textSecondary).tnum),
                                    ],
                                  ),
                                ),
                                const HrmBadge('Pending', tone: Tone.warning),
                              ]),
                              Divider(height: 1, color: c.borderDefault),
                              Row(children: [
                                Expanded(
                                    child: Text('Balance after',
                                        style: T.label.col(c.textSecondary))),
                                Text('5 days', style: T.bodyStrong.col(c.textPrimary).tnum),
                              ]),
                              const _Step('Sent today, 9:41 AM', done: true),
                              const _Step('Tahmina is reviewing', now: true),
                              const _Step('Decision'),
                            ],
                          ),
                        ).rise(4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Sp.s3),
                HrmButton('Back to Home', onPressed: () => context.go('/home')).rise(5),
                const SizedBox(height: Sp.s2),
                HrmButton('Withdraw request',
                    kind: BtnKind.ghost,
                    size: BtnSize.md,
                    onPressed: () async {
                      final ok = await showHrmConfirm(
                        context,
                        title: 'Withdraw this request?',
                        message: 'Withdrawing this request will restore 3 days to your balance.',
                        confirmLabel: 'Withdraw',
                        cancelLabel: 'Keep request',
                      );
                      if (ok && context.mounted) context.go('/leave');
                    }).rise(5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.text, {this.done = false, this.now = false});
  final String text;
  final bool done;
  final bool now;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: done
                ? c.success
                : now
                    ? c.primary500
                    : c.borderStrong,
            shape: BoxShape.circle,
            boxShadow: now
                ? [BoxShadow(color: c.primary500.withValues(alpha: 0.22), spreadRadius: 5)]
                : null,
          ),
        ),
        const SizedBox(width: Sp.s3),
        Text(text,
            style: (now ? T.label : T.body)
                .col(done || now ? c.textPrimary : c.textSecondary)),
      ],
    );
  }
}
