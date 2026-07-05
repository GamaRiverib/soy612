import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxcal_app/app_providers.dart';
import 'package:taxcal_app/core/fiscal/bancarizacion.dart';
import 'package:taxcal_app/data/db/app_database.dart';
import 'package:taxcal_app/data/db/tables.dart';
import 'package:taxcal_app/features/facturas/xml_import_controller.dart';

void main() {
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('importarFacturasDeEjemplo classifies, alta CRM and flags bancarizacion', () async {
    final controller = container.read(xmlImportControllerProvider.notifier);

    await controller.importarFacturasDeEjemplo();

    final estado = container.read(xmlImportControllerProvider);
    expect(estado.procesando, isFalse);
    expect(estado.archivos, hasLength(3));
    expect(estado.archivos.every((a) => a.estado == EstadoArchivo.listo), isTrue);

    final resumen = estado.resumen!;
    expect(resumen.ingresos, 1);
    expect(resumen.gastos, 2);
    expect(resumen.nuevosContribuyentes, 3); // cliente + 2 proveedores, además del propio
    expect(resumen.errores, 0);

    final ingresos = await db
        .watchFacturasDelMes(anio: 2026, mes: 6, tipo: TipoCfdi.ingreso)
        .first;
    expect(ingresos, hasLength(1));
    expect(ingresos.single.estatusPago, EstatusPago.cobrado);
    expect(ingresos.single.fechaPagoEfectivo, ingresos.single.fechaEmision);

    final egresos = await db
        .watchFacturasDelMes(anio: 2026, mes: 6, tipo: TipoCfdi.egreso)
        .first;
    expect(egresos, hasLength(2));

    final pendiente = egresos.firstWhere((f) => f.metodoPago == MetodoPagoCfdi.ppd);
    expect(pendiente.estatusPago, EstatusPago.pendiente);
    expect(pendiente.fechaPagoEfectivo, isNull);

    final pagadoEfectivo = egresos.firstWhere((f) => f.formaPago == '01');
    expect(pagadoEfectivo.estatusPago, EstatusPago.pagado);
    expect(
      ReglaBancarizacion.violaBancarizacion(
        subtotal: pagadoEfectivo.subtotal,
        formaPago: pagadoEfectivo.formaPago,
      ),
      isTrue,
    );

    final contribuyentes = await db.watchContribuyentes().first;
    // Propio (RFC demo) + cliente + 2 proveedores = 4.
    expect(contribuyentes, hasLength(4));
  });

  test('re-running the demo import does not duplicate invoices', () async {
    final controller = container.read(xmlImportControllerProvider.notifier);

    await controller.importarFacturasDeEjemplo();
    await controller.importarFacturasDeEjemplo();

    final todasIngresos = await db
        .watchFacturasDelMes(anio: 2026, mes: 6, tipo: TipoCfdi.ingreso)
        .first;
    expect(todasIngresos, hasLength(1));

    final segundoResumen = container.read(xmlImportControllerProvider).resumen!;
    // La segunda pasada no debería sumar contribuyentes nuevos (ya existen).
    expect(segundoResumen.nuevosContribuyentes, 0);
  });

  test('rfcPropioConfigurado returns null until a real RFC is saved', () async {
    final controller = container.read(xmlImportControllerProvider.notifier);

    expect(await controller.rfcPropioConfigurado(), isNull);

    await controller.guardarRfcPropio('MIRF800101AB1');

    expect(await controller.rfcPropioConfigurado(), 'MIRF800101AB1');
  });

  test('a CFDI unrelated to the configured RFC is reported as an error', () async {
    final controller = container.read(xmlImportControllerProvider.notifier);
    await controller.guardarRfcPropio('OTRO900101ZZ9');

    const xmlAjeno = '''
<?xml version="1.0" encoding="UTF-8"?>
<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"
    Version="4.0" Folio="X1" Fecha="2026-06-01T00:00:00" SubTotal="100.00" Total="116.00"
    MetodoPago="PUE" FormaPago="03">
  <cfdi:Emisor Rfc="AAAA010101AA1" Nombre="Alguien"/>
  <cfdi:Receptor Rfc="BBBB010101BB1" Nombre="Otro Alguien"/>
  <cfdi:Complemento>
    <tfd:TimbreFiscalDigital UUID="ZZZZZZZZ-0000-0000-0000-000000000009"/>
  </cfdi:Complemento>
</cfdi:Comprobante>
''';

    await controller.importarArchivos(
      [('ajeno.xml', xmlAjeno)],
      rfcPropio: 'OTRO900101ZZ9',
      nombrePropio: 'Yo',
    );

    final estado = container.read(xmlImportControllerProvider);
    expect(estado.archivos.single.estado, EstadoArchivo.error);
    expect(estado.resumen!.errores, 1);
  });
}
