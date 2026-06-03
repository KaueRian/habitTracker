import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/preferences_provider.dart';
import 'shared/navigation_shell.dart';
import 'theme/leve_theme.dart';

class LeveApp extends ConsumerWidget {
  const LeveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final seasonalTheme = ref.watch(seasonalThemeProvider);

    // Direct routing: if user is logged in OR simulated guest mode is active
    final bool isAuthenticated = authState.user != null || authState.isGuest;

    return MaterialApp(
      title: 'Leve: Hábitos & Diário',
      debugShowCheckedModeBanner: false,
      theme: LeveTheme.getThemeData(seasonalTheme),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      home: isAuthenticated ? const NavigationShell() : const LoginScreen(),
    );
  }
}
