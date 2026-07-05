import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxcal_app/data/prefs/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to legal notice not accepted', () async {
    final prefs = await AppPreferences.create();
    expect(prefs.avisoLegalAceptado, isFalse);
  });

  test('persists legal notice acceptance', () async {
    final prefs = await AppPreferences.create();
    await prefs.aceptarAvisoLegal();
    expect(prefs.avisoLegalAceptado, isTrue);
  });

  test('persists taxpayer profile fields', () async {
    final prefs = await AppPreferences.create();
    await prefs.guardarNombreContribuyente('Juana Pérez');
    await prefs.guardarRfcContribuyente('PEXJ800101ABC');

    expect(prefs.nombreContribuyente, 'Juana Pérez');
    expect(prefs.rfcContribuyente, 'PEXJ800101ABC');
  });

  test('defaults active year/month to current date when unset', () async {
    final prefs = await AppPreferences.create();
    final now = DateTime.now();
    expect(prefs.anioActivo, now.year);
    expect(prefs.mesActivo, now.month);
  });

  test('persists active year/month selection', () async {
    final prefs = await AppPreferences.create();
    await prefs.guardarAnioActivo(2026);
    await prefs.guardarMesActivo(6);

    expect(prefs.anioActivo, 2026);
    expect(prefs.mesActivo, 6);
  });
}
