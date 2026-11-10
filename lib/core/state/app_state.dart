import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';

// ------------------------------------------------------------------ Theme

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;
  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ------------------------------------------------------------------ Clock-in

enum ClockPhase { idle, confirming, working, onBreak }

class ClockState {
  const ClockState(
    this.phase,
    this.seconds, {
    this.isOutwork = false,
    this.location = 'Head Office',
    this.clientName = '',
  });

  final ClockPhase phase;
  final int seconds;
  final bool isOutwork;
  final String location;
  final String clientName;

  String get text {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Progress through a 9 hour shift.
  double get progress => (seconds / (9 * 3600)).clamp(0, 1).toDouble();

  ClockState copyWith({
    ClockPhase? phase,
    int? seconds,
    bool? isOutwork,
    String? location,
    String? clientName,
  }) {
    return ClockState(
      phase ?? this.phase,
      seconds ?? this.seconds,
      isOutwork: isOutwork ?? this.isOutwork,
      location: location ?? this.location,
      clientName: clientName ?? this.clientName,
    );
  }
}

class ClockNotifier extends Notifier<ClockState> {
  Timer? _timer;
  String? _attendanceDocId;

  @override
  ClockState build() {
    ref.onDispose(() => _timer?.cancel());
    return const ClockState(ClockPhase.idle, 0);
  }

  void _run() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase == ClockPhase.working) {
        state = state.copyWith(seconds: state.seconds + 1);
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Shows an already clocked-in state (used by the dark preview and tests).
  void startAt(int seconds) {
    state = state.copyWith(phase: ClockPhase.working, seconds: seconds);
    _run();
  }

  void setOutwork({required bool isOutwork, String? location, String? clientName}) {
    state = state.copyWith(
      isOutwork: isOutwork,
      location: location ?? (isOutwork ? 'Client Site · Gulshan 2' : 'Head Office'),
      clientName: clientName ?? (isOutwork ? 'Client Visit' : ''),
    );
  }

  void toggleOutwork([String? location, String? clientName]) {
    final next = !state.isOutwork;
    setOutwork(isOutwork: next, location: location, clientName: clientName);
  }

  Future<void> clockIn({bool? isOutwork, String? location, String? clientName}) async {
    if (state.phase != ClockPhase.idle) return;
    final outwork = isOutwork ?? state.isOutwork;
    final loc = location ??
        (outwork
            ? (state.location.isEmpty ? 'Client Site · Gulshan 2' : state.location)
            : 'Head Office');
    final client = clientName ?? state.clientName;
    state = ClockState(
      ClockPhase.confirming,
      0,
      isOutwork: outwork,
      location: loc,
      clientName: client,
    );
    await Future<void>.delayed(const Duration(milliseconds: 650));
    state = ClockState(
      ClockPhase.working,
      0,
      isOutwork: outwork,
      location: loc,
      clientName: client,
    );
    _run();

    // Sync to Firestore
    try {
      final auth = ref.read(authServiceProvider);
      final firestore = ref.read(firestoreServiceProvider);
      firestore
          .recordClockIn(
            userId: auth.currentUserId,
            isOutwork: outwork,
            location: loc,
            clientName: client,
          )
          .then((id) => _attendanceDocId = id);
    } catch (_) {}
  }

  void toggleBreak() {
    if (state.phase == ClockPhase.working) {
      state = state.copyWith(phase: ClockPhase.onBreak);
    } else if (state.phase == ClockPhase.onBreak) {
      state = state.copyWith(phase: ClockPhase.working);
    }
  }

  void clockOut() {
    _stop();
    if (_attendanceDocId != null) {
      try {
        final firestore = ref.read(firestoreServiceProvider);
        firestore.recordClockOut(
          attendanceId: _attendanceDocId!,
          totalSeconds: state.seconds,
        );
      } catch (_) {}
      _attendanceDocId = null;
    }
    state = state.copyWith(phase: ClockPhase.idle, seconds: 0);
  }
}

final clockProvider =
    NotifierProvider<ClockNotifier, ClockState>(ClockNotifier.new);

// ------------------------------------------------------------------ Notifications

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => Mock.notifications;

