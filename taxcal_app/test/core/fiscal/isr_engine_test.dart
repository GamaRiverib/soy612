import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/fiscal/isr_engine.dart';
import 'package:taxcal_app/core/fiscal/tarifa_isr.dart';

TablaTarifaIsr _tabla2026Mensual() => TablaTarifaIsr.fromJson({
  'anio': 2026,
  'renglones': [
    {'limiteInferior': 0.01, 'limiteSuperior': 844.59, 'cuotaFija': 0, 'tasa': 1.92},
    {'limiteInferior': 844.6, 'limiteSuperior': 7168.51, 'cuotaFija': 16.22, 'tasa': 6.4},
    {'limiteInferior': 7168.52, 'limiteSuperior': 12598.02, 'cuotaFija': 420.95, 'tasa': 10.88},
    {'limiteInferior': 12598.03, 'limiteSuperior': 14644.64, 'cuotaFija': 1011.68, 'tasa': 16},
    {'limiteInferior': 14644.65, 'limiteSuperior': 17533.64, 'cuotaFija': 1339.14, 'tasa': 17.92},
    {'limiteInferior': 17533.65, 'limiteSuperior': 35362.83, 'cuotaFija': 1856.84, 'tasa': 21.36},
    {'limiteInferior': 35362.84, 'limiteSuperior': 55736.68, 'cuotaFija': 5665.16, 'tasa': 23.52},
    {'limiteInferior': 55736.69, 'limiteSuperior': 106410.5, 'cuotaFija': 10457.09, 'tasa': 30},
    {'limiteInferior': 106410.51, 'limiteSuperior': 141880.66, 'cuotaFija': 25659.23, 'tasa': 32},
    {'limiteInferior': 141880.67, 'limiteSuperior': 425641.99, 'cuotaFija': 37009.69, 'tasa': 34},
    {'limiteInferior': 425642.0, 'limiteSuperior': null, 'cuotaFija': 133488.54, 'tasa': 35},
  ],
});

void main() {
  group('IsrEngine.calcularProvisionalMensual', () {
    test('January (no scaling): base 20,000 lands on bracket 6', () {
      final resultado = IsrEngine.calcularProvisionalMensual(
        ingresosCobradosAcumulados: 20000,
        deduccionesAutorizadasAcumuladas: 0,
        ptuPagada: 0,
        perdidasFiscalesAnteriores: 0,
        tarifaEneroMensual: _tabla2026Mensual(),
        mesActivo: 1,
        pagosProvisionalesAnteriores: 0,
        isrRetenidoAcumulado: 0,
      );

      expect(resultado.baseGravableAcumulada, 20000);
      // excedente = 20000 - 17533.65 = 2466.35; marginal = 2466.35 * 0.2136 = 526.81236
      // causado = 526.81236 + 1856.84 = 2383.65236
      expect(resultado.isrCausado, closeTo(2383.65, 0.01));
      expect(resultado.isrACargo, closeTo(2383.65, 0.01));
    });

    test('June (factor 6 scaling): base 150,000 lands on scaled bracket 6', () {
      final resultado = IsrEngine.calcularProvisionalMensual(
        ingresosCobradosAcumulados: 150000,
        deduccionesAutorizadasAcumuladas: 0,
        ptuPagada: 0,
        perdidasFiscalesAnteriores: 0,
        tarifaEneroMensual: _tabla2026Mensual(),
        mesActivo: 6,
        pagosProvisionalesAnteriores: 0,
        isrRetenidoAcumulado: 0,
      );

      // Scaled bracket 6: limiteInferior 105201.9, cuotaFija 11141.04, tasa 21.36
      // excedente = 150000 - 105201.9 = 44798.1; marginal = 44798.1 * 0.2136 = 9568.87416
      // causado = 9568.87416 + 11141.04 = 20709.91416
      expect(resultado.isrCausado, closeTo(20709.91, 0.01));
    });

    test('deducts previous provisional payments and withheld ISR', () {
      final resultado = IsrEngine.calcularProvisionalMensual(
        ingresosCobradosAcumulados: 20000,
        deduccionesAutorizadasAcumuladas: 0,
        ptuPagada: 0,
        perdidasFiscalesAnteriores: 0,
        tarifaEneroMensual: _tabla2026Mensual(),
        mesActivo: 1,
        pagosProvisionalesAnteriores: 1000,
        isrRetenidoAcumulado: 200,
      );

      expect(resultado.isrACargo, closeTo(2383.65 - 1000 - 200, 0.01));
    });

    test('zero or negative base gravable yields zero ISR causado', () {
      final resultado = IsrEngine.calcularProvisionalMensual(
        ingresosCobradosAcumulados: 1000,
        deduccionesAutorizadasAcumuladas: 5000,
        ptuPagada: 0,
        perdidasFiscalesAnteriores: 0,
        tarifaEneroMensual: _tabla2026Mensual(),
        mesActivo: 3,
        pagosProvisionalesAnteriores: 0,
        isrRetenidoAcumulado: 0,
      );

      expect(resultado.baseGravableAcumulada, -4000);
      expect(resultado.isrCausado, 0);
      expect(resultado.isrACargo, 0);
    });

    test('rejects mesActivo out of range', () {
      expect(
        () => IsrEngine.calcularProvisionalMensual(
          ingresosCobradosAcumulados: 1000,
          deduccionesAutorizadasAcumuladas: 0,
          ptuPagada: 0,
          perdidasFiscalesAnteriores: 0,
          tarifaEneroMensual: _tabla2026Mensual(),
          mesActivo: 13,
          pagosProvisionalesAnteriores: 0,
          isrRetenidoAcumulado: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
