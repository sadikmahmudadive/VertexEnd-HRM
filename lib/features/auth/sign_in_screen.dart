import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/firebase/firebase_service.dart';
import '../../core/state/app_state.dart';
import '../../core/ui.dart';

enum _Scan { idle, scanning, ok }

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  _Scan _scan = _Scan.idle;
  Timer? _timer;
  bool _loading = false;
  bool _obscurePassword = true;

  final _companyCodeController = TextEditingController(text: 'ACME-DHK');
  final _emailController = TextEditingController(text: 'rahim@acme.com.bd');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _timer?.cancel();
    _companyCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      showHrmToast(context, 'Please enter your work email');
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signIn(email: email, password: password);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        showHrmToast(
          context,
          'Auth error: $e. Entering with demo profile.',
          actionLabel: 'Proceed',
          onAction: () => context.go('/home'),
          bottom: 32,
        );
        // Seamless fallback
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) context.go('/home');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startScan() {
    if (_scan != _Scan.idle) return;
    HapticFeedback.lightImpact();
    setState(() => _scan = _Scan.scanning);
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _scan = _Scan.ok);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bgCanvas,
      resizeToAvoidBottomInset: true,
      body: HrmBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Sp.s6, Sp.s2, Sp.s6, Sp.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    HrmIconButton(
                        icon: LucideIcons.chevronLeft,
                        label: 'Back',
                        onTap: () => context.go('/')),
                    const SizedBox(width: Sp.s3),
                    Text('HRM', style: T.h3.col(c.textPrimary)),
                    const Spacer(),
                    HrmBadge(
                      FirebaseService.isInitialized ? 'Firebase Connected' : 'Demo Mode',
                      tone: FirebaseService.isInitialized ? Tone.success : Tone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: Sp.s8),
                Text('Welcome back', style: T.display.col(c.textPrimary)).rise(),
                const SizedBox(height: Sp.s1),
                Text('Sign in with Firebase or biometric passkey.',
                        style: T.body.col(c.textSecondary))
                    .rise(1),
                const SizedBox(height: Sp.s8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Sp.s4,
                  children: [
                    HrmField(
                      label: 'Company code',
                      controller: _companyCodeController,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const HrmBadge('Acme Bangladesh Ltd', tone: Tone.success)
                          .popIn(2),
                    ),
                    HrmField(
                      label: 'Work email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    HrmField(
                      label: 'Password',
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                          size: 18,
                          color: c.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    HrmButton(
                      'Continue',
                      loading: _loading,
                      onPressed: _handleSignIn,
                    ),
                    HrmButton('Use single sign-on',
                        kind: BtnKind.ghost,
                        size: BtnSize.md,
                        onPressed: () => context.go('/home')),
                  ],
                ).rise(2),
                const SizedBox(height: Sp.s8),
                Row(children: [
                  Expanded(child: Divider(color: c.borderDefault)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.s3),
                    child: Text('or', style: T.caption.col(c.textSecondary)),
                  ),
                  Expanded(child: Divider(color: c.borderDefault)),
                ]),
                const SizedBox(height: Sp.s5),
                Center(child: _FaceButton(scan: _scan, onTap: _startScan)),
                const SizedBox(height: Sp.s3),
                Center(
                  child: Text(
                    switch (_scan) {
                      _Scan.idle => 'Sign in with Face ID',
                      _Scan.scanning => 'Scanning',
                      _Scan.ok => 'Welcome back, Rahim',
                    },
                    style: T.bodyStrong.col(c.textPrimary),
                  ),
                ),
                const SizedBox(height: Sp.s1),
                Center(
                  child: Text(
                    _scan == _Scan.ok
                        ? 'Verified on this phone.'
                        : 'Your passkey stays on this phone.',
                    style: T.caption.col(c.textSecondary),
                  ),
                ),
                if (_scan == _Scan.ok) ...[
                  const SizedBox(height: Sp.s4),
                  Center(
                    child: HrmButton('Open Home',
                            kind: BtnKind.secondary,
                            size: BtnSize.md,
                            expand: false,
                            onPressed: () => context.go('/home'))
                        .popIn(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaceButton extends StatelessWidget {
  const _FaceButton({required this.scan, required this.onTap});
  final _Scan scan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ok = scan == _Scan.ok;
    return PressScale(
      onTap: onTap,
      scale: 0.95,
      semanticLabel: 'Sign in with Face ID',
      child: SizedBox(
        width: 104,
        height: 104,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (scan == _Scan.idle)
              for (var i = 0; i < 2; i++)
                Container(
                  width: 104,
                  height: 104,
                  decoration:
                      BoxDecoration(color: c.primary500, shape: BoxShape.circle),
                )
                    .animate(delay: (i * 700).ms, onPlay: (ctl) => ctl.repeat())
                    .scale(
                        begin: const Offset(.8, .8),
                        end: const Offset(1.7, 1.7),
                        duration: 2200.ms,
                        curve: Curves.easeOut)
                    .fadeOut(duration: 2200.ms, begin: .5),
            AnimatedContainer(
              duration: Motion.base,
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: ok ? c.successSoft : c.primary50,
                shape: BoxShape.circle,
              ),
              child: ok
                  ? Icon(LucideIcons.check, size: 44, color: c.success)
                      .popIn()
                  : ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(LucideIcons.scanFace, size: 60, color: c.primary600),
                          if (scan == _Scan.scanning)
                            Positioned(
                              left: 22,
                              right: 22,
                              top: 22,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                    color: c.primary500, borderRadius: Rd.rFull),
                              )
                                  .animate(onPlay: (ctl) => ctl.repeat(reverse: true))
                                  .moveY(
                                      begin: 0,
                                      end: 58,
                                      duration: 1200.ms,
                                      curve: Curves.easeInOut),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
