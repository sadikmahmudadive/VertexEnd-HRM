import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

enum _Sign { idle, signing, done }

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  _Sign _sign = _Sign.idle;
  String _cat = 'All';
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _doSign() {
    HapticFeedback.lightImpact();
    setState(() => _sign = _Sign.signing);
    _timer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _sign = _Sign.done);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final docs = Mock.documents
        .where((d) =>
            _cat == 'All' ||
            d.category == _cat ||
            (_cat == 'To sign' && d.tone == Tone.warning))
        .toList();
    return HrmScreen(
      title: 'Documents',
      actions: [HrmIconButton(icon: LucideIcons.search, label: 'Search documents', onTap: () {})],
      floating: Positioned(
        right: Sp.s4,
        bottom: Sp.s6,
        child: PressScale(
          onTap: () => showHrmToast(context, 'Upload is not connected yet', bottom: 96),
          semanticLabel: 'Upload a document',
          child: Container(
            height: Sz.fab,
            padding: const EdgeInsets.symmetric(horizontal: Sp.s5),
            decoration: BoxDecoration(
              color: c.primary500,
              borderRadius: Rd.rFull,
              boxShadow: c.isDark
                  ? null
                  : const [BoxShadow(color: Color(0x290F172A), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(LucideIcons.plus, size: 20, color: c.textOnPrimary),
              const SizedBox(width: Sp.s2),
              Text('Upload', style: T.label.col(c.textOnPrimary)),
            ]),
          ),
        ).popIn(2),
      ),
      bottomPad: 120,
      children: [
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s3,
            children: [
              Row(children: [
                Expanded(
                    child: Text('Employment contract amendment',
                        style: T.bodyStrong.col(c.textPrimary))),
                HrmBadge(_sign == _Sign.done ? 'Signed' : 'To sign',
                    tone: _sign == _Sign.done ? Tone.success : Tone.warning),
              ]),
              Container(
                padding: const EdgeInsets.all(Sp.s4),
                decoration: BoxDecoration(color: c.bgSubtle, borderRadius: Rd.rMd),
                child: Column(
                  spacing: 6,
                  children: [
                    for (final w in const [0.64, 0.92, 0.84, 0.48])
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: w,
                          child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                  color: c.borderStrong.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(3))),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: Motion.base,
                height: 76,
                decoration: BoxDecoration(
                  color: c.bgSurface,
                  borderRadius: Rd.rSm,
                  border: Border.all(
                      color: _sign == _Sign.done ? c.success : c.borderStrong,
                      width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_sign == _Sign.idle)
                      Text('Sign here', style: T.label.weight(FontWeight.w400).col(c.textSecondary))
                    else
                      TweenAnimationBuilder<double>(
                        key: ValueKey(_sign == _Sign.done),
                        tween: Tween(begin: _sign == _Sign.done ? 1 : 0, end: 1),
                        duration: const Duration(milliseconds: 1400),
                        curve: Curves.easeInOut,
                        builder: (context, v, _) => CustomPaint(
                          size: const Size(160, 64),
                          painter: _SignaturePainter(v, c.textPrimary),
                        ),
                      ),
                    if (_sign == _Sign.done)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: const HrmBadge('Signed 9:52 AM', tone: Tone.success).popIn(),
                      ),
                  ],
                ),
              ),
              switch (_sign) {
                _Sign.idle => HrmButton('Sign document', icon: LucideIcons.pencil, onPressed: _doSign),
                _Sign.signing => const HrmButton('Signing...', onPressed: null),
                _Sign.done => Text('A copy was sent to your email and added to your files.',
                    style: T.caption.col(c.textSecondary)),
              },
            ],
          ),
        ).rise(1),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (final k in const ['All', 'To sign', 'Contracts', 'Policies', 'Tax']) ...[
                HrmChip(k, selected: _cat == k, onTap: () => setState(() => _cat = k)),
                const SizedBox(width: Sp.s2),
              ],
            ],
          ),
        ).rise(2),
        HrmList(children: [for (final d in docs) _DocTile(d)]).rise(3),
        if (docs.isEmpty)
          const EmptyState(
              icon: LucideIcons.fileText,
              title: 'No documents here',
              message: 'Files in this category will show up here.'),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile(this.d);
  final DocItem d;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bg = switch (d.category) {
      'Contracts' => c.dangerSoft,
      'Policies' => c.infoSoft,
      _ => c.successSoft,
    };
    return HrmListTile(
      minHeight: 72,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(d.ext,
            style: T.overline.copyWith(fontSize: 10, letterSpacing: 0.5).col(c.textPrimary)),
      ),
      title: d.name,
      subtitle: d.meta,
      trailing: Row(mainAxisSize: MainAxisSize.min, spacing: Sp.s2, children: [
        if (d.tag.isNotEmpty) HrmBadge(d.tag, tone: d.tone),
        Icon(LucideIcons.download, size: 20, color: c.textSecondary),
      ]),
      onTap: () => showHrmToast(context, '${d.name} saved to Files', bottom: 96),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.v, this.color);
  final double v;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 140, size.height / 56);
    final path = Path()
      ..moveTo(8, 40)
      ..cubicTo(16, 14, 26, 12, 26, 34)
      ..cubicTo(26, 48, 36, 16, 44, 28)
      ..cubicTo(50, 38, 54, 42, 62, 26)
      ..cubicTo(68, 14, 74, 44, 88, 30)
      ..cubicTo(98, 20, 108, 36, 132, 22);
    final m = path.computeMetrics().first;
    canvas.drawPath(
      m.extractPath(0, m.length * v),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => old.v != v || old.color != color;
}
