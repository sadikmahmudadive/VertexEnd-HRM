import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_service.dart';

/// User profile representation used across authentication and state.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'Senior product designer',
    this.department = 'Design',
    this.companyCode = 'ACME-DHK',
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final String department;
  final String companyCode;

  factory AuthUser.fromFirebaseUser(User user, {Map<String, dynamic>? firestoreData}) {
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (firestoreData?['name'] as String? ?? 'Employee'),
      photoUrl: user.photoURL ?? (firestoreData?['avatarUrl'] as String?),
      role: firestoreData?['role'] as String? ?? 'Team Member',
      department: firestoreData?['dept'] as String? ?? 'General',
      companyCode: firestoreData?['companyCode'] as String? ?? 'ACME-DHK',
    );
  }
}

/// Service wrapping FirebaseAuth operations with offline/demo fallback.
class AuthService {
  AuthService() {
    if (FirebaseService.isInitialized) {
      FirebaseService.auth?.authStateChanges().listen((user) {
        _cachedFirebaseUser = user;
        _userController.add(user);
      });
    }
  }

  User? _cachedFirebaseUser;
  final _userController = StreamController<User?>.broadcast();

  // Local demo user for offline mode
  static const AuthUser demoUser = AuthUser(
    uid: 'ra',
    email: 'rahim@acme.com.bd',
    displayName: 'Rahim Ahmed',
    photoUrl: null,
    role: 'Senior product designer',
    department: 'Design',
    companyCode: 'ACME-DHK',
  );

  /// Stream of Firebase Auth user changes.
  Stream<User?> get authStateChanges =>
      FirebaseService.isInitialized && FirebaseService.auth != null
          ? FirebaseService.auth!.authStateChanges()
          : _userController.stream;

  /// Current signed-in Firebase user (if initialized).
  User? get currentFirebaseUser =>
      FirebaseService.isInitialized ? FirebaseService.auth?.currentUser : _cachedFirebaseUser;

  String get currentUserId => currentFirebaseUser?.uid ?? demoUser.uid;

  bool get isSignedIn =>
      FirebaseService.isInitialized ? FirebaseService.auth?.currentUser != null : true;

  /// Sign in with email and password.
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.isInitialized || FirebaseService.auth == null) {
      debugPrint('ℹ️ [AuthService] Firebase offline/demo sign in for: $email');
      return null;
    }

    try {
      final credential = await FirebaseService.auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('⚠️ [AuthService] Firebase Auth error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Register / sign up a new user with email and password.
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String displayName,
    String? role,
    String? department,
  }) async {
    if (!FirebaseService.isInitialized || FirebaseService.auth == null) {
      debugPrint('ℹ️ [AuthService] Firebase offline: simulated signup for $email');
      return null;
    }

    try {
      final credential = await FirebaseService.auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('⚠️ [AuthService] Firebase Auth registration error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    if (FirebaseService.isInitialized && FirebaseService.auth != null) {
      await FirebaseService.auth!.signOut();
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    if (FirebaseService.isInitialized && FirebaseService.auth != null) {
      await FirebaseService.auth!.sendPasswordResetEmail(email: email.trim());
    }
  }
}

