import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Centralized manager for Firebase initialization and service access.
class FirebaseService {
  static bool _initialized = false;
  static String? _initError;

  static bool get isInitialized => _initialized;
  static String? get initError => _initError;

  /// Safe initialization that won't crash if keys are unconfigured or offline.
  static Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      if (!DefaultFirebaseOptions.isConfigured) {
        debugPrint(
          'ℹ️ [FirebaseService] Running in local/mock mode: '
          'FirebaseOptions not yet configured with your project keys in '
          'lib/core/firebase/firebase_options.dart',
        );
        return false;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      _initError = null;
      debugPrint('✅ [FirebaseService] Firebase successfully initialized.');
      return true;
    } catch (e, st) {
      _initError = e.toString();
      debugPrint('⚠️ [FirebaseService] Initialization failed: $e\n$st');
      return false;
    }
  }

  /// Safe accessor for FirebaseAuth. Returns null if not initialized.
  static FirebaseAuth? get auth {
    if (!_initialized) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Safe accessor for FirebaseFirestore. Returns null if not initialized.
  static FirebaseFirestore? get firestore {
    if (!_initialized) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }
}

