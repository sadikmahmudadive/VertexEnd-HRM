import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/state/app_state.dart';
import '../../core/ui.dart';
import '../../core/widgets/charts.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

enum _Phase { idle, scan, ready, sent }

String _fmt(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  _Phase _phase = _Phase.idle;
  String _cat = 'Meals';
  bool _sent = false;
  String? _uploadedReceiptUrl;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startScanWithImage(ImageSource? source) async {
    HapticFeedback.selectionClick();
    setState(() => _phase = _Phase.scan);

    if (source != null) {
      try {
        final cloudinary = ref.read(cloudinaryServiceProvider);
        final result = await cloudinary.pickAndUploadImage(
          source: source,
          folder: 'vertexhand_hrm/receipts',
        );
        if (result != null) {
          _uploadedReceiptUrl = result.secureUrl;
        }
      } catch (e) {
        debugPrint('Receipt upload error: $e');
      }
    }

    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _phase = _Phase.ready);
    });
  }

  void _showImagePickerSheet() {
    final c = context.c;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: c.bgSurfaceRaised,
          borderRadius: Rd.sheetTop,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: c.borderStrong,
                  borderRadius: Rd.rFull,
                ),
              ),
            ),
            const SizedBox(height: Sp.s3),
            Text('Attach Receipt Photo', style: T.h2.col(c.textPrimary)),
            const SizedBox(height: Sp.s1),
            Text('Upload to Cloudinary for instant OCR and record keeping',
                style: T.caption.col(c.textSecondary)),
            const SizedBox(height: Sp.s4),
            HrmButton(
              'Snap with Camera',
              icon: LucideIcons.camera,
              kind: BtnKind.secondary,
              onPressed: () {
                Navigator.pop(ctx);
                _startScanWithImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: Sp.s2),
            HrmButton(
              'Choose from Gallery',
              icon: LucideIcons.image,
              kind: BtnKind.secondary,
              onPressed: () {
                Navigator.pop(ctx);
                _startScanWithImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: Sp.s2),
            HrmButton(
              'Scan Sample Demo Receipt',
              icon: LucideIcons.sparkles,
              kind: BtnKind.ghost,
              onPressed: () {
                Navigator.pop(ctx);
                _startScanWithImage(null);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitClaim() {
    final auth = ref.read(authServiceProvider);
    final firestore = ref.read(firestoreServiceProvider);

    firestore.createExpenseClaim(
      userId: auth.currentUserId,
      title: 'Riverside Cafe',
      category: _cat,
      amount: 1250,
      date: '3 Nov',
      receiptImageUrl: _uploadedReceiptUrl,
    );

    setState(() {
      _phase = _Phase.sent;
      _sent = true;
    });
  }

  void _viewReceipt(String? url) {
    if (url == null || url.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: Rd.rLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Padding(
                padding: EdgeInsets.all(32),
                child: Text('Unable to load receipt image'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: HrmButton(
                'Close',
                size: BtnSize.sm,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const approved = 5200;
    final pending = 3250 + (_sent ? 1250 : 0);
    final total = approved + pending;
    final history = [
      if (_sent)
        ExpenseClaim(
          'Riverside Cafe',
          _cat,
          '3 Nov',
          1250,
          'Pending',
          Tone.warning,
          receiptUrl: _uploadedReceiptUrl,
        ),
      ...Mock.expenseHistory,
    ];

    return HrmScreen(
      title: 'Expenses',
      children: [
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s3,
            children: [
              Row(children: [
                Expanded(child: Text('Claimed in November', style: T.caption.col(c.textSecondary))),
                const HrmBadge('Paid with payroll', tone: Tone.info),
              ]),
              Text('৳ ${_fmt(total)}', style: T.display.col(c.textPrimary).tnum),
              SegmentBar(segments: [
                (approved / total, c.success),
                (pending / total, c.warning),
              ]),
              Row(children: [
                _Legend(c.success, 'Approved ৳ ${_fmt(approved)}'),
                const Spacer(),
                _Legend(c.warning, 'Pending ৳ ${_fmt(pending)}'),
              ]),
            ],
          ),
        ).rise(1),
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s4,
            children: [
              Row(
                children: [
                  Expanded(child: Text('New claim', style: T.h3.col(c.textPrimary))),
                  const HrmBadge('Cloudinary & Firestore', tone: Tone.neutral),
                ],
              ),
              AnimatedSwitcher(
                duration: Motion.base,
                child: switch (_phase) {
                  _Phase.idle => _Idle(
                      key: const ValueKey('i'),
                      onScan: _showImagePickerSheet,
                    ),
                  _Phase.scan => const _Scanning(key: ValueKey('s')),
                  _Phase.ready => _Ready(
                      key: const ValueKey('r'),
                      cat: _cat,
                      receiptUrl: _uploadedReceiptUrl,
                      onCat: (v) => setState(() => _cat = v),
                      onSubmit: _handleSubmitClaim,
                    ),
                  _Phase.sent => Column(
                      key: const ValueKey('d'),
                      spacing: Sp.s3,
                      children: [
                        const StatusBanner(
                          tone: Tone.success,
                          text:
                              "Claim recorded in Firestore and sent to Tahmina for approval. Receipt safely preserved in Cloudinary CDN.",
                        ).popIn(),
                        HrmButton(
                          'Add another claim',
                          kind: BtnKind.secondary,
                          onPressed: () => setState(() {
                            _phase = _Phase.idle;
                            _uploadedReceiptUrl = null;
                          }),
                        ),
                      ],
                    ),
                },
              ),
            ],
          ),
        ).rise(2),
        const SectionHeader('Recent claims').rise(3),
        HrmList(children: [
          for (final h in history)
            HrmListTile(
              minHeight: 72,
              leading: const LeadIcon(LucideIcons.receipt),
              title: h.name,
              subtitle: '${h.category} · ${h.date}',
              onTap: h.receiptUrl != null ? () => _viewReceipt(h.receiptUrl) : null,
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 2,
                children: [
                  Text('৳ ${_fmt(h.amount)}', style: T.bodyStrong.col(c.textPrimary).tnum),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (h.receiptUrl != null) ...[
                        Icon(LucideIcons.paperclip, size: 12, color: c.primary500),
                        const SizedBox(width: 3),
                      ],
                      HrmBadge(h.status, tone: h.tone),
                    ],
                  ),
                ],
              ),
            ),
        ]).rise(3),
      ],
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
        Text(text, style: T.caption.col(context.c.textSecondary).tnum),
      ]);
}

