import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/fiscal/isr_engine.dart';
import '../../core/fiscal/iva_engine.dart';
import '../shared/periodo_activo_controller.dart';

Stream<T> _porPeriodo<T>(
  AsyncValue<PeriodoActivo> periodoAsync,
  Stream<T> Function(PeriodoActivo) builder,
) {
  return periodoAsync.when(
    data: builder,
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream<T>.error(error, stackTrace),
  );
}

final ingresosCobradosDelMesProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(periodo, (p) => db.watchIngresosCobradosDelMes(anio: p.anio, mes: p.mes));
});

final contadorIngresosDelMesProvider = StreamProvider.autoDispose<int>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(
    periodo,
    (p) => db.watchContadorIngresosCobradosDelMes(anio: p.anio, mes: p.mes),
  );
});

final gastosDeduciblesDelMesProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(periodo, (p) => db.watchGastosDeduciblesDelMes(anio: p.anio, mes: p.mes));
});

final contadorGastosDelMesProvider = StreamProvider.autoDispose<int>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(
    periodo,
    (p) => db.watchContadorGastosDeduciblesDelMes(anio: p.anio, mes: p.mes),
  );
});

final ingresosCobradosAcumuladosProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(
    periodo,
    (p) => db.watchIngresosCobradosAcumulados(anio: p.anio, hastaMes: p.mes),
  );
});

final deduccionesAutorizadasAcumuladasProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(
    periodo,
    (p) => db.watchDeduccionesAutorizadasAcumuladas(anio: p.anio, hastaMes: p.mes),
  );
});

final isrRetenidoAcumuladoProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(periodo, (p) => db.watchIsrRetenidoAcumulado(anio: p.anio, hastaMes: p.mes));
});

final ivaCobradoDelMesProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(periodo, (p) => db.watchIvaCobradoDelMes(anio: p.anio, mes: p.mes));
});

final ivaAcreditableDelMesProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(periodo, (p) => db.watchIvaAcreditableDelMes(anio: p.anio, mes: p.mes));
});

final ivaRetenidoDelMesProvider = StreamProvider.autoDispose<double>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);
  return _porPeriodo(periodo, (p) => db.watchIvaRetenidoDelMes(anio: p.anio, mes: p.mes));
});

/// Datos consolidados del Tablero (KPIs + proyecciones ISR/IVA).
class TableroDatos {
  const TableroDatos({
    required this.ingresosCobrados,
    required this.contadorIngresos,
    required this.gastosDeducibles,
    required this.contadorGastos,
    required this.isr,
    required this.iva,
  });

  final double ingresosCobrados;
  final int contadorIngresos;
  final double gastosDeducibles;
  final int contadorGastos;
  final IsrProvisionalResultado isr;
  final IvaResultado iva;

  double get utilidadDelMes => ingresosCobrados - gastosDeducibles;

  bool get hayComprobantesEnElMes => contadorIngresos > 0 || contadorGastos > 0;
}

/// Combina los providers reactivos anteriores con el motor de cálculo fiscal.
///
/// Nota (simplificación de la Fase 1, documentada en el plan de
/// implementación): PTU pagada, pérdidas fiscales de ejercicios anteriores,
/// pagos provisionales anteriores y el saldo a favor de IVA de periodos
/// anteriores son capturas manuales del módulo Espejo SAT (Fase 2) — aquí se
/// asumen en 0 mientras esa pantalla no existe.
final tableroDatosProvider = FutureProvider.autoDispose<TableroDatos>((ref) async {
  final periodo = await ref.watch(periodoActivoProvider.future);
  final fiscalRepo = ref.watch(fiscalDataRepositoryProvider);

  final ingresosCobrados = await ref.watch(ingresosCobradosDelMesProvider.future);
  final contadorIngresos = await ref.watch(contadorIngresosDelMesProvider.future);
  final gastosDeducibles = await ref.watch(gastosDeduciblesDelMesProvider.future);
  final contadorGastos = await ref.watch(contadorGastosDelMesProvider.future);

  final ingresosAcumulados = await ref.watch(ingresosCobradosAcumuladosProvider.future);
  final deduccionesAcumuladas = await ref.watch(deduccionesAutorizadasAcumuladasProvider.future);
  final isrRetenidoAcumulado = await ref.watch(isrRetenidoAcumuladoProvider.future);
  final tarifaMensual = await fiscalRepo.tarifaMensual(periodo.anio);

  final isr = IsrEngine.calcularProvisionalMensual(
    ingresosCobradosAcumulados: ingresosAcumulados,
    deduccionesAutorizadasAcumuladas: deduccionesAcumuladas,
    ptuPagada: 0,
    perdidasFiscalesAnteriores: 0,
    tarifaEneroMensual: tarifaMensual,
    mesActivo: periodo.mes,
    pagosProvisionalesAnteriores: 0,
    isrRetenidoAcumulado: isrRetenidoAcumulado,
  );

  final ivaCobrado = await ref.watch(ivaCobradoDelMesProvider.future);
  final ivaAcreditable = await ref.watch(ivaAcreditableDelMesProvider.future);
  final ivaRetenido = await ref.watch(ivaRetenidoDelMesProvider.future);

  final iva = IvaEngine.calcularDefinitivoMensual(
    ivaCobrado: ivaCobrado,
    ivaAcreditable: ivaAcreditable,
    ivaRetenidoDelPeriodo: ivaRetenido,
    saldoAFavorPeriodosAnteriores: 0,
  );

  return TableroDatos(
    ingresosCobrados: ingresosCobrados,
    contadorIngresos: contadorIngresos,
    gastosDeducibles: gastosDeducibles,
    contadorGastos: contadorGastos,
    isr: isr,
    iva: iva,
  );
});
