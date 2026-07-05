import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxcal_app/features/onboarding/onboarding_controller.dart';
import 'package:taxcal_app/features/onboarding/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('accept button is disabled until the checkbox is checked', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Antes de empezar'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Aceptar y continuar'));
    expect(button.onPressed, isNull);

    await tester.tap(find.textContaining('He leído y entiendo'));
    await tester.pumpAndSettle();

    final buttonAfterCheck =
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Aceptar y continuar'));
    expect(buttonAfterCheck.onPressed, isNotNull);
  });

  testWidgets('accepting persists the legal notice acceptance', (tester) async {
    late final ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        child: Builder(builder: (context) {
          container = ProviderScope.containerOf(context);
          return const MaterialApp(home: OnboardingScreen());
        }),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('He leído y entiendo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aceptar y continuar'));
    await tester.pumpAndSettle();

    expect(container.read(onboardingStatusProvider).value, isTrue);
  });
}
