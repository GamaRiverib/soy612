import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxcal_app/app_providers.dart';
import 'package:taxcal_app/data/db/app_database.dart';
import 'package:taxcal_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows onboarding when the legal notice has not been accepted', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaxCalApp()));
    await tester.pumpAndSettle();

    expect(find.text('TaxCal'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
  });

  testWidgets('shows the main app shell when the legal notice was already accepted', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_aviso_legal_aceptado': true});

    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const TaxCalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tablero'), findsWidgets);

    // Dispose the provider tree (and its Drift stream subscriptions) while
    // still inside the controlled test zone, then pump once more so any
    // pending internal Drift timer fires before the test ends — otherwise
    // flutter_test's teardown invariant check ("Timer is still pending")
    // fails because that timer would only fire during framework teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
