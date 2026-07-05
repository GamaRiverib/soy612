import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/pdf/papel_trabajo_generator.dart';
import 'package:taxcal_app/features/espejo_sat/espejo_providers.dart';

void main() {
  test('generar produces a non-empty PDF document containing the legal clause', () async {
    final bytes = await PapelTrabajoGenerator.generar(
      nombreContribuyente: 'Juana Pérez',
      rfcContribuyente: 'PEXJ800101ABC',
      periodoLabel: 'Junio 2026',
      isr: const EspejoIsrDatos(
        ingresosAcumulados: 20000,
        deduccionesAcumuladas: 0,
        baseGravableAcumulada: 20000,
        ptuPagada: 0,
        perdidasFiscales: 0,
        pagosProvisionalesAnteriores: 0,
        isrACargo: 1052.99,
      ),
      iva: const EspejoIvaDatos(
        ivaCobrado: 800,
        ivaAcreditable: 0,
        saldoFavorAnterior: 0,
        impuestoNeto: 800,
      ),
      totalAPagar: 1852.99,
      fechaLimiteLabel: '20 de julio de 2026',
    );

    expect(bytes, isNotEmpty);
    // Cabecera estándar de un archivo PDF válido.
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('clausula legal contains the mandatory blocking text (spec 6.4)', () {
    expect(clausulaLegalPapelTrabajo, contains('bitácora contable de uso'));
    expect(clausulaLegalPapelTrabajo, contains('Servicio de Administración Tributaria (SAT)'));
    expect(clausulaLegalPapelTrabajo, contains('estricta responsabilidad personal del contribuyente'));
  });
}
