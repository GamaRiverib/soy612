import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'factura_con_contraparte.dart';
import 'factura_pendiente_ppd.dart';
import 'tables.dart';

export 'factura_con_contraparte.dart';
export 'factura_pendiente_ppd.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Contribuyentes, Facturas, Inversiones, CapturasEspejo])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'taxcal'));

  /// Usado en tests para inyectar un [QueryExecutor] en memoria.
  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(capturasEspejo);
      }
    },
  );

  // ---------------------------------------------------------------------
  // Contribuyentes (CRM offline)
  // ---------------------------------------------------------------------

  /// Alta automática si el RFC no existe todavía (pipeline de importación XML,
  /// sección 4.2 de la especificación funcional). No sobreescribe la razón
  /// social de un contribuyente ya existente.
  Future<void> altaContribuyenteSiNoExiste({
    required String rfc,
    required String razonSocial,
  }) async {
    final tipo = rfc.length == 13 ? TipoPersona.fisica : TipoPersona.moral;
    await into(contribuyentes).insert(
      ContribuyentesCompanion.insert(
        rfc: rfc,
        razonSocial: razonSocial,
        tipoPersona: tipo,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Stream<List<Contribuyente>> watchContribuyentes() =>
      (select(contribuyentes)..orderBy([(t) => OrderingTerm(expression: t.razonSocial)]))
          .watch();

  Stream<List<Contribuyente>> watchContribuyentesBuscados(String query) {
    final like = '%$query%';
    return (select(contribuyentes)
          ..where((t) => t.razonSocial.like(like) | t.rfc.like(like))
          ..orderBy([(t) => OrderingTerm(expression: t.razonSocial)]))
        .watch();
  }

  // ---------------------------------------------------------------------
  // Facturas
  // ---------------------------------------------------------------------

  /// Inserción idempotente por UUID (protección de duplicados, sección 6 de
  /// la especificación técnica): si el UUID ya existe, la inserción se ignora.
  ///
  /// Nota: no se usa el rowid devuelto por `insert()` para detectar el
  /// conflicto porque, al ser `uuid` una clave primaria de texto, SQLite deja
  /// `last_insert_rowid()` con el valor de la última inserción exitosa previa
  /// en vez de 0 cuando la fila se ignora.
  Future<bool> insertarFacturaSiNoExiste(FacturasCompanion factura) async {
    final uuid = factura.uuid.value;
    final existente = await (select(facturas)..where((f) => f.uuid.equals(uuid))).getSingleOrNull();
    if (existente != null) return false;

    await into(facturas).insert(factura, mode: InsertMode.insertOrIgnore);
    return true;
  }

  Stream<List<Factura>> watchFacturasDelMes({
    required int anio,
    required int mes,
    required TipoCfdi tipo,
  }) {
    final inicio = DateTime(anio, mes, 1);
    final finExclusivo = DateTime(anio, mes + 1, 1);
    return (select(facturas)
          ..where((f) =>
              f.tipoCfdi.equalsValue(tipo) &
              f.fechaEmision.isBiggerOrEqualValue(inicio) &
              f.fechaEmision.isSmallerThanValue(finExclusivo))
          ..orderBy([(f) => OrderingTerm.desc(f.fechaEmision)]))
        .watch();
  }

  /// Como [watchFacturasDelMes], pero incluye el nombre de la contraparte
  /// (receptor si es ingreso, emisor si es egreso) para las tarjetas de la
  /// pantalla Facturas.
  Stream<List<FacturaConContraparte>> watchFacturasDelMesConContraparte({
    required int anio,
    required int mes,
    required TipoCfdi tipo,
  }) {
    final inicio = DateTime(anio, mes, 1);
    final finExclusivo = DateTime(anio, mes + 1, 1);
    return (select(facturas).join([
          innerJoin(contribuyentes, contribuyentes.rfc.equalsExp(_contraparteRfc(tipo))),
        ])
          ..where(facturas.tipoCfdi.equalsValue(tipo))
          ..where(facturas.fechaEmision.isBiggerOrEqualValue(inicio))
          ..where(facturas.fechaEmision.isSmallerThanValue(finExclusivo))
          ..orderBy([OrderingTerm.desc(facturas.fechaEmision)]))
        .map(
          (row) => FacturaConContraparte(
            factura: row.readTable(facturas),
            contraparteRazonSocial: row.readTable(contribuyentes).razonSocial,
          ),
        )
        .watch();
  }

  /// Facturas que integran una suma del Espejo SAT (README, sección "4.
  /// Espejo SAT": botones "Detalle"). A diferencia de [watchFacturasDelMes],
  /// filtra por [fechaPagoEfectivo] (no por fecha de emisión) dentro de un
  /// rango arbitrario — acumulado del año para ISR, o solo el mes para IVA —
  /// y solo incluye las facturas que ya cuentan para el cálculo (cobradas,
  /// o pagadas y deducibles).
  Stream<List<FacturaConContraparte>> watchFacturasParaDetalle({
    required TipoCfdi tipo,
    required DateTime inicio,
    required DateTime finExclusivo,
  }) {
    final estatusEfectivo = tipo == TipoCfdi.ingreso ? EstatusPago.cobrado : EstatusPago.pagado;
    final query = select(facturas).join([
      innerJoin(contribuyentes, contribuyentes.rfc.equalsExp(_contraparteRfc(tipo))),
    ])
      ..where(facturas.tipoCfdi.equalsValue(tipo))
      ..where(facturas.estatusPago.equalsValue(estatusEfectivo))
      ..where(facturas.fechaPagoEfectivo.isBiggerOrEqualValue(inicio))
      ..where(facturas.fechaPagoEfectivo.isSmallerThanValue(finExclusivo))
      ..orderBy([OrderingTerm.desc(facturas.fechaPagoEfectivo)]);
    if (tipo == TipoCfdi.egreso) {
      query.where(facturas.esDeducible.equals(true));
    }
    return query
        .map(
          (row) => FacturaConContraparte(
            factura: row.readTable(facturas),
            contraparteRazonSocial: row.readTable(contribuyentes).razonSocial,
          ),
        )
        .watch();
  }

  Stream<List<Factura>> watchFacturasBuscadas({
    required TipoCfdi tipo,
    required String query,
  }) {
    final like = '%$query%';
    return (select(facturas).join([
      innerJoin(contribuyentes, contribuyentes.rfc.equalsExp(_contraparteRfc(tipo))),
    ])
          ..where(facturas.tipoCfdi.equalsValue(tipo))
          ..where(
            facturas.rfcEmisor.like(like) |
                facturas.rfcReceptor.like(like) |
                facturas.folioInterno.like(like) |
                facturas.uuid.like(like) |
                contribuyentes.razonSocial.like(like),
          )
          ..orderBy([OrderingTerm.desc(facturas.fechaEmision)]))
        .map((row) => row.readTable(facturas))
        .watch();
  }

  Expression<String> _contraparteRfc(TipoCfdi tipo) =>
      tipo == TipoCfdi.ingreso ? facturas.rfcReceptor : facturas.rfcEmisor;

  Stream<List<Factura>> watchFacturasPendientesPpd() => (select(facturas)
        ..where((f) => f.estatusPago.equalsValue(EstatusPago.pendiente))
        ..orderBy([(f) => OrderingTerm.asc(f.fechaEmision)]))
      .watch();

  /// Facturas de ingreso PPD pendientes, con el nombre de la contraparte
  /// (receptor) para el bottom sheet de recordatorios (README, sección
  /// "Recordatorios de conciliación PPD").
  Stream<List<FacturaPendientePpd>> watchIngresosPendientesPpdConContraparte() =>
      (select(facturas).join([
            innerJoin(contribuyentes, contribuyentes.rfc.equalsExp(facturas.rfcReceptor)),
          ])
            ..where(facturas.tipoCfdi.equalsValue(TipoCfdi.ingreso))
            ..where(facturas.estatusPago.equalsValue(EstatusPago.pendiente))
            ..orderBy([OrderingTerm.asc(facturas.fechaEmision)]))
          .map(
            (row) => FacturaPendientePpd(
              factura: row.readTable(facturas),
              contraparteRazonSocial: row.readTable(contribuyentes).razonSocial,
            ),
          )
          .watch();

  /// Facturas de egreso PPD pendientes, con el nombre de la contraparte (emisor).
  Stream<List<FacturaPendientePpd>> watchEgresosPendientesPpdConContraparte() =>
      (select(facturas).join([
            innerJoin(contribuyentes, contribuyentes.rfc.equalsExp(facturas.rfcEmisor)),
          ])
            ..where(facturas.tipoCfdi.equalsValue(TipoCfdi.egreso))
            ..where(facturas.estatusPago.equalsValue(EstatusPago.pendiente))
            ..orderBy([OrderingTerm.asc(facturas.fechaEmision)]))
          .map(
            (row) => FacturaPendientePpd(
              factura: row.readTable(facturas),
              contraparteRazonSocial: row.readTable(contribuyentes).razonSocial,
            ),
          )
          .watch();

  Future<void> actualizarDeducible({required String uuid, required bool esDeducible}) =>
      (update(facturas)..where((f) => f.uuid.equals(uuid)))
          .write(FacturasCompanion(esDeducible: Value(esDeducible)));

  /// Conciliación PPD (sección 2.2 de la especificación funcional): asigna la
  /// fecha de pago efectivo y el estatus resultante según el tipo de CFDI.
  Future<void> conciliarPagoPpd({
    required String uuid,
    required DateTime fechaPagoEfectivo,
    required TipoCfdi tipoCfdi,
  }) {
    final estatus = tipoCfdi == TipoCfdi.ingreso ? EstatusPago.cobrado : EstatusPago.pagado;
    return (update(facturas)..where((f) => f.uuid.equals(uuid))).write(
      FacturasCompanion(
        fechaPagoEfectivo: Value(fechaPagoEfectivo),
        estatusPago: Value(estatus),
      ),
    );
  }

  /// Suma de subtotales de ingresos cobrados del mes (KPI del Tablero).
  Stream<double> watchIngresosCobradosDelMes({required int anio, required int mes}) =>
      _watchSuma(
        columna: facturas.subtotal,
        tipo: TipoCfdi.ingreso,
        inicio: DateTime(anio, mes, 1),
        finExclusivo: DateTime(anio, mes + 1, 1),
      );

  /// Suma de subtotales de gastos deducibles y pagados del mes (KPI del Tablero).
  Stream<double> watchGastosDeduciblesDelMes({required int anio, required int mes}) =>
      _watchSuma(
        columna: facturas.subtotal,
        tipo: TipoCfdi.egreso,
        inicio: DateTime(anio, mes, 1),
        finExclusivo: DateTime(anio, mes + 1, 1),
        soloDeducibles: true,
      );

  /// Contador de comprobantes que integran el KPI de ingresos del mes.
  Stream<int> watchContadorIngresosCobradosDelMes({required int anio, required int mes}) =>
      _watchContador(
        tipo: TipoCfdi.ingreso,
        inicio: DateTime(anio, mes, 1),
        finExclusivo: DateTime(anio, mes + 1, 1),
      );

  /// Contador de comprobantes que integran el KPI de gastos deducibles del mes.
  Stream<int> watchContadorGastosDeduciblesDelMes({required int anio, required int mes}) =>
      _watchContador(
        tipo: TipoCfdi.egreso,
        inicio: DateTime(anio, mes, 1),
        finExclusivo: DateTime(anio, mes + 1, 1),
        soloDeducibles: true,
      );

  /// Ingresos cobrados acumulados desde enero hasta [hastaMes] (inclusive) del
  /// ejercicio — base para el ISR provisional acumulado (sección 5.1).
  Stream<double> watchIngresosCobradosAcumulados({required int anio, required int hastaMes}) =>
      _watchSuma(
        columna: facturas.subtotal,
        tipo: TipoCfdi.ingreso,
        inicio: DateTime(anio, 1, 1),
        finExclusivo: DateTime(anio, hastaMes + 1, 1),
      );

  /// Deducciones autorizadas acumuladas desde enero hasta [hastaMes] (inclusive).
  Stream<double> watchDeduccionesAutorizadasAcumuladas({
    required int anio,
    required int hastaMes,
  }) => _watchSuma(
    columna: facturas.subtotal,
    tipo: TipoCfdi.egreso,
    inicio: DateTime(anio, 1, 1),
    finExclusivo: DateTime(anio, hastaMes + 1, 1),
    soloDeducibles: true,
  );

  /// ISR retenido acumulado (de las retenciones que traen los CFDI de
  /// ingreso cobrados, ej. servicios profesionales a personas morales).
  Stream<double> watchIsrRetenidoAcumulado({required int anio, required int hastaMes}) =>
      _watchSuma(
        columna: facturas.isrRetenido,
        tipo: TipoCfdi.ingreso,
        inicio: DateTime(anio, 1, 1),
        finExclusivo: DateTime(anio, hastaMes + 1, 1),
      );

  /// IVA cobrado del mes (tasa 16%, definitivo y no acumulativo — sección 5.2).
  Stream<double> watchIvaCobradoDelMes({required int anio, required int mes}) => _watchSuma(
    columna: facturas.ivaTrasladado,
    tipo: TipoCfdi.ingreso,
    inicio: DateTime(anio, mes, 1),
    finExclusivo: DateTime(anio, mes + 1, 1),
    tasaIva: 16.0,
  );

  /// IVA acreditable del mes (egresos deducibles y pagados, tasa 16%).
  Stream<double> watchIvaAcreditableDelMes({required int anio, required int mes}) => _watchSuma(
    columna: facturas.ivaTrasladado,
    tipo: TipoCfdi.egreso,
    inicio: DateTime(anio, mes, 1),
    finExclusivo: DateTime(anio, mes + 1, 1),
    soloDeducibles: true,
    tasaIva: 16.0,
  );

  /// IVA retenido del periodo (retenciones que traen los CFDI de ingreso cobrados).
  Stream<double> watchIvaRetenidoDelMes({required int anio, required int mes}) => _watchSuma(
    columna: facturas.ivaRetenido,
    tipo: TipoCfdi.ingreso,
    inicio: DateTime(anio, mes, 1),
    finExclusivo: DateTime(anio, mes + 1, 1),
  );

  Stream<double> _watchSuma({
    required Column<double> columna,
    required TipoCfdi tipo,
    required DateTime inicio,
    required DateTime finExclusivo,
    bool soloDeducibles = false,
    double? tasaIva,
  }) {
    final estatusEfectivo = tipo == TipoCfdi.ingreso ? EstatusPago.cobrado : EstatusPago.pagado;
    final suma = columna.sum();

    final query = selectOnly(facturas)
      ..addColumns([suma])
      ..where(facturas.tipoCfdi.equalsValue(tipo))
      ..where(facturas.estatusPago.equalsValue(estatusEfectivo))
      ..where(facturas.fechaPagoEfectivo.isBiggerOrEqualValue(inicio))
      ..where(facturas.fechaPagoEfectivo.isSmallerThanValue(finExclusivo));
    if (soloDeducibles) {
      query.where(facturas.esDeducible.equals(true));
    }
    if (tasaIva != null) {
      query.where(facturas.tasaIva.equals(tasaIva));
    }

    return query.map((row) => row.read(suma) ?? 0.0).watchSingle();
  }

  Stream<int> _watchContador({
    required TipoCfdi tipo,
    required DateTime inicio,
    required DateTime finExclusivo,
    bool soloDeducibles = false,
  }) {
    final estatusEfectivo = tipo == TipoCfdi.ingreso ? EstatusPago.cobrado : EstatusPago.pagado;
    final conteo = facturas.uuid.count();

    final query = selectOnly(facturas)
      ..addColumns([conteo])
      ..where(facturas.tipoCfdi.equalsValue(tipo))
      ..where(facturas.estatusPago.equalsValue(estatusEfectivo))
      ..where(facturas.fechaPagoEfectivo.isBiggerOrEqualValue(inicio))
      ..where(facturas.fechaPagoEfectivo.isSmallerThanValue(finExclusivo));
    if (soloDeducibles) {
      query.where(facturas.esDeducible.equals(true));
    }

    return query.map((row) => row.read(conteo) ?? 0).watchSingle();
  }

  // ---------------------------------------------------------------------
  // Contadores (pantalla de Configuración)
  // ---------------------------------------------------------------------

  Stream<int> watchContadorContribuyentes() =>
      (selectOnly(contribuyentes)..addColumns([contribuyentes.rfc.count()]))
          .map((row) => row.read(contribuyentes.rfc.count()) ?? 0)
          .watchSingle();

  Stream<int> watchContadorFacturasPorTipo(TipoCfdi tipo) => (selectOnly(facturas)
        ..addColumns([facturas.uuid.count()])
        ..where(facturas.tipoCfdi.equalsValue(tipo)))
      .map((row) => row.read(facturas.uuid.count()) ?? 0)
      .watchSingle();

  /// Purga completa de la base local ("Borrar todos los datos", sección 2.6).
  Future<void> borrarTodosLosDatos() async {
    await transaction(() async {
      await delete(inversiones).go();
      await delete(facturas).go();
      await delete(contribuyentes).go();
      await delete(capturasEspejo).go();
    });
  }

  // ---------------------------------------------------------------------
  // Capturas Espejo SAT (manuales, por periodo)
  // ---------------------------------------------------------------------

  Stream<CapturasEspejoData?> watchCapturaEspejo({required int anio, required int mes}) {
    return (select(capturasEspejo)
          ..where((c) => c.anio.equals(anio) & c.mes.equals(mes)))
        .watchSingleOrNull();
  }

  /// Inserta o actualiza la captura del periodo. Los campos no especificados
  /// (`null`) no se tocan si la fila ya existe, y toman su valor por defecto
  /// si es una fila nueva (vía `ON CONFLICT DO UPDATE` de Drift, que solo
  /// incluye en el `SET` las columnas presentes en el companion).
  Future<void> guardarCapturaEspejo({
    required int anio,
    required int mes,
    double? ptuPagada,
    double? perdidasFiscales,
    double? pagosProvisionalesAnteriores,
    double? saldoFavorIvaAnterior,
    TipoDeclaracion? tipoDeclaracion,
    bool? copropiedad,
  }) {
    return into(capturasEspejo).insertOnConflictUpdate(
      CapturasEspejoCompanion(
        anio: Value(anio),
        mes: Value(mes),
        ptuPagada: ptuPagada == null ? const Value.absent() : Value(ptuPagada),
        perdidasFiscales: perdidasFiscales == null
            ? const Value.absent()
            : Value(perdidasFiscales),
        pagosProvisionalesAnteriores: pagosProvisionalesAnteriores == null
            ? const Value.absent()
            : Value(pagosProvisionalesAnteriores),
        saldoFavorIvaAnterior: saldoFavorIvaAnterior == null
            ? const Value.absent()
            : Value(saldoFavorIvaAnterior),
        tipoDeclaracion: tipoDeclaracion == null ? const Value.absent() : Value(tipoDeclaracion),
        copropiedad: copropiedad == null ? const Value.absent() : Value(copropiedad),
      ),
    );
  }
}
