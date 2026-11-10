import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/app_state.dart';
import '../../core/ui.dart';
import '../../core/widgets/charts.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  int _tab = 0;

  void _decide(ApprovalRequest r, Decision d) {
    HapticFeedback.mediumImpact();
    ref.read(approvalsProvider.notifier).decide(r.id, d);
    showHrmToast(
      context,
      '${d == Decision.approved ? 'Approved' : 'Rejected'} ${r.name.split(' ').first}\'s request',
      actionLabel: 'Undo',
      onAction: () => ref.read(approvalsProvider.notifier).undo(r.id),
      bottom: 32,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final decisions = ref.watch(approvalsProvider);
    final pending = ref.watch(pendingApprovalsProvider);
    final pendingAttendance =
        Mock.attendanceApprovals.where((r) => !decisions.containsKey(r.id)).length;
    final showEmpty = (_tab == 0 && pending == 0) ||
        (_tab == 1 && pendingAttendance == 0) ||
        _tab == 2;

    return HrmScreen(
      title: 'Approvals',
      actions: [HrmBadge('$pending pending', tone: Tone.warning)],
      children: [
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s3,
            children: [
              Row(children: [
                Expanded(child: Text('Team today', style: T.bodyStrong.col(c.textPrimary))),
                Text('24 people', style: T.caption.col(c.textSecondary)),
              ]),
              SegmentBar(segments: [
                (0.75, c.success),
                (0.08, c.warning),
                (0.17, c.info),
              ]),
              Row(spacing: Sp.s4, children: [
                _Count('18', 'present', c.textPrimary, c.textSecondary),
                _Count('2', 'late', c.textPrimary, c.textSecondary),
                _Count('4', 'on leave', c.textPrimary, c.textSecondary),
              ]),
            ],
          ),
        ).rise(1),
        HrmSegmented(
          labels: const ['Leave', 'Attendance', 'Expense'],
          index: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ).rise(2),
        Text('Swipe right to approve, left to reject. Buttons do the same.',
            style: T.caption.col(c.textSecondary)),
        if (_tab == 0)
          for (final r in Mock.approvals)
            Collapsible(
              visible: !decisions.containsKey(r.id),
              slideTo: decisions[r.id] == Decision.rejected
                  ? const Offset(-0.2, 0)
                  : const Offset(0.2, 0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: Sp.s3),
                child: _RequestCard(
                  r: r,
                  onApprove: () => _decide(r, Decision.approved),
                  onReject: () => _decide(r, Decision.rejected),
                ),
              ),
            ),
        if (_tab == 1)
          for (final r in Mock.attendanceApprovals)
            Collapsible(
              visible: !decisions.containsKey(r.id),
              slideTo: decisions[r.id] == Decision.rejected
                  ? const Offset(-0.2, 0)
                  : const Offset(0.2, 0),
              child: Padding(
                padding: const EdgeInsets.only(bottom: Sp.s3),
                child: _RequestCard(
                  r: r,
                  onApprove: () => _decide(r, Decision.approved),
                  onReject: () => _decide(r, Decision.rejected),
                ),
              ),
            ),
        if (showEmpty)
          Column(
            children: [
              const SizedBox(height: Sp.s4),
              const InboxArt(),
              const SizedBox(height: Sp.s2),
              Text(_tab == 0 ? 'No pending approvals 🎉' : 'Nothing to review',
                  style: T.h3.col(c.textPrimary)),
              Text(_tab == 0 ? "You're all caught up." : 'New items will show up here.',
                  style: T.body.col(c.textSecondary)),
            ],
          ).rise(),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.n, this.label, this.strong, this.soft);
  final String n;
  final String label;
  final Color strong;
  final Color soft;
  @override
  Widget build(BuildContext context) => Text.rich(TextSpan(children: [
        TextSpan(text: n, style: T.caption.col(strong).weight(FontWeight.w700)),
        TextSpan(text: ' $label', style: T.caption.col(soft)),
      ]));
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.r, required this.onApprove, required this.onReject});
  final ApprovalRequest r;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return HrmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Sp.s3,
        children: [
          Row(children: [
            HrmAvatar(r.initials, variant: r.variant),
            const SizedBox(width: Sp.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: T.bodyStrong.col(c.textPrimary)),
                  Text(r.role, style: T.caption.col(c.textSecondary)),
                ],
              ),
            ),
            const HrmBadge('Pending', tone: Tone.warning),
          ]),
          Row(children: [
            Expanded(child: Text(r.type, style: T.bodyStrong.col(c.textPrimary))),
            Text('${r.dates} · ${r.length}', style: T.label.weight(FontWeight.w400).col(c.textSecondary).tnum),
          ]),
          Text(r.reason, style: T.label.weight(FontWeight.w400).col(c.textSecondary)),
          StatusBanner(
            compact: true,
            tone: r.warn ? Tone.warning : Tone.info,
            icon: LucideIcons.users,
            text: r.impact,
          ),
          Row(children: [
            Expanded(child: HrmButton('Approve', size: BtnSize.md, onPressed: onApprove)),
            const SizedBox(width: Sp.s2),
            HrmButton('Reject',
                kind: BtnKind.ghostDanger,
                size: BtnSize.md,
                expand: false,
                onPressed: onReject),
          ]),
        ],
      ),
    );
  }
}
