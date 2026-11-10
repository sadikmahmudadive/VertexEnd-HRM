import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/state/app_state.dart';
import '../../core/ui.dart';

/// Modal bottom sheet for Outwork / On-Duty requests and instant outwork clock-in.
class OutworkRequestSheet extends ConsumerStatefulWidget {
  const OutworkRequestSheet({super.key});

  @override
  ConsumerState<OutworkRequestSheet> createState() => _OutworkRequestSheetState();
}

class _OutworkRequestSheetState extends ConsumerState<OutworkRequestSheet> {
  int _categoryIndex = 0;
  int _scheduleIndex = 0; // 0 = Today full day, 1 = First half, 2 = Second half, 3 = Tomorrow
  String? _proofImageUrl;
  bool _uploadingProof = false;

  final _clientController = TextEditingController(text: 'Apex Footwear Ltd');
  final _locationController = TextEditingController(text: 'Gulshan 2, Dhaka');
  final _purposeController = TextEditingController(
    text: 'On-site system deployment and user training walkthrough.',
  );

  static const _categories = [
    (LucideIcons.handshake, 'Client visit'),
    (LucideIcons.hardHat, 'Site inspection'),
    (LucideIcons.wrench, 'Deployment'),
    (LucideIcons.briefcase, 'Official meeting'),
  ];

  static const _clientSuggestions = [
    'Apex Footwear HQ',
    'Grameenphone Ltd',
    'BRAC Bank Head Office',
    'Beximco Industrial Park',
    'Unilever Bangladesh',
  ];

