import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxcal_app/app_providers.dart';
import 'package:taxcal_app/data/db/app_database.dart';
import 'package:taxcal_app/data/db/tables.dart';
import 'package:taxcal_app/features/espejo_sat/capturas_espejo_controller.dart';
import 'package:taxcal_app/features/espejo_sat/espejo_providers.dart';

Future<void> _seedContribuyentes(AppDatabase db) async {
  await db.altaContribuyenteSiNoExiste(rfc: 'EMIS010101AAA', razonSocial: 'Emisor SA');
  await db.altaContribuyenteSiNoExiste(rfc: 'RECE010101AAA', razonSocial: 'Receptor SA');
}

/// `.autoDispose` providers get disposed as soon as nothing is listening,
/// which can happen mid-flight for a chain of combined async providers when
/// the only access is a bare `container.read(provider.future)`. Keeping a
/// no-op listener alive for the duration of the read avoids that race.
Future<T> _readKeptAlive<T>(ProviderContainer container, FutureProvider<T> provider) {
  final subscription = container.listen(provider, (_, _) {});
  return container.read(provider.future).whenComplete(subscription.close);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'ejercicio_anio_activo': 2026,
      'ejercicio_mes_activo': 6,
    });
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    await _seedContribuyentes(db);
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('espejoIsrDatosProvider uses 0 defaults when nothing was captured', () async {
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'ing-1',
        fechaEmision: DateTime(2026, 6, 10),
        fechaPagoEfectivo: Value(DateTime(2026, 6, 10)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.ingreso,
        subtotal: 20000,
        total: 23200,
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.cobrado,
      ),
    );

    final datos = await _readKeptAlive(container, espejoIsrDatosProvider);

    expect(datos.ingresosAcumulados, 20000);
    expect(datos.deduccionesAcumuladas, 0);
    expect(datos.baseGravableAcumulada, 20000);
    expect(datos.ptuPagada, 0);
    expect(datos.perdidasFiscales, 0);
    expect(datos.pagosProvisionalesAnteriores, 0);
    // mes activo = 6 (junio): tarifa escalada x6, bracket 2 (5067.60-43011.06)
    // excedente = 20000 - 5067.60 = 14932.40; marginal = 14932.40*6.4% = 955.6736
    // causado = 955.6736 + 97.32 (16.22*6) = 1052.9936
    expect(datos.isrACargo, closeTo(1052.9936, 0.01));
  });

  test('espejoIsrDatosProvider reflects captured PTU/pérdidas/pagos anteriores', () async {
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'ing-2',
        fechaEmision: DateTime(2026, 6, 10),
        fechaPagoEfectivo: Value(DateTime(2026, 6, 10)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.ingreso,
        subtotal: 20000,
        total: 23200,
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.cobrado,
      ),
    );

    await container
        .read(capturasEspejoControllerProvider.notifier)
        .guardarPagosProvisionalesAnteriores(1000);

    final datos = await _readKeptAlive(container, espejoIsrDatosProvider);

    expect(datos.pagosProvisionalesAnteriores, 1000);
    expect(datos.isrACargo, closeTo(1052.9936 - 1000, 0.01));
  });

  test('espejoIvaDatosProvider nets cobrado, acreditable and saldo a favor anterior', () async {
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'ing-iva',
        fechaEmision: DateTime(2026, 6, 10),
        fechaPagoEfectivo: Value(DateTime(2026, 6, 10)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.ingreso,
        subtotal: 1000,
        total: 1160,
        tasaIva: const Value(16.0),
        ivaTrasladado: const Value(160.0),
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.cobrado,
      ),
    );

    await container.read(capturasEspejoControllerProvider.notifier).guardarSaldoFavorIvaAnterior(50);

    final datos = await _readKeptAlive(container, espejoIvaDatosProvider);

    expect(datos.ivaCobrado, 160);
    expect(datos.ivaAcreditable, 0);
    expect(datos.saldoFavorAnterior, 50);
    expect(datos.impuestoNeto, 110); // 160 - 0 - 50
    expect(datos.esACargo, isTrue);
  });

  test('espejoSatGuiadoProvider builds SAT sections with monthly and prior values', () async {
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'ing-previous',
        fechaEmision: DateTime(2026, 5, 10),
        fechaPagoEfectivo: Value(DateTime(2026, 5, 10)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.ingreso,
        subtotal: 900,
        total: 1044,
        tasaIva: const Value(16.0),
        ivaTrasladado: const Value(144.0),
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.cobrado,
      ),
    );
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'ing-current',
        fechaEmision: DateTime(2026, 6, 10),
        fechaPagoEfectivo: Value(DateTime(2026, 6, 10)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.ingreso,
        subtotal: 1000,
        total: 1160,
        tasaIva: const Value(16.0),
        ivaTrasladado: const Value(160.0),
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.cobrado,
      ),
    );
    await db.guardarCapturaSatCampo(
      anio: 2026,
      mes: 6,
      campoId: 'isr_ingresos_adicionales',
      valor: 25,
    );

    final datos = await _readKeptAlive(container, espejoSatGuiadoProvider);
    final ingresos = datos.secciones.singleWhere((s) => s.id == 'isr_ingresos');
    final adicional = ingresos.campos.singleWhere((c) => c.id == 'isr_ingresos_adicionales');
    final anteriores = ingresos.campos.singleWhere((c) => c.id == 'isr_ingresos_anteriores');
    final total = ingresos.campos.singleWhere((c) => c.id == 'isr_total_ingresos_periodo');

    expect(datos.secciones.map((s) => s.id), containsAll(['isr_ingresos', 'iva_acreditable']));
    expect(adicional.tipo, CampoSatTipo.ceroSugerido);
    expect(adicional.valor, 25);
    expect(anteriores.valor, 900);
    expect(total.valor, 1925);
  });

  test('espejoSatGuiadoProvider preloads previous provisional payments from prior months', () async {
    await db.guardarCapturaSatCampo(
      anio: 2026,
      mes: 4,
      campoId: 'isr_pago_realizado',
      valor: 1000,
    );
    await db.guardarCapturaSatCampo(
      anio: 2026,
      mes: 5,
      campoId: 'isr_pago_realizado',
      valor: 2708,
    );
    await db.guardarCapturaSatCampo(
      anio: 2026,
      mes: 6,
      campoId: 'isr_pago_realizado',
      valor: 500,
    );

    final datos = await _readKeptAlive(container, espejoSatGuiadoProvider);
    final determinacion = datos.secciones.singleWhere((s) => s.id == 'isr_determinacion');
    final pagos = determinacion.campos.singleWhere(
      (c) => c.id == 'isr_pagos_provisionales_anteriores',
    );
    final pagoPeriodo = datos.secciones
        .singleWhere((s) => s.id == 'isr_pago')
        .campos
        .singleWhere((c) => c.id == 'isr_pago_realizado');

    expect(pagos.valor, 3708);
    expect(pagoPeriodo.valor, 500);
  });

  test('espejoSatGuiadoProvider reuses previous SAT provisional payment captures', () async {
    await db.guardarCapturaSatCampo(
      anio: 2026,
      mes: 5,
      campoId: 'isr_pagos_provisionales_anteriores',
      valor: 3708,
    );

    final datos = await _readKeptAlive(container, espejoSatGuiadoProvider);
    final determinacion = datos.secciones.singleWhere((s) => s.id == 'isr_determinacion');
    final pagos = determinacion.campos.singleWhere(
      (c) => c.id == 'isr_pagos_provisionales_anteriores',
    );

    expect(pagos.valor, 3708);
  });
}
