import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/fiscal/bancarizacion.dart';
import '../../core/fiscal/deducciones_personales_engine.dart';
import '../../core/fiscal/tarifa_isr.dart';
import '../../core/fiscal/tarifa_progresiva.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../shared/periodo_activo_controller.dart';
import '../tablero/tablero_providers.dart';

final _ingresosAnualesProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return periodo.when(
    data: (p) => db.watchIngresosCobradosAcumulados(anio: p.anio, hastaMes: 12),
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream<double>.error(error, stackTrace),
  );
});

final _gastosAnualesProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return periodo.when(
    data: (p) => db.watchDeduccionesAutorizadasAcumuladas(anio: p.anio, hastaMes: 12),
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream<double>.error(error, stackTrace),
  );
});

final _ingresosMesFamily = StreamProvider.family.autoDispose<double, (int anio, int mes)>((
  ref,
  parametros,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchIngresosCobradosDelMes(anio: parametros.$1, mes: parametros.$2);
});

final _gastosMesFamily = StreamProvider.family.autoDispose<double, (int anio, int mes)>((
  ref,
  parametros,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchGastosDeduciblesDelMes(anio: parametros.$1, mes: parametros.$2);
});

final _egresosAnualesListProvider = StreamProvider.autoDispose<List<FacturaConContraparte>>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return periodo.when(
    data: (p) => db.watchFacturasParaDetalle(
      tipo: TipoCfdi.egreso,
      inicio: DateTime(p.anio),
      finExclusivo: DateTime(p.anio + 1),
    ),
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream<List<FacturaConContraparte>>.error(error, stackTrace),
  );
});

/// Bolsa de deducciones personales del ejercicio activo.
final deduccionesPersonalesProvider = StreamProvider.autoDispose<List<DeduccionPersonal>>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return periodo.when(
    data: (p) => db.watchDeduccionesPersonales(p.anio),
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream<List<DeduccionPersonal>>.error(error, stackTrace),
  );
});

/// Datos consolidados de la pantalla Anual (README, sección "5. Anual").
class AnualDatos {
  const AnualDatos({
    required this.ingresosAnuales,
    required this.gastosAnuales,
    required this.tendenciaMensual,
    required this.violacionesBancarizacion,
    required this.totalNoBancarizado,
    required this.topeDeduccionesPersonales,
    required this.deduccionesPersonalesAplicadas,
    required this.porcentajeDeduccionesAplicadas,
    required this.baseGravableAnual,
    required this.isrCausadoAnual,
    required this.pagosProvisionalesRealizados,
    required this.saldoAnual,
  });

  final double ingresosAnuales;
  final double gastosAnuales;

  /// 12 pares (ingresos, gastos), índice 0 = enero.
  final List<(double ingresos, double gastos)> tendenciaMensual;
  final List<FacturaConContraparte> violacionesBancarizacion;
  final double totalNoBancarizado;
  final double topeDeduccionesPersonales;
  final double deduccionesPersonalesAplicadas;
  final int porcentajeDeduccionesAplicadas;
  final double baseGravableAnual;
  final double isrCausadoAnual;
  final double pagosProvisionalesRealizados;

  /// Positivo = ISR a cargo estimado. Negativo = saldo a favor estimado.
  final double saldoAnual;

  bool get hayViolacionesBancarizacion => violacionesBancarizacion.isNotEmpty;
}

final anualDatosProvider = FutureProvider.autoDispose<AnualDatos>((ref) async {
  final periodo = await ref.watch(periodoActivoProvider.future);
  final fiscalRepo = ref.watch(fiscalDataRepositoryProvider);

  final ingresosAnuales = await ref.watch(_ingresosAnualesProvider.future);
  final gastosAnuales = await ref.watch(_gastosAnualesProvider.future);

  final tendenciaMensual = <(double, double)>[];
  for (var mes = 1; mes <= 12; mes++) {
    final ingresosMes = await ref.watch(_ingresosMesFamily((periodo.anio, mes)).future);
    final gastosMes = await ref.watch(_gastosMesFamily((periodo.anio, mes)).future);
    tendenciaMensual.add((ingresosMes, gastosMes));
  }

  final egresosDelAnio = await ref.watch(_egresosAnualesListProvider.future);
  final violaciones = egresosDelAnio
      .where(
        (f) => ReglaBancarizacion.violaBancarizacion(
          subtotal: f.factura.subtotal,
          formaPago: f.factura.formaPago,
        ),
      )
      .toList(growable: false);
  final totalNoBancarizado = violaciones.fold(0.0, (acumulado, f) => acumulado + f.factura.total);

  final deducciones = await ref.watch(deduccionesPersonalesProvider.future);
  final uma = await fiscalRepo.uma(periodo.anio);
  final tope = DeduccionesPersonalesEngine.topeGlobalAnual(
    ingresosAnuales: ingresosAnuales,
    umaAnual: uma.anual,
  );
  final aplicadas = DeduccionesPersonalesEngine.sumaAplicada(deducciones: deducciones, tope: tope);
  final porcentajeAplicadas = tope > 0 ? ((aplicadas / tope) * 100).round().clamp(0, 100) : 0;

  final tarifaAnual = await fiscalRepo.tarifaAnual(periodo.anio);
  final baseGravableAnual = _noNegativo(ingresosAnuales - gastosAnuales - aplicadas);
  final isrCausadoAnual = aplicarTarifaProgresiva(tarifaAnual, baseGravableAnual).impuestoCausado;

  // "Pagos provisionales ya hechos": el ISR causado acumulado a la fecha vía
  // el mecanismo provisional (tarifa mensual escalada al mes activo), que por
  // ser un cálculo acumulativo ya representa el total generado en el año a
  // esa altura del ejercicio.
  final ingresosAcumuladosMesActivo = await ref.watch(ingresosCobradosAcumuladosProvider.future);
  final deduccionesAcumuladasMesActivo = await ref.watch(
    deduccionesAutorizadasAcumuladasProvider.future,
  );
  final tarifaMensual = await fiscalRepo.tarifaMensual(periodo.anio);
  final tarifaMensualEscalada = TablaTarifaIsr(
    anio: tarifaMensual.anio,
    renglones: tarifaMensual.renglones.map((r) => r.escalar(periodo.mes)).toList(growable: false),
  );
  final baseAcumuladaMesActivo = _noNegativo(
    ingresosAcumuladosMesActivo - deduccionesAcumuladasMesActivo,
  );
  final pagosProvisionalesRealizados = aplicarTarifaProgresiva(
    tarifaMensualEscalada,
    baseAcumuladaMesActivo,
  ).impuestoCausado;

  return AnualDatos(
    ingresosAnuales: ingresosAnuales,
    gastosAnuales: gastosAnuales,
    tendenciaMensual: tendenciaMensual,
    violacionesBancarizacion: violaciones,
    totalNoBancarizado: totalNoBancarizado,
    topeDeduccionesPersonales: tope,
    deduccionesPersonalesAplicadas: aplicadas,
    porcentajeDeduccionesAplicadas: porcentajeAplicadas,
    baseGravableAnual: baseGravableAnual,
    isrCausadoAnual: isrCausadoAnual,
    pagosProvisionalesRealizados: pagosProvisionalesRealizados,
    saldoAnual: isrCausadoAnual - pagosProvisionalesRealizados,
  );
});

double _noNegativo(double valor) => valor < 0 ? 0 : valor;
