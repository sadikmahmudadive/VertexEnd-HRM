import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/firebase/firebase_service.dart';
import '../../core/state/app_state.dart';
import '../../core/ui.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final cloudinary = ref.read(cloudinaryServiceProvider);
    setState(() => _isUploadingPhoto = true);

    try {
      final result = await cloudinary.pickAndUploadImage(
        source: source,
        folder: 'vertexhand_hrm/avatars',
      );

      if (result != null && mounted) {
        ref.read(userProfileProvider.notifier).updateAvatar(result.secureUrl);
        showHrmToast(
          context,
          'Profile picture updated via Cloudinary!',
          bottom: 110,
        );
      }
    } catch (e) {
      if (mounted) {
        showHrmToast(
          context,
          'Upload error: $e',
          bottom: 110,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    HapticFeedback.selectionClick();
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
            Row(
              children: [
                Expanded(
                  child: Text('Profile Photo · Cloudinary', style: T.h2.col(c.textPrimary)),
                ),
                HrmIconButton(
                  icon: LucideIcons.x,
                  label: 'Close',
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: Sp.s1),
            Text(
              'Upload and optimize your profile picture with Cloudinary CDN',
              style: T.caption.col(c.textSecondary),
            ),
            const SizedBox(height: Sp.s4),
            HrmButton(
              'Take photo with Camera',
              icon: LucideIcons.camera,
              kind: BtnKind.secondary,
              onPressed: () {
                Navigator.pop(ctx);
                _pickAndUploadPhoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: Sp.s2),
            HrmButton(
              'Choose from Gallery',
              icon: LucideIcons.image,
              kind: BtnKind.secondary,
              onPressed: () {
                Navigator.pop(ctx);
                _pickAndUploadPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(UserProfile profile) {
    HapticFeedback.selectionClick();
    final c = context.c;
    final nameCtrl = TextEditingController(text: profile.name);
    final roleCtrl = TextEditingController(text: profile.role);
    final deptCtrl = TextEditingController(text: profile.dept);
    final phoneCtrl = TextEditingController(text: profile.phone);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
              Row(
                children: [
                  Expanded(
                    child: Text('Edit Profile · Firestore', style: T.h2.col(c.textPrimary)),
                  ),
                  HrmIconButton(
                    icon: LucideIcons.x,
                    label: 'Close',
                    onTap: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: Sp.s4),
              HrmField(
                label: 'Full Name',
                initialValue: profile.name,
                onChanged: (v) => nameCtrl.text = v,
              ),
              const SizedBox(height: Sp.s3),
              HrmField(
                label: 'Designation / Role',
                initialValue: profile.role,
                onChanged: (v) => roleCtrl.text = v,
              ),
              const SizedBox(height: Sp.s3),
              HrmField(
                label: 'Department',
                initialValue: profile.dept,
                onChanged: (v) => deptCtrl.text = v,
              ),
              const SizedBox(height: Sp.s3),
              HrmField(
                label: 'Phone number',
                initialValue: profile.phone,
                onChanged: (v) => phoneCtrl.text = v,
              ),
              const SizedBox(height: Sp.s5),
              HrmButton(
                'Save to Firestore',
                icon: LucideIcons.check,
                onPressed: () {
                  ref.read(userProfileProvider.notifier).updateProfile(
                        name: nameCtrl.text.trim(),
                        role: roleCtrl.text.trim(),
                        dept: deptCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );
                  Navigator.pop(ctx);
                  showHrmToast(context, 'Profile synced with Firestore!', bottom: 110);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = ref.watch(settingsProvider);
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final profile = ref.watch(userProfileProvider);
    final clock = ref.watch(clockProvider);

    Widget toggle(
      IconData icon,
      String title,
      String sub,
      bool v,
      Settings Function(Settings, bool) f,
    ) =>
        HrmListTile(
          leading: LeadIcon(icon, size: 36, circle: false),
          title: title,
          subtitle: sub,
          trailing: HrmSwitch(
            label: title,
            value: v,
            onChanged: (nv) => notifier.update((o) => f(o, nv)),
          ),
        );

    return HrmScreen(
      title: 'Me',
      showBack: false,
      bottomPad: 140,
      actions: [
        HrmIconButton(
          icon: LucideIcons.pencil,
          label: 'Edit profile',
          onTap: () => _showEditProfileSheet(profile),
        ),
      ],
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: _showPhotoOptions,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 116,
                height: 116,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [
                          c.heroFrom,
                          c.secondary500,
                          c.heroTo,
                          c.heroFrom,
                        ]),
                      ),
                    ).animate(onPlay: (ctl) => ctl.repeat()).rotate(duration: 8.seconds),
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(color: c.bgCanvas, shape: BoxShape.circle),
                    ),
                    HrmAvatar(
                      profile.initials,
                      imageUrl: profile.avatarUrl,
                      size: 96,
                    ),
                    if (_isUploadingPhoto)
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        ),
                      ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c.primary500,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.bgCanvas, width: 2.5),
                        ),
                        child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Sp.s3),
            Text(profile.name, style: T.h2.col(c.textPrimary)),
            Text('${profile.role} · ${profile.dept}', style: T.body.col(c.textSecondary)),
            const SizedBox(height: Sp.s3),
            Wrap(
              spacing: Sp.s2,
              runSpacing: Sp.s2,
              alignment: WrapAlignment.center,
              children: [
                HrmBadge(
                  clock.phase == ClockPhase.working
                      ? (clock.isOutwork ? 'Outwork Active' : 'Clocked in')
                      : 'Off Shift',
                  tone: clock.phase == ClockPhase.working ? Tone.success : Tone.neutral,
                ),
                HrmBadge('ID ${profile.employeeId}'),
                HrmBadge(clock.location),
              ],
            ),
          ],
        ).rise(1),
        HrmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s3,
            children: [
              Row(children: [
                Expanded(child: Text('Profile 85% complete', style: T.bodyStrong.col(c.textPrimary))),
                const HrmBadge('Cloudinary connected', tone: Tone.success),
              ]),
              const ProgressBar(value: 0.85),
              HrmButton(
                'Change photo (Cloudinary)',
                kind: BtnKind.secondary,
                size: BtnSize.md,
                icon: LucideIcons.uploadCloud,
                onPressed: _showPhotoOptions,
              ),
            ],
          ),
        ).rise(2),
        const Overline('Account'),
        HrmList(children: [
          HrmListTile(
            leading: const LeadIcon(LucideIcons.user, size: 36, circle: false),
            title: 'Personal info',
            subtitle: '${profile.phone} · ${profile.email}',
            chevron: true,
            onTap: () => _showEditProfileSheet(profile),
          ),
          HrmListTile(
            leading: const LeadIcon(LucideIcons.fileText, size: 36, circle: false),
            title: 'Documents',
            subtitle: 'Contract, National ID, 2 more',
            trailing: const HrmBadge('1 to sign', tone: Tone.warning),
            chevron: true,
            onTap: () => context.push('/documents'),
          ),
          HrmListTile(
            leading: const LeadIcon(LucideIcons.users, size: 36, circle: false),
            title: 'People directory',
            subtitle: 'Find and contact colleagues',
            chevron: true,
            onTap: () => context.push('/directory'),
          ),
          HrmListTile(
            leading: const LeadIcon(LucideIcons.listChecks, size: 36, circle: false),
            title: 'My tasks',
            subtitle: 'First-week checklist · 4 of 7',
            chevron: true,
            onTap: () => context.push('/tasks'),
          ),
          HrmListTile(
            leading: const LeadIcon(LucideIcons.cloud, size: 36, circle: false),
            title: 'Backend & Cloud Storage',
            subtitle: FirebaseService.isInitialized
                ? 'Firebase Auth & Firestore live'
                : 'Firebase offline mode · Cloudinary ready',
            trailing: HrmBadge(
              FirebaseService.isInitialized ? 'Live' : 'Ready',
              tone: FirebaseService.isInitialized ? Tone.success : Tone.info,
            ),
            chevron: false,
          ),
        ]).rise(3),
        const Overline('Security'),
        HrmList(children: [
          toggle(LucideIcons.scanFace, 'Face ID', 'Unlock the app and reveal pay', s.face,
              (o, v) => o.copyWith(face: v)),
          toggle(LucideIcons.fingerprint, 'Passkey', 'Sign in without a password', s.passkey,
              (o, v) => o.copyWith(passkey: v)),
          toggle(LucideIcons.lock, 'App lock PIN', 'Ask for a PIN after 1 minute', s.pin,
              (o, v) => o.copyWith(pin: v)),
        ]).rise(4),
        const Overline('Appearance'),
        HrmCard(
          padding: const EdgeInsets.all(Sp.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Sp.s3,
            children: [
              HrmSegmented(
                labels: const ['Light', 'Dark'],
                icons: const [LucideIcons.sun, LucideIcons.moon],
                index: (mode == ThemeMode.dark ||
                        (mode == ThemeMode.system &&
                            MediaQuery.platformBrightnessOf(context) == Brightness.dark))
                    ? 1
                    : 0,
                onChanged: (i) => ref
                    .read(themeModeProvider.notifier)
                    .set(i == 1 ? ThemeMode.dark : ThemeMode.light),
              ),
              Row(spacing: Sp.s2, children: [
                HrmChip('English',
                    selected: !s.bengali,
                    height: 40,
                    onTap: () => notifier.update((o) => o.copyWith(bengali: false))),
                HrmChip('বাংলা',
                    selected: s.bengali,
                    height: 40,
                    onTap: () => notifier.update((o) => o.copyWith(bengali: true))),
              ]),
            ],
          ),
        ).rise(5),
        const Overline('Notifications'),
        HrmList(children: [
          toggle(LucideIcons.bell, 'Push notifications',
              'Approvals, payslips, announcements', s.push, (o, v) => o.copyWith(push: v)),
          toggle(LucideIcons.clock, 'Clock-in reminder', 'At 8:50 AM on working days', s.remind,
              (o, v) => o.copyWith(remind: v)),
          toggle(LucideIcons.mail, 'Weekly email digest', 'A summary every Monday', s.mail,
              (o, v) => o.copyWith(mail: v)),
        ]).rise(6),
        const SizedBox(height: Sp.s2),
        HrmList(children: [
          HrmListTile(
            leading: const LeadIcon(LucideIcons.sparkles, size: 36, circle: false),
            title: 'Help and Ask HR',
            subtitle: 'Policies, questions, support',
            chevron: true,
            onTap: () => context.push('/ask-hr'),
          ),
          HrmListTile(
            leading: LeadIcon(LucideIcons.logOut,
                size: 36, circle: false, bg: c.dangerSoft, fg: c.danger),
            title: 'Log out',
            titleColor: c.danger,
            onTap: () async {
              final ok = await showHrmConfirm(
                context,
                title: 'Log out of HRM?',
                message:
                    "You'll need your password or Face ID to sign back in. Your clock-in stays recorded.",
                confirmLabel: 'Log out',
              );
              if (ok && context.mounted) {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/signin');
              }
            },
          ),
        ]).rise(7),
        Center(
          child: Text('HRM 2.4.0 · ${profile.companyCode}',
              style: T.caption.col(c.textSecondary)),
        ),
      ],
    );
  }
}
