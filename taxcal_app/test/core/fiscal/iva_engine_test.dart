import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/fiscal/iva_engine.dart';

void main() {
  group('IvaEngine.calcularDefinitivoMensual', () {
    test('IVA a cargo when cobrado exceeds acreditable', () {
      final resultado = IvaEngine.calcularDefinitivoMensual(
        ivaCobrado: 1600,
        ivaAcreditable: 800,
        ivaRetenidoDelPeriodo: 0,
        saldoAFavorPeriodosAnteriores: 0,
      );

      expect(resultado.impuestoNeto, 800);
      expect(resultado.esACargo, isTrue);
      expect(resultado.esSaldoAFavor, isFalse);
    });

    test('saldo a favor when acreditable exceeds cobrado', () {
      final resultado = IvaEngine.calcularDefinitivoMensual(
        ivaCobrado: 500,
        ivaAcreditable: 1200,
        ivaRetenidoDelPeriodo: 0,
        saldoAFavorPeriodosAnteriores: 0,
      );

      expect(resultado.impuestoNeto, -700);
      expect(resultado.esSaldoAFavor, isTrue);
      expect(resultado.esACargo, isFalse);
    });

    test('subtracts retained IVA and prior period favor balance', () {
      final resultado = IvaEngine.calcularDefinitivoMensual(
        ivaCobrado: 2000,
        ivaAcreditable: 500,
        ivaRetenidoDelPeriodo: 300,
        saldoAFavorPeriodosAnteriores: 400,
      );

      expect(resultado.impuestoNeto, 2000 - 500 - 300 - 400);
    });
  });
}
