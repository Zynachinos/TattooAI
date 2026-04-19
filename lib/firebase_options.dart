import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        // iOS config wird beim Mac-Handoff via FlutterFire CLI ergänzt
        throw UnsupportedError('iOS Firebase config noch nicht konfiguriert.');
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqgUMVQUKeRXlTVtqAVAZ2YIWiYdRvvfM',
    appId: '1:367078395660:android:3c3c800acd2881a21b0329',
    messagingSenderId: '367078395660',
    projectId: 'tattooai-3ca74',
    storageBucket: 'tattooai-3ca74.firebasestorage.app',
    databaseURL: 'https://tattooai-3ca74-default-rtdb.europe-west1.firebasedatabase.app',
  );
}
