import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configurações do Firebase para o projeto Leve.
/// Os valores são carregados do arquivo .env na raiz do projeto.
/// Copie .env.example → .env e preencha com as suas credenciais.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
    appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? '',
    messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'] ?? '',
    projectId: dotenv.env['FIREBASE_WEB_PROJECT_ID'] ?? '',
    authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] ?? '',
    storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'] ?? '',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
    appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
    messagingSenderId: dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'] ?? '',
    projectId: dotenv.env['FIREBASE_ANDROID_PROJECT_ID'] ?? '',
    storageBucket: dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'] ?? '',
  );
}