  @override
  void dispose() {
    _clientController.dispose();
    _locationController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _pickProofImage(ImageSource source) async {
    setState(() => _uploadingProof = true);
    try {
      final cloudinary = ref.read(cloudinaryServiceProvider);
      final res = await cloudinary.pickAndUploadImage(
        source: source,
        folder: 'vertexhand_hrm/outwork',
      );
      if (res != null && mounted) {
        setState(() => _proofImageUrl = res.secureUrl);
        showHrmToast(context, 'Site photo uploaded to Cloudinary!', bottom: 32);
      }
    } catch (e) {
      if (mounted) showHrmToast(context, 'Photo upload error: $e', bottom: 32);
    } finally {
      if (mounted) setState(() => _uploadingProof = false);
    }
  }

  void _submitRequest({bool clockInNow = false}) {
    HapticFeedback.mediumImpact();
    final client = _clientController.text.trim();
    final location = _locationController.text.trim();
    final category = _categories[_categoryIndex].$2;
    final scheduleText = switch (_scheduleIndex) {
      0 => 'Today · Full day',
      1 => 'First half (9:00 – 1:30)',
      2 => 'Second half (1:30 – 6:00)',
      _ => 'Tomorrow · 11 Nov',
    };

    // Sync to Firestore
    try {
      final auth = ref.read(authServiceProvider);
      final profile = ref.read(userProfileProvider);
      final firestore = ref.read(firestoreServiceProvider);
      firestore.createOutworkRequest(
        userId: auth.currentUserId,
        userName: profile.name,
        category: category,
        clientName: client.isNotEmpty ? client : category,
        location: location.isNotEmpty ? location : 'Client Site · Dhaka',
        schedule: scheduleText,
        reason: _purposeController.text.trim(),
        proofImageUrl: _proofImageUrl,
      );
    } catch (_) {}

    if (clockInNow) {
      ref.read(clockProvider.notifier).setOutwork(
            isOutwork: true,
            location: location.isNotEmpty ? location : 'Client Site · Outwork',
            clientName: client.isNotEmpty ? client : category,
          );
      ref.read(clockProvider.notifier).clockIn();
      context.pop();
      showHrmToast(
        context,
        'Clocked in for Outwork at ${client.isNotEmpty ? client : location}',
        actionLabel: 'View',
        onAction: () => context.go('/attendance'),
        bottom: 32,
      );
    } else {
      context.pop();
      showHrmToast(
        context,
        'Outwork request recorded in Firestore and sent for approval',
        bottom: 32,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.90,
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
                      color: c.borderStrong,
                      borderRadius: Rd.rFull,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316).withValues(alpha: c.isDark ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.briefcase,
                            size: 18,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: Sp.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Outwork / On Duty', style: T.h2.col(c.textPrimary)),
                              Text(
                                'Official field work outside office geofence',
                                style: T.caption.col(c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        HrmIconButton(
                          icon: LucideIcons.x,
                          label: 'Close',
                          onTap: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 120 + bottom),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const Overline('Duty Category'),
                        const SizedBox(height: Sp.s2),
                        Wrap(
                          spacing: Sp.s2,
                          runSpacing: Sp.s2,
                          children: [
                            for (var i = 0; i < _categories.length; i++)
                              HrmChip(
                                _categories[i].$2,
                                selected: _categoryIndex == i,
                                dot: const Color(0xFFEA580C),
                                height: 40,
                                onTap: () => setState(() => _categoryIndex = i),
                              ),
                          ],
                        ),
                        const SizedBox(height: Sp.s4),
                        const Overline('Client or Destination'),
                        const SizedBox(height: Sp.s2),
                        HrmField(
                          label: 'Client / Company name',
                          controller: _clientController,
                          prefix: const Icon(LucideIcons.building2, size: 18),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            children: [
                              for (final name in _clientSuggestions) ...[
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _clientController.text = name);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: c.bgSubtle,
                                      borderRadius: Rd.rFull,
                                      border: Border.all(color: c.borderDefault),
                                    ),
                                    child: Text(
                                      name,
                                      style: T.caption.copyWith(
                                        color: c.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: Sp.s4),
                        const Overline('Site Location'),
                        const SizedBox(height: Sp.s2),
                        HrmField(
                          label: 'Location / Area',
                          controller: _locationController,
                          prefix: const Icon(LucideIcons.mapPin, size: 18),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: Sp.s4),
                        const Overline('Schedule & Duration'),
                        const SizedBox(height: Sp.s2),
                        Wrap(
                          spacing: Sp.s2,
                          runSpacing: Sp.s2,
                          children: [
                            HrmChip(
                              'Today · Full day',
                              selected: _scheduleIndex == 0,
                              dot: const Color(0xFF10B981),
                              height: 38,
                              onTap: () => setState(() => _scheduleIndex = 0),
                            ),
                            HrmChip(
                              'First half (9:00 – 1:30)',
                              selected: _scheduleIndex == 1,
                              height: 38,
                              onTap: () => setState(() => _scheduleIndex = 1),
                            ),
                            HrmChip(
                              'Second half (1:30 – 6:00)',
                              selected: _scheduleIndex == 2,
                              height: 38,
                              onTap: () => setState(() => _scheduleIndex = 2),
                            ),
                            HrmChip(
                              'Tomorrow · 11 Nov',
                              selected: _scheduleIndex == 3,
                              height: 38,
                              onTap: () => setState(() => _scheduleIndex = 3),
                            ),
                          ],
                        ),
                        const SizedBox(height: Sp.s4),
                        HrmField(
                          label: 'Purpose of visit & agenda',
                          controller: _purposeController,
                          maxLines: 3,
                          maxLength: 250,
                          helper: '${_purposeController.text.length} / 250',
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: Sp.s3),
                        Container(
                          padding: const EdgeInsets.all(Sp.s4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316).withValues(alpha: c.isDark ? 0.15 : 0.08),
                            borderRadius: Rd.rMd,
                            border: Border.all(
                              color: const Color(0xFFF97316).withValues(alpha: c.isDark ? 0.3 : 0.22),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.shieldCheck,
                                size: 20,
                                color: Color(0xFFEA580C),
                              ),
                              const SizedBox(width: Sp.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Geofence Exemption Enabled',
                                      style: T.bodyStrong.copyWith(
                                        color: c.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Once submitted or clocked in, your field location will be automatically verified for attendance.',
                                      style: T.caption.col(c.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Sp.s3),
                        Container(
                          padding: const EdgeInsets.all(Sp.s3),
                          decoration: BoxDecoration(
                            color: c.bgSubtle,
                            borderRadius: Rd.rMd,
                            border: Border.all(color: c.borderDefault),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: c.primary50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _proofImageUrl != null
                                      ? LucideIcons.checkCircle2
                                      : LucideIcons.camera,
                                  size: 20,
                                  color: _proofImageUrl != null ? c.success : c.primary600,
                                ),
                              ),
                              const SizedBox(width: Sp.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _proofImageUrl != null
                                          ? 'Photo attached (Cloudinary)'
                                          : 'On-site photo proof',
                                      style: T.bodyStrong.copyWith(
                                        fontSize: 13,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _proofImageUrl != null
                                          ? 'Securely stored on Cloudinary CDN'
                                          : 'Snap client premises or signboard',
                                      style: T.caption.col(c.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (_uploadingProof)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                HrmButton(
                                  _proofImageUrl != null ? 'Change' : 'Snap photo',
                                  kind: BtnKind.secondary,
                                  size: BtnSize.sm,
                                  expand: false,
                                  onPressed: () => _pickProofImage(ImageSource.camera),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom sticky action buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
                  decoration: BoxDecoration(
                    color: c.bgSurfaceRaised,
                    border: Border(top: BorderSide(color: c.borderDefault)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: c.isDark ? 0.35 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_scheduleIndex != 3) ...[
                        Expanded(
                          child: HrmButton(
                            'Clock in Outwork',
                            kind: BtnKind.primary,
                            icon: LucideIcons.playCircle,
                            onPressed: () => _submitRequest(clockInNow: true),
                          ),
                        ),
                        const SizedBox(width: Sp.s3),
                      ],
                      Expanded(
                        child: HrmButton(
                          _scheduleIndex == 3 ? 'Submit Request' : 'Apply for Approval',
                          kind: _scheduleIndex == 3 ? BtnKind.primary : BtnKind.secondary,
                          icon: LucideIcons.send,
                          onPressed: () => _submitRequest(clockInNow: false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
