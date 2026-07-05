import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/fiscal/deducciones_personales_engine.dart';
import 'package:taxcal_app/data/db/app_database.dart';
import 'package:taxcal_app/data/db/tables.dart';

DeduccionPersonal _deduccion({
  int id = 1,
  double monto = 1000,
  FormaPagoPersonal formaPago = FormaPagoPersonal.tarjeta,
  bool esFunerario = false,
}) => DeduccionPersonal(
  id: id,
  ejercicioFiscal: 2026,
  concepto: 'Gasto de prueba',
  monto: monto,
  formaPago: formaPago,
  esFunerario: esFunerario,
  creadoEn: DateTime(2026, 1, 1),
);

void main() {
  group('DeduccionesPersonalesEngine.esElegible', () {
    test('tarjeta is always eligible', () {
      expect(
        DeduccionesPersonalesEngine.esElegible(
          formaPago: FormaPagoPersonal.tarjeta,
          esFunerario: false,
        ),
        isTrue,
      );
    });

    test('efectivo is not eligible unless funerario', () {
      expect(
        DeduccionesPersonalesEngine.esElegible(
          formaPago: FormaPagoPersonal.efectivo,
          esFunerario: false,
        ),
        isFalse,
      );
      expect(
        DeduccionesPersonalesEngine.esElegible(
          formaPago: FormaPagoPersonal.efectivo,
          esFunerario: true,
        ),
        isTrue,
      );
    });
  });

  group('DeduccionesPersonalesEngine.topeGlobalAnual', () {
    test('picks 15% of income when it is the smaller amount', () {
      final tope = DeduccionesPersonalesEngine.topeGlobalAnual(
        ingresosAnuales: 100000,
        umaAnual: 42794.64,
      );
      expect(tope, closeTo(15000, 0.01)); // 15% de 100,000 < 5 UMA (213,973.20)
    });

    test('picks 5 UMA when income is very high', () {
      final tope = DeduccionesPersonalesEngine.topeGlobalAnual(
        ingresosAnuales: 5000000,
        umaAnual: 42794.64,
      );
      expect(tope, closeTo(213973.20, 0.01)); // 5 * 42,794.64
    });
  });

  group('DeduccionesPersonalesEngine.sumaAplicada', () {
    test('sums only eligible deductions', () {
      final deducciones = [
        _deduccion(id: 1, monto: 1000, formaPago: FormaPagoPersonal.tarjeta),
        _deduccion(id: 2, monto: 500, formaPago: FormaPagoPersonal.efectivo),
        _deduccion(
          id: 3,
          monto: 300,
          formaPago: FormaPagoPersonal.efectivo,
          esFunerario: true,
        ),
      ];

      final suma = DeduccionesPersonalesEngine.sumaAplicada(
        deducciones: deducciones,
        tope: 100000,
      );

      expect(suma, 1300); // 1000 + 300 (funerario), excluye los 500 en efectivo
    });

    test('clamps the sum to the global cap', () {
      final deducciones = [
        _deduccion(id: 1, monto: 100000, formaPago: FormaPagoPersonal.tarjeta),
      ];

      final suma = DeduccionesPersonalesEngine.sumaAplicada(deducciones: deducciones, tope: 15000);

      expect(suma, 15000);
    });
  });
}
