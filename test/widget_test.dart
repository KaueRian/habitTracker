import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leve/app.dart';

void main() {
  testWidgets('Onboarding/Login screen renders successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LeveApp(),
      ),
    );

    // Verify that the logo "leve." is displayed.
    expect(find.text('leve.'), findsOneWidget);
    expect(find.text('Entrar como Visitante'), findsOneWidget);
  });
}
