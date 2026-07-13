import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/data/db/app_database.dart';
import 'package:taxcal_app/data/db/tables.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('Contribuyentes', () {
    test('altaContribuyenteSiNoExiste inserts once and ignores duplicates', () async {
      await db.altaContribuyenteSiNoExiste(rfc: 'AAAA010101AAA', razonSocial: 'Cliente Uno');
      await db.altaContribuyenteSiNoExiste(rfc: 'AAAA010101AAA', razonSocial: 'Otro nombre');

      final lista = await db.watchContribuyentes().first;
      expect(lista, hasLength(1));
      expect(lista.single.razonSocial, 'Cliente Uno');
      expect(lista.single.tipoPersona, TipoPersona.fisica);
    });

    test('classifies moral RFC (12 chars) correctly', () async {
      await db.altaContribuyenteSiNoExiste(rfc: 'AAA010101AAA', razonSocial: 'Empresa SA');
      final lista = await db.watchContribuyentes().first;
      expect(lista.single.tipoPersona, TipoPersona.moral);
    });
  });

  group('Facturas', () {
    Future<void> seedContribuyentes() async {
      await db.altaContribuyenteSiNoExiste(rfc: 'EMIS010101AAA', razonSocial: 'Emisor SA');
      await db.altaContribuyenteSiNoExiste(rfc: 'RECE010101AAA', razonSocial: 'Receptor SA');
    }

    test('insertarFacturaSiNoExiste rejects duplicate UUIDs', () async {
      await seedContribuyentes();
      final companion = FacturasCompanion.insert(
        uuid: 'uuid-1',
        fechaEmision: DateTime(2026, 6, 15),
        fechaPagoEfectivo: const Value.absent(),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.ingreso,
        subtotal: 1000,
        total: 1160,
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.cobrado,
      );

      final primera = await db.insertarFacturaSiNoExiste(companion);
      final segunda = await db.insertarFacturaSiNoExiste(companion);

      expect(primera, isTrue);
      expect(segunda, isFalse);

      final todas = await db.watchFacturasDelMes(anio: 2026, mes: 6, tipo: TipoCfdi.ingreso).first;
      expect(todas, hasLength(1));
    });

    test('watchFacturasDelMes filters by month boundaries', () async {
      await seedContribuyentes();
      Future<void> insertar(String uuid, DateTime fecha) => db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: uuid,
          fechaEmision: fecha,
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 100,
          total: 116,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.cobrado,
        ),
      );

      await insertar('uuid-may-31', DateTime(2026, 5, 31));
      await insertar('uuid-jun-01', DateTime(2026, 6, 1));
      await insertar('uuid-jun-30', DateTime(2026, 6, 30));
      await insertar('uuid-jul-01', DateTime(2026, 7, 1));

      final junio = await db.watchFacturasDelMes(anio: 2026, mes: 6, tipo: TipoCfdi.ingreso).first;
      expect(junio.map((f) => f.uuid), unorderedEquals(['uuid-jun-01', 'uuid-jun-30']));
    });

    test('conciliarPagoPpd sets fecha and estatus per tipoCfdi', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'ppd-1',
          fechaEmision: DateTime(2026, 6, 1),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.egreso,
          subtotal: 500,
          total: 580,
          metodoPago: MetodoPagoCfdi.ppd,
          formaPago: '03',
          estatusPago: EstatusPago.pendiente,
        ),
      );

      var pendientes = await db.watchFacturasPendientesPpd().first;
      expect(pendientes, hasLength(1));

      await db.conciliarPagoPpd(
        uuid: 'ppd-1',
        fechaPagoEfectivo: DateTime(2026, 6, 20),
        tipoCfdi: TipoCfdi.egreso,
      );

      pendientes = await db.watchFacturasPendientesPpd().first;
      expect(pendientes, isEmpty);

      final gastos = await db.watchGastosDeduciblesDelMes(anio: 2026, mes: 6).first;
      expect(gastos, 500);
    });

    test('watchIngresosPendientesPpdConContraparte joins counterparty name', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'ppd-ingreso-1',
          fechaEmision: DateTime(2026, 6, 1),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 1000,
          total: 1160,
          metodoPago: MetodoPagoCfdi.ppd,
          formaPago: '03',
          estatusPago: EstatusPago.pendiente,
        ),
      );

      final pendientes = await db.watchIngresosPendientesPpdConContraparte().first;
      expect(pendientes, hasLength(1));
      expect(pendientes.single.contraparteRazonSocial, 'Receptor SA');

      final egresosPendientes = await db.watchEgresosPendientesPpdConContraparte().first;
      expect(egresosPendientes, isEmpty);
    });

    test('actualizarDeducible excludes non-deductible expenses from KPI sum', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'gasto-1',
          fechaEmision: DateTime(2026, 6, 1),
          fechaPagoEfectivo: Value(DateTime(2026, 6, 1)),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.egreso,
          subtotal: 300,
          total: 348,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.pagado,
        ),
      );

      expect(await db.watchGastosDeduciblesDelMes(anio: 2026, mes: 6).first, 300);

      await db.actualizarDeducible(uuid: 'gasto-1', esDeducible: false);

      expect(await db.watchGastosDeduciblesDelMes(anio: 2026, mes: 6).first, 0);
    });

    test('watchFacturasDelMesConContraparte joins the counterparty name', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'con-contraparte-1',
          fechaEmision: DateTime(2026, 6, 5),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 100,
          total: 116,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.cobrado,
        ),
      );

      final ingresos = await db
          .watchFacturasDelMesConContraparte(anio: 2026, mes: 6, tipo: TipoCfdi.ingreso)
          .first;
      expect(ingresos, hasLength(1));
      expect(ingresos.single.contraparteRazonSocial, 'Receptor SA');
      expect(ingresos.single.contraparteRfc, 'RECE010101AAA');

      final egresos = await db
          .watchFacturasDelMesConContraparte(anio: 2026, mes: 6, tipo: TipoCfdi.egreso)
          .first;
      expect(egresos, isEmpty);
    });

    test('watchFacturasBuscados finds invoices by counterparty razon social', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'busq-1',
          fechaEmision: DateTime(2026, 6, 1),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 100,
          total: 116,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.cobrado,
        ),
      );

      final resultado = await db
          .watchFacturasBuscadas(tipo: TipoCfdi.ingreso, query: 'Receptor')
          .first;
      expect(resultado, hasLength(1));
      expect(resultado.single.uuid, 'busq-1');

      final vacio = await db
          .watchFacturasBuscadas(tipo: TipoCfdi.ingreso, query: 'NoExiste')
          .first;
      expect(vacio, isEmpty);
    });
  });

  group('Agregaciones fiscales', () {
    Future<void> seedContribuyentes() async {
      await db.altaContribuyenteSiNoExiste(rfc: 'EMIS010101AAA', razonSocial: 'Emisor SA');
      await db.altaContribuyenteSiNoExiste(rfc: 'RECE010101AAA', razonSocial: 'Receptor SA');
    }

    test('accumulates income/expenses year-to-date across prior months', () async {
      await seedContribuyentes();
      Future<void> insertarIngreso(String uuid, DateTime fecha, double subtotal) =>
          db.insertarFacturaSiNoExiste(
            FacturasCompanion.insert(
              uuid: uuid,
              fechaEmision: fecha,
              fechaPagoEfectivo: Value(fecha),
              rfcEmisor: 'EMIS010101AAA',
              rfcReceptor: 'RECE010101AAA',
              tipoCfdi: TipoCfdi.ingreso,
              subtotal: subtotal,
              total: subtotal * 1.16,
              metodoPago: MetodoPagoCfdi.pue,
              formaPago: '03',
              estatusPago: EstatusPago.cobrado,
              isrRetenido: const Value(10.0),
            ),
          );

      await insertarIngreso('ene', DateTime(2026, 1, 15), 1000);
      await insertarIngreso('mar', DateTime(2026, 3, 15), 2000);
      await insertarIngreso('jun', DateTime(2026, 6, 15), 3000);
      await insertarIngreso('jul', DateTime(2026, 7, 15), 4000); // fuera de rango

      final acumuladoAJunio =
          await db.watchIngresosCobradosAcumulados(anio: 2026, hastaMes: 6).first;
      expect(acumuladoAJunio, 6000); // ene+mar+jun, no jul

      final isrRetenidoAcumulado =
          await db.watchIsrRetenidoAcumulado(anio: 2026, hastaMes: 6).first;
      expect(isrRetenidoAcumulado, 30); // 10 por cada una de las 3 facturas
    });

    test('computes monthly IVA cobrado/acreditable/retenido at 16%', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'ingreso-iva',
          fechaEmision: DateTime(2026, 6, 10),
          fechaPagoEfectivo: Value(DateTime(2026, 6, 10)),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 1000,
          total: 1160,
          tasaIva: const Value(16.0),
          ivaTrasladado: const Value(160.0),
          ivaRetenido: const Value(20.0),
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.cobrado,
        ),
      );
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'egreso-iva',
          fechaEmision: DateTime(2026, 6, 12),
          fechaPagoEfectivo: Value(DateTime(2026, 6, 12)),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.egreso,
          subtotal: 500,
          total: 580,
          tasaIva: const Value(16.0),
          ivaTrasladado: const Value(80.0),
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.pagado,
        ),
      );

      expect(await db.watchIvaCobradoDelMes(anio: 2026, mes: 6).first, 160);
      expect(await db.watchIvaAcreditableDelMes(anio: 2026, mes: 6).first, 80);
      expect(await db.watchIvaRetenidoDelMes(anio: 2026, mes: 6).first, 20);
    });

    test('KPI counters reflect only invoices within the month', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'contador-jun',
          fechaEmision: DateTime(2026, 6, 1),
          fechaPagoEfectivo: Value(DateTime(2026, 6, 1)),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 100,
          total: 116,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.cobrado,
        ),
      );

      expect(await db.watchContadorIngresosCobradosDelMes(anio: 2026, mes: 6).first, 1);
      expect(await db.watchContadorIngresosCobradosDelMes(anio: 2026, mes: 7).first, 0);
    });
  });

  group('Mantenimiento', () {
    test('borrarTodosLosDatos empties every collection', () async {
      await db.altaContribuyenteSiNoExiste(rfc: 'EMIS010101AAA', razonSocial: 'Emisor SA');
      await db.altaContribuyenteSiNoExiste(rfc: 'RECE010101AAA', razonSocial: 'Receptor SA');
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'a-borrar',
          fechaEmision: DateTime(2026, 6, 1),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 100,
          total: 116,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.cobrado,
        ),
      );

      await db.borrarTodosLosDatos();

      expect(await db.watchContribuyentes().first, isEmpty);
      expect(await db.watchFacturasPendientesPpd().first, isEmpty);
    });
  });

  group('Capturas Espejo SAT', () {
    test('watchCapturaEspejo returns null when nothing has been captured', () async {
      final captura = await db.watchCapturaEspejo(anio: 2026, mes: 6).first;
      expect(captura, isNull);
    });

    test('guardarCapturaEspejo creates a row with defaults for unset fields', () async {
      await db.guardarCapturaEspejo(anio: 2026, mes: 6, ptuPagada: 500);

      final captura = await db.watchCapturaEspejo(anio: 2026, mes: 6).first;
      expect(captura!.ptuPagada, 500);
      expect(captura.perdidasFiscales, 0);
      expect(captura.pagosProvisionalesAnteriores, 0);
      expect(captura.saldoFavorIvaAnterior, 0);
      expect(captura.tipoDeclaracion, TipoDeclaracion.normal);
      expect(captura.copropiedad, isFalse);
    });

    test('guardarCapturaEspejo only updates the fields passed, leaving the rest untouched', () async {
      await db.guardarCapturaEspejo(anio: 2026, mes: 6, ptuPagada: 500, perdidasFiscales: 200);

      await db.guardarCapturaEspejo(anio: 2026, mes: 6, perdidasFiscales: 999);

      final captura = await db.watchCapturaEspejo(anio: 2026, mes: 6).first;
      expect(captura!.ptuPagada, 500, reason: 'ptuPagada should be untouched by the second call');
      expect(captura.perdidasFiscales, 999);
    });

    test('captures are independent per (anio, mes)', () async {
      await db.guardarCapturaEspejo(anio: 2026, mes: 6, ptuPagada: 100);
      await db.guardarCapturaEspejo(anio: 2026, mes: 7, ptuPagada: 200);

      expect((await db.watchCapturaEspejo(anio: 2026, mes: 6).first)!.ptuPagada, 100);
      expect((await db.watchCapturaEspejo(anio: 2026, mes: 7).first)!.ptuPagada, 200);
    });

    test('guardarCapturaEspejo persists tipoDeclaracion and copropiedad', () async {
      await db.guardarCapturaEspejo(
        anio: 2026,
        mes: 6,
        tipoDeclaracion: TipoDeclaracion.complementaria,
        copropiedad: true,
      );

      final captura = await db.watchCapturaEspejo(anio: 2026, mes: 6).first;
      expect(captura!.tipoDeclaracion, TipoDeclaracion.complementaria);
      expect(captura.copropiedad, isTrue);
    });

    test('borrarTodosLosDatos clears captured periods too', () async {
      await db.guardarCapturaEspejo(anio: 2026, mes: 6, ptuPagada: 500);
      await db.borrarTodosLosDatos();
      expect(await db.watchCapturaEspejo(anio: 2026, mes: 6).first, isNull);
    });

    test('guardarCapturaSatCampo persists flexible SAT field values', () async {
      await db.guardarCapturaSatCampo(
        anio: 2026,
        mes: 6,
        campoId: 'iva_otras_cantidades_cargo',
        valor: 123,
      );
      await db.guardarCapturaSatCampo(
        anio: 2026,
        mes: 6,
        campoId: 'iva_proporcion_opcion',
        opcion: 'Art. 5 de la LIVA',
      );

      final capturas = await db.watchCapturasSatCampos(anio: 2026, mes: 6).first;

      expect(capturas.map((c) => c.campoId), contains('iva_otras_cantidades_cargo'));
      expect(
        capturas.singleWhere((c) => c.campoId == 'iva_otras_cantidades_cargo').valor,
        123,
      );
      expect(
        capturas.singleWhere((c) => c.campoId == 'iva_proporcion_opcion').opcion,
        'Art. 5 de la LIVA',
      );
    });

    test('sumarCapturasSatCampoAntesDeMes accumulates only previous months', () async {
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

      final acumuladoJunio = await db.sumarCapturasSatCampoAntesDeMes(
        anio: 2026,
        mes: 6,
        campoId: 'isr_pago_realizado',
      );

      expect(acumuladoJunio, 3708);
    });
  });

  group('watchFacturasParaDetalle', () {
    Future<void> seedContribuyentes() async {
      await db.altaContribuyenteSiNoExiste(rfc: 'EMIS010101AAA', razonSocial: 'Emisor SA');
      await db.altaContribuyenteSiNoExiste(rfc: 'RECE010101AAA', razonSocial: 'Receptor SA');
    }

    test('acumula ingresos cobrados de enero al mes activo (rango ISR)', () async {
      await seedContribuyentes();
      Future<void> insertar(String uuid, DateTime fechaPago) => db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: uuid,
          fechaEmision: fechaPago,
          fechaPagoEfectivo: Value(fechaPago),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.ingreso,
          subtotal: 100,
          total: 116,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.cobrado,
        ),
      );

      await insertar('ene', DateTime(2026, 1, 15));
      await insertar('jun', DateTime(2026, 6, 10));
      await insertar('jul', DateTime(2026, 7, 1));

      final ytd = await db
          .watchFacturasParaDetalle(
            tipo: TipoCfdi.ingreso,
            inicio: DateTime(2026),
            finExclusivo: DateTime(2026, 7),
          )
          .first;

      expect(ytd.map((f) => f.factura.uuid), unorderedEquals(['ene', 'jun']));
    });

    test('excluye egresos no deducibles', () async {
      await seedContribuyentes();
      await db.insertarFacturaSiNoExiste(
        FacturasCompanion.insert(
          uuid: 'gasto-no-ded',
          fechaEmision: DateTime(2026, 6, 5),
          fechaPagoEfectivo: Value(DateTime(2026, 6, 5)),
          rfcEmisor: 'EMIS010101AAA',
          rfcReceptor: 'RECE010101AAA',
          tipoCfdi: TipoCfdi.egreso,
          subtotal: 100,
          total: 116,
          metodoPago: MetodoPagoCfdi.pue,
          formaPago: '03',
          estatusPago: EstatusPago.pagado,
          esDeducible: const Value(false),
        ),
      );

      final resultado = await db
          .watchFacturasParaDetalle(
            tipo: TipoCfdi.egreso,
            inicio: DateTime(2026, 6),
            finExclusivo: DateTime(2026, 7),
          )
          .first;

      expect(resultado, isEmpty);
    });
  });

  group('Deducciones personales', () {
    test('agregarDeduccionPersonal inserts and watchDeduccionesPersonales lists by ejercicio', () async {
      await db.agregarDeduccionPersonal(
        ejercicioFiscal: 2026,
        concepto: 'Consulta dental',
        monto: 800,
        formaPago: FormaPagoPersonal.tarjeta,
        esFunerario: false,
      );
      await db.agregarDeduccionPersonal(
        ejercicioFiscal: 2025,
        concepto: 'Del año pasado',
        monto: 500,
        formaPago: FormaPagoPersonal.tarjeta,
        esFunerario: false,
      );

      final deducciones2026 = await db.watchDeduccionesPersonales(2026).first;
      expect(deducciones2026, hasLength(1));
      expect(deducciones2026.single.concepto, 'Consulta dental');
      expect(deducciones2026.single.monto, 800);
      expect(deducciones2026.single.formaPago, FormaPagoPersonal.tarjeta);
    });

    test('eliminarDeduccionPersonal removes the row', () async {
      await db.agregarDeduccionPersonal(
        ejercicioFiscal: 2026,
        concepto: 'Seguro de gastos médicos',
        monto: 5000,
        formaPago: FormaPagoPersonal.tarjeta,
        esFunerario: false,
      );
      final antes = await db.watchDeduccionesPersonales(2026).first;

      await db.eliminarDeduccionPersonal(antes.single.id);

      expect(await db.watchDeduccionesPersonales(2026).first, isEmpty);
    });

    test('borrarTodosLosDatos clears personal deductions too', () async {
      await db.agregarDeduccionPersonal(
        ejercicioFiscal: 2026,
        concepto: 'Colegiatura',
        monto: 3000,
        formaPago: FormaPagoPersonal.tarjeta,
        esFunerario: false,
      );

      await db.borrarTodosLosDatos();

      expect(await db.watchDeduccionesPersonales(2026).first, isEmpty);
    });
  });
}
