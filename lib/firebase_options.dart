import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7GlG9KtBLz4_ZHw09F-1K0o-KY3mi_OQ',
    appId: '1:1024478255871:web:28bb2149c7bf4ab0c70aca',
    messagingSenderId: '1024478255871',
    projectId: 'lakhu-acnvtu',
    authDomain: 'lakhu-acnvtu.firebaseapp.com',
    databaseURL: 'https://lakhu-acnvtu.firebaseio.com',
    storageBucket: 'lakhu-acnvtu.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCHzneiRuI-_KLnfZ4i_JILNt3ANWu02g4',
    appId: '1:1024478255871:android:4ddf6476a2ca0830c70aca',
    messagingSenderId: '1024478255871',
    projectId: 'lakhu-acnvtu',
    databaseURL: 'https://lakhu-acnvtu.firebaseio.com',
    storageBucket: 'lakhu-acnvtu.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArK5COn3RZv9JOxRcd5MZxCNgtuZwOmoc',
    appId: '1:1024478255871:ios:78b4ddbbb34e08dcc70aca',
    messagingSenderId: '1024478255871',
    projectId: 'lakhu-acnvtu',
    databaseURL: 'https://lakhu-acnvtu.firebaseio.com',
    storageBucket: 'lakhu-acnvtu.firebasestorage.app',
    iosBundleId: 'com.example.rkEnterprises',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyArK5COn3RZv9JOxRcd5MZxCNgtuZwOmoc',
    appId: '1:1024478255871:ios:78b4ddbbb34e08dcc70aca',
    messagingSenderId: '1024478255871',
    projectId: 'lakhu-acnvtu',
    databaseURL: 'https://lakhu-acnvtu.firebaseio.com',
    storageBucket: 'lakhu-acnvtu.firebasestorage.app',
    iosBundleId: 'com.example.rkEnterprises',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA7GlG9KtBLz4_ZHw09F-1K0o-KY3mi_OQ',
    appId: '1:1024478255871:web:a153a7cf8f563f4dc70aca',
    messagingSenderId: '1024478255871',
    projectId: 'lakhu-acnvtu',
    authDomain: 'lakhu-acnvtu.firebaseapp.com',
    databaseURL: 'https://lakhu-acnvtu.firebaseio.com',
    storageBucket: 'lakhu-acnvtu.firebasestorage.app',
  );
}
