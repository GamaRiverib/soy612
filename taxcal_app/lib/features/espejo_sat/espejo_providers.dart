import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../app_providers.dart';
import '../../core/calendar/due_date_calculator.dart';
import '../../core/fiscal/isr_engine.dart';
import '../../core/fiscal/iva_engine.dart';
import '../shared/periodo_activo_controller.dart';
import '../tablero/tablero_providers.dart';
import 'capturas_espejo_controller.dart';

/// Los 3 pasos del stepper (sección 1.2 de la especificación funcional).
enum EspejoStep { config, determinacion, pago }

/// Los 2 sub-tabs del paso Determinación.
enum EspejoSubtab { isr, iva }

final espejoStepProvider = StateProvider.autoDispose<EspejoStep>((ref) => EspejoStep.config);
final espejoSubtabProvider = StateProvider.autoDispose<EspejoSubtab>((ref) => EspejoSubtab.isr);

/// Datos del sub-tab "ISR Propio" del paso Determinación (README, sección
/// "4. Espejo SAT"): expone tanto los componentes automáticos/manuales como
/// el resultado final, para que la UI pueda mostrar cada tarjeta.
class EspejoIsrDatos {
  const EspejoIsrDatos({
    required this.ingresosAcumulados,
    required this.deduccionesAcumuladas,
    required this.baseGravableAcumulada,
    required this.ptuPagada,
    required this.perdidasFiscales,
    required this.pagosProvisionalesAnteriores,
    required this.isrACargo,
  });

  final double ingresosAcumulados;
  final double deduccionesAcumuladas;
  final double baseGravableAcumulada;
  final double ptuPagada;
  final double perdidasFiscales;
  final double pagosProvisionalesAnteriores;
  final double isrACargo;
}

class EspejoIvaDatos {
  const EspejoIvaDatos({
    required this.ivaCobrado,
    required this.ivaAcreditable,
    required this.saldoFavorAnterior,
    required this.impuestoNeto,
  });

  final double ivaCobrado;
  final double ivaAcreditable;
  final double saldoFavorAnterior;

  /// Positivo = IVA a cargo del periodo. Negativo = saldo a favor.
  final double impuestoNeto;

  bool get esACargo => impuestoNeto > 0;
}

/// Determinación real de ISR (a diferencia del Tablero, que usa 0 como
/// simplificación rápida para PTU/pérdidas/pagos anteriores — aquí se usan
/// las capturas manuales reales del contribuyente para este periodo).
final espejoIsrDatosProvider = FutureProvider.autoDispose<EspejoIsrDatos>((ref) async {
  final periodo = await ref.watch(periodoActivoProvider.future);
  final captura = await ref.watch(capturaEspejoActivaProvider.future);
  final fiscalRepo = ref.watch(fiscalDataRepositoryProvider);

  final ingresosAcumulados = await ref.watch(ingresosCobradosAcumuladosProvider.future);
  final deduccionesAcumuladas = await ref.watch(deduccionesAutorizadasAcumuladasProvider.future);
  final isrRetenidoAcumulado = await ref.watch(isrRetenidoAcumuladoProvider.future);
  final tarifaMensual = await fiscalRepo.tarifaMensual(periodo.anio);

  final resultado = IsrEngine.calcularProvisionalMensual(
    ingresosCobradosAcumulados: ingresosAcumulados,
    deduccionesAutorizadasAcumuladas: deduccionesAcumuladas,
    ptuPagada: captura.ptuPagada,
    perdidasFiscalesAnteriores: captura.perdidasFiscales,
    tarifaEneroMensual: tarifaMensual,
    mesActivo: periodo.mes,
    pagosProvisionalesAnteriores: captura.pagosProvisionalesAnteriores,
    isrRetenidoAcumulado: isrRetenidoAcumulado,
  );

  return EspejoIsrDatos(
    ingresosAcumulados: ingresosAcumulados,
    deduccionesAcumuladas: deduccionesAcumuladas,
    baseGravableAcumulada: resultado.baseGravableAcumulada,
    ptuPagada: captura.ptuPagada,
    perdidasFiscales: captura.perdidasFiscales,
    pagosProvisionalesAnteriores: captura.pagosProvisionalesAnteriores,
    isrACargo: resultado.isrACargo,
  );
});

final espejoIvaDatosProvider = FutureProvider.autoDispose<EspejoIvaDatos>((ref) async {
  final captura = await ref.watch(capturaEspejoActivaProvider.future);

  final ivaCobrado = await ref.watch(ivaCobradoDelMesProvider.future);
  final ivaAcreditable = await ref.watch(ivaAcreditableDelMesProvider.future);
  final ivaRetenido = await ref.watch(ivaRetenidoDelMesProvider.future);

  final resultado = IvaEngine.calcularDefinitivoMensual(
    ivaCobrado: ivaCobrado,
    ivaAcreditable: ivaAcreditable,
    ivaRetenidoDelPeriodo: ivaRetenido,
    saldoAFavorPeriodosAnteriores: captura.saldoFavorIvaAnterior,
  );

  return EspejoIvaDatos(
    ivaCobrado: ivaCobrado,
    ivaAcreditable: ivaAcreditable,
    saldoFavorAnterior: captura.saldoFavorIvaAnterior,
    impuestoNeto: resultado.impuestoNeto,
  );
});

/// Fecha límite estimada de pago (sección 6.2 de la especificación
/// funcional). `null` si el contribuyente todavía no ha capturado su RFC en
/// Configuración.
final espejoFechaLimiteProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  final periodo = await ref.watch(periodoActivoProvider.future);
  final prefs = await ref.watch(appPreferencesProvider.future);
  final rfc = prefs.rfcContribuyente;
  if (rfc == null || rfc.length < 6) return null;

  try {
    return DueDateCalculator.calcularVencimiento(
      anio: periodo.anio,
      mesPeriodo: periodo.mes,
      rfc: rfc,
    );
  } on ArgumentError {
    return null;
  }
});
