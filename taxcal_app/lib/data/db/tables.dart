import 'package:drift/drift.dart';

/// Clasificación según la longitud del RFC (13 = física, 12 = moral).
enum TipoPersona { fisica, moral }

/// `tipo_cfdi` (sección 3.2 de la especificación de datos).
enum TipoCfdi { ingreso, egreso, pago }

enum MetodoPagoCfdi { pue, ppd }

/// Estado del flujo de efectivo para conciliación.
enum EstatusPago { pendiente, cobrado, pagado }

/// Determina la tasa de depreciación máxima anual (tabla `inversiones`).
enum TipoActivo { computo, mobiliario, autoCombustion, autoHibrido, pickup }

/// Tipo de declaración del módulo Espejo SAT (sección 2.4 de la
/// especificación funcional, paso "Configuración").
enum TipoDeclaracion { normal, complementaria }

/// Colección `contribuyentes` (CRM offline) — sección 3.1.
class Contribuyentes extends Table {
  TextColumn get rfc => text()();
  TextColumn get razonSocial => text()();
  IntColumn get tipoPersona => intEnum<TipoPersona>()();
  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {rfc};
}

/// Colección `facturas` — desglose de CFDI 4.0 (sección 3.2).
class Facturas extends Table {
  TextColumn get uuid => text()();
  TextColumn get folioInterno => text().nullable()();
  DateTimeColumn get fechaEmision => dateTime()();
  DateTimeColumn get fechaPagoEfectivo => dateTime().nullable()();
  TextColumn get rfcEmisor => text().references(Contribuyentes, #rfc)();
  TextColumn get rfcReceptor => text().references(Contribuyentes, #rfc)();
  IntColumn get tipoCfdi => intEnum<TipoCfdi>()();
  RealColumn get subtotal => real()();
  RealColumn get tasaIva => real().withDefault(const Constant(16.0))();
  RealColumn get ivaTrasladado => real().withDefault(const Constant(0.0))();
  RealColumn get ivaRetenido => real().withDefault(const Constant(0.0))();
  RealColumn get isrRetenido => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  IntColumn get metodoPago => intEnum<MetodoPagoCfdi>()();
  TextColumn get formaPago => text()();
  BoolColumn get esDeducible => boolean().withDefault(const Constant(true))();
  IntColumn get estatusPago => intEnum<EstatusPago>()();

  @override
  Set<Column> get primaryKey => {uuid};
}

/// Colección `inversiones` (activos fijos) — sección 3.3.
class Inversiones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuidFactura => text().unique().references(Facturas, #uuid)();
  IntColumn get tipoActivo => intEnum<TipoActivo>()();
  RealColumn get montoOriginal => real()();
  RealColumn get pctDepreciacion => real()();
  DateTimeColumn get fechaAdquisicion => dateTime()();
}

/// Capturas manuales del módulo Espejo SAT por periodo (año/mes): campos que
/// no vienen de los CFDIs y que el SAT exige capturar a mano (PTU pagada,
/// pérdidas fiscales, pagos provisionales anteriores, saldo a favor de IVA
/// anterior), más el tipo de declaración y la respuesta de copropiedad del
/// paso "Configuración".
class CapturasEspejo extends Table {
  IntColumn get anio => integer()();
  IntColumn get mes => integer()();
  RealColumn get ptuPagada => real().withDefault(const Constant(0.0))();
  RealColumn get perdidasFiscales => real().withDefault(const Constant(0.0))();
  RealColumn get pagosProvisionalesAnteriores => real().withDefault(const Constant(0.0))();
  RealColumn get saldoFavorIvaAnterior => real().withDefault(const Constant(0.0))();
  IntColumn get tipoDeclaracion =>
      intEnum<TipoDeclaracion>().withDefault(Constant(TipoDeclaracion.normal.index))();
  BoolColumn get copropiedad => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {anio, mes};
}