class _Idle extends StatelessWidget {
  const _Idle({super.key, required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Sp.s4,
      children: [
        GestureDetector(
          onTap: onScan,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: c.bgSurface,
              borderRadius: Rd.rLg,
              border: Border.all(color: c.borderStrong, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.camera, size: 32, color: c.primary500),
                const SizedBox(height: Sp.s2),
                Text('Snap receipt with Cloudinary', style: T.bodyStrong.col(c.textPrimary)),
                Text('Camera or gallery upload with secure Cloudinary CDN',
                    style: T.caption.col(c.textSecondary)),
              ],
            ),
          ),
        ),
        HrmButton('Attach receipt photo', icon: LucideIcons.uploadCloud, onPressed: onScan),
      ],
    );
  }
}

class _Scanning extends StatelessWidget {
  const _Scanning({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 104,
          height: 140,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: c.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.borderStrong, width: 2),
                ),
                padding: const EdgeInsets.all(Sp.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    for (final w in const [48.0, 60.0, 52.0, 56.0, 40.0])
                      Container(
                          width: w,
                          height: 5,
                          decoration: BoxDecoration(
                              color: c.borderStrong, borderRadius: BorderRadius.circular(3))),
                    const Spacer(),
                    Container(
                        width: 60,
                        height: 8,
                        decoration: BoxDecoration(
                            color: c.primary500, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
              Positioned(
                left: -6,
                right: -6,
                top: 10,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: c.primary500,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                          color: c.primary500.withValues(alpha: 0.55),
                          blurRadius: 14,
                          spreadRadius: 2)
                    ],
                  ),
                )
                    .animate(onPlay: (ctl) => ctl.repeat(reverse: true))
                    .moveY(begin: 0, end: 116, duration: 1300.ms, curve: Curves.easeInOut),
              ),
            ],
          ),
        ),
        const SizedBox(width: Sp.s4),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s3,
            children: [
              _ReadingLabel(),
              Skeleton(height: 44, radius: Rd.md),
              Skeleton(height: 44, radius: Rd.md),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadingLabel extends StatelessWidget {
  const _ReadingLabel();
  @override
  Widget build(BuildContext context) =>
      Text('Processing receipt...', style: T.bodyStrong.col(context.c.textPrimary));
}

class _Ready extends StatelessWidget {
  const _Ready({
    super.key,
    required this.cat,
    required this.onCat,
    required this.onSubmit,
    this.receiptUrl,
  });

  final String cat;
  final ValueChanged<String> onCat;
  final VoidCallback onSubmit;
  final String? receiptUrl;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget field(String label, String value) => Container(
          padding: const EdgeInsets.all(Sp.s3),
          decoration: BoxDecoration(color: c.bgSubtle, borderRadius: Rd.rMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: T.caption.col(c.textSecondary)),
              Text(value, style: T.h3.col(c.textPrimary).tnum),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Sp.s4,
      children: [
        if (receiptUrl != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.success.withValues(alpha: 0.12),
              borderRadius: Rd.rMd,
              border: Border.all(color: c.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.checkCircle2, size: 16, color: c.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Receipt media uploaded to Cloudinary',
                    style: T.caption.copyWith(color: c.success, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        Row(spacing: Sp.s3, children: [
          Expanded(child: field('Amount', '৳ 1,250').popIn(0)),
          Expanded(child: field('Date', '3 Nov').popIn(1)),
        ]),
        Container(
          padding: const EdgeInsets.all(Sp.s3),
          decoration: BoxDecoration(color: c.bgSubtle, borderRadius: Rd.rMd),
          child: Row(children: [
            Icon(LucideIcons.sparkles, size: 16, color: c.primary500),
            const SizedBox(width: Sp.s2),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: 'Read from receipt: ',
                  style: T.label.weight(FontWeight.w400).col(c.textPrimary)),
              TextSpan(
                  text: 'Riverside Cafe',
                  style: T.label.weight(FontWeight.w700).col(c.textPrimary)),
            ])),
          ]),
        ).popIn(2),
        const Overline('Category'),
        Wrap(spacing: Sp.s2, runSpacing: Sp.s2, children: [
          for (final k in const ['Meals', 'Travel', 'Supplies', 'Internet'])
            HrmChip(k, selected: cat == k, onTap: () => onCat(k)),
        ]),
        HrmButton('Submit claim', icon: LucideIcons.send, onPressed: onSubmit),
      ],
    );
  }
}