  void markAllRead() =>
      state = [for (final n in state) n.copyWith(unread: false)];

  void act(int id, String result) => state = [
        for (final n in state)
          n.id == id ? n.copyWith(unread: false, result: result) : n,
      ];
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
        NotificationsNotifier.new);

final unreadCountProvider = Provider<int>(
    (ref) => ref.watch(notificationsProvider).where((n) => n.unread).length);

// ------------------------------------------------------------------ Approvals

enum Decision { approved, rejected }

class ApprovalsNotifier extends Notifier<Map<int, Decision>> {
  @override
  Map<int, Decision> build() => const {};

  void decide(int id, Decision d) => state = {...state, id: d};
  void undo(int id) => state = {...state}..remove(id);
}

final approvalsProvider =
    NotifierProvider<ApprovalsNotifier, Map<int, Decision>>(
        ApprovalsNotifier.new);

final pendingApprovalsProvider = Provider<int>(
    (ref) => Mock.approvals.length - ref.watch(approvalsProvider).length);

// ------------------------------------------------------------------ Settings

class Settings {
  const Settings({
    this.face = true,
    this.passkey = true,
    this.pin = false,
    this.push = true,
    this.remind = true,
    this.mail = false,
    this.bengali = false,
  });
  final bool face;
  final bool passkey;
  final bool pin;
  final bool push;
  final bool remind;
  final bool mail;
  final bool bengali;

  Settings copyWith({
    bool? face,
    bool? passkey,
    bool? pin,
    bool? push,
    bool? remind,
    bool? mail,
    bool? bengali,
  }) =>
      Settings(
        face: face ?? this.face,
        passkey: passkey ?? this.passkey,
        pin: pin ?? this.pin,
        push: push ?? this.push,
        remind: remind ?? this.remind,
        mail: mail ?? this.mail,
        bengali: bengali ?? this.bengali,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => const Settings();
  void update(Settings Function(Settings) f) => state = f(state);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

// ------------------------------------------------------------------ Backend Providers (Firebase & Cloudinary)

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) => CloudinaryService());

class UserProfile {
  const UserProfile({
    required this.name,
    required this.role,
    required this.dept,
    required this.email,
    required this.employeeId,
    required this.companyCode,
    this.avatarUrl,
    this.phone = '+880 1712 345678',
  });

  final String name;
  final String role;
  final String dept;
  final String email;
  final String employeeId;
  final String companyCode;
  final String? avatarUrl;
  final String phone;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'ME';
  }

  UserProfile copyWith({
    String? name,
    String? role,
    String? dept,
    String? email,
    String? employeeId,
    String? companyCode,
    String? avatarUrl,
    String? phone,
  }) =>
      UserProfile(
        name: name ?? this.name,
        role: role ?? this.role,
        dept: dept ?? this.dept,
        email: email ?? this.email,
        employeeId: employeeId ?? this.employeeId,
        companyCode: companyCode ?? this.companyCode,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phone: phone ?? this.phone,
      );
}

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return const UserProfile(
      name: Mock.meName,
      role: 'Senior product designer',
      dept: 'Design',
      email: 'rahim@acme.com.bd',
      employeeId: 'ACME-0142',
      companyCode: 'ACME-DHK',
      avatarUrl: null,
    );
  }

  void updateAvatar(String newUrl) {
    state = state.copyWith(avatarUrl: newUrl);
    try {
      final auth = ref.read(authServiceProvider);
      final firestore = ref.read(firestoreServiceProvider);
      firestore.updateAvatarUrl(auth.currentUserId, newUrl);
    } catch (_) {}
  }

  void updateProfile({String? name, String? role, String? dept, String? phone}) {
    state = state.copyWith(
      name: name,
      role: role,
      dept: dept,
      phone: phone,
    );
    try {
      final auth = ref.read(authServiceProvider);
      final firestore = ref.read(firestoreServiceProvider);
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (role != null) updates['role'] = role;
      if (dept != null) updates['dept'] = dept;
      if (phone != null) updates['phone'] = phone;
      firestore.updateUserProfile(auth.currentUserId, updates);
    } catch (_) {}
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);
