// File generated for FlutterFire integration in VertexHand HRM.
// Replace the placeholder values with your Firebase project credentials,
// or run `flutterfire configure` to generate automatically.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Returns true if custom project credentials have been configured.
  /// When false, the app automatically runs in local/offline fallback mode.
  static bool get isConfigured =>
      android.apiKey != 'YOUR-ANDROID-API-KEY' &&
      android.projectId != 'YOUR-PROJECT-ID';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-WEB-API-KEY',
    appId: '1:100000000000:web:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'vertexhand-hrm-prod',
    authDomain: 'vertexhand-hrm-prod.firebaseapp.com',
    storageBucket: 'vertexhand-hrm-prod.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: '1:100000000000:android:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'vertexhand-hrm-prod',
    storageBucket: 'vertexhand-hrm-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: '1:100000000000:ios:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'vertexhand-hrm-prod',
    storageBucket: 'vertexhand-hrm-prod.appspot.com',
    iosBundleId: 'com.vertexhand.vertexhandHrm',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: '1:100000000000:ios:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'vertexhand-hrm-prod',
    storageBucket: 'vertexhand-hrm-prod.appspot.com',
    iosBundleId: 'com.vertexhand.vertexhandHrm',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR-WINDOWS-API-KEY',
    appId: '1:100000000000:web:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'vertexhand-hrm-prod',
    storageBucket: 'vertexhand-hrm-prod.appspot.com',
  );
}

