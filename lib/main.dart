import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'shared/storage_service.dart';

/// Global flag indicating whether Firebase was successfully initialized.
/// Checked by AuthNotifier to decide between real Firebase Auth or simulated guest mode.
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Initialize date formatting for Portuguese
  await initializeDateFormatting('pt_BR', null);

  // Initialize Local Persistence Storage (Hive)
  await StorageService.init();

  // Safeguarded Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint("Firebase init failed or was not configured yet: $e");
    debugPrint("App will run in fallback simulated mode until valid credentials are added to .env.");
  }


  runApp(
    const ProviderScope(
      child: LeveApp(),
    ),
  );
}
