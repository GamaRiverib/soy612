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

enum EspejoImpuesto { isr, iva }

enum CampoSatTipo { auto, cotejo, manual, ceroSugerido, calculado }

class CampoSat {
  const CampoSat({
    required this.id,
    required this.label,
    required this.tipo,
    required this.valor,
    this.helper,
    this.signo,
    this.detalle,
    this.opciones = const [],
    this.opcionSeleccionada,
  });

  final String id;
  final String label;
  final CampoSatTipo tipo;
  final double valor;
  final String? helper;
  final String? signo;
  final String? detalle;
  final List<String> opciones;
  final String? opcionSeleccionada;

  bool get editable => tipo == CampoSatTipo.manual || tipo == CampoSatTipo.ceroSugerido;
  bool get copiable => tipo != CampoSatTipo.manual;
}

class SeccionSat {
  const SeccionSat({
    required this.id,
    required this.titulo,
    required this.impuesto,
    required this.campos,
  });

  final String id;
  final String titulo;
  final EspejoImpuesto impuesto;
  final List<CampoSat> campos;
}

class ResumenSatCompacto {
  const ResumenSatCompacto({
    required this.ingresosMes,
    required this.ingresosAnteriores,
    required this.gastosMes,
    required this.gastosAnteriores,
    required this.isrRetenidoMes,
    required this.isrRetenidoAnterior,
    required this.ivaCobrado,
    required this.ivaAcreditable,
    required this.ivaRetenido,
  });

  final double ingresosMes;
  final double ingresosAnteriores;
  final double gastosMes;
  final double gastosAnteriores;
  final double isrRetenidoMes;
  final double isrRetenidoAnterior;
  final double ivaCobrado;
  final double ivaAcreditable;
  final double ivaRetenido;
}

class EspejoSatGuiadoDatos {
  const EspejoSatGuiadoDatos({
    required this.secciones,
    required this.resumen,
    required this.isr,
    required this.iva,
  });

  final List<SeccionSat> secciones;
  final ResumenSatCompacto resumen;
  final EspejoIsrDatos isr;
  final EspejoIvaDatos iva;
}

final espejoStepProvider = StateProvider.autoDispose<EspejoStep>((ref) => EspejoStep.config);
final espejoSubtabProvider = StateProvider.autoDispose<EspejoSubtab>((ref) => EspejoSubtab.isr);
final espejoImpuestoProvider = StateProvider.autoDispose<EspejoImpuesto>((ref) => EspejoImpuesto.isr);
final espejoSeccionIdProvider = StateProvider.autoDispose<String>((ref) => 'isr_ingresos');

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
    required this.isrRetenidoAcumulado,
    required this.isrCausado,
    required this.isrACargo,
  });

  final double ingresosAcumulados;
  final double deduccionesAcumuladas;
  final double baseGravableAcumulada;
  final double ptuPagada;
  final double perdidasFiscales;
  final double pagosProvisionalesAnteriores;
  final double isrRetenidoAcumulado;
  final double isrCausado;
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
    isrRetenidoAcumulado: isrRetenidoAcumulado,
    isrCausado: resultado.isrCausado,
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

final espejoSatGuiadoProvider = FutureProvider.autoDispose<EspejoSatGuiadoDatos>((ref) async {
  final periodo = await ref.watch(periodoActivoProvider.future);
  final db = ref.watch(appDatabaseProvider);
  final captura = await ref.watch(capturaEspejoActivaProvider.future);
  final capturas = await db.watchCapturasSatCampos(anio: periodo.anio, mes: periodo.mes).first;
  final valores = {for (final item in capturas) item.campoId: item};

  double manual(String id, [double legacy = 0]) => valores[id]?.valor ?? legacy;
  String opcion(String id, String fallback) => valores[id]?.opcion ?? fallback;

  final ingresosMes = await db.watchIngresosCobradosDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final ingresosAnteriores =
      await db.watchIngresosCobradosAntesDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final gastosMes = await db.watchGastosDeduciblesDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final gastosAnteriores =
      await db.watchGastosDeduciblesAntesDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final isrRetenidoAcumulado =
      await db.watchIsrRetenidoAcumulado(anio: periodo.anio, hastaMes: periodo.mes).first;
  final isrRetenidoAnterior =
      await db.watchIsrRetenidoAntesDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final isrRetenidoMes = isrRetenidoAcumulado - isrRetenidoAnterior;
  final baseIngresos16 =
      await db.watchBaseIngresosPorTasaDelMes(anio: periodo.anio, mes: periodo.mes, tasaIva: 16).first;
  final baseIngresos0 =
      await db.watchBaseIngresosPorTasaDelMes(anio: periodo.anio, mes: periodo.mes, tasaIva: 0).first;
  final baseGastos16 =
      await db.watchBaseGastosPorTasaDelMes(anio: periodo.anio, mes: periodo.mes, tasaIva: 16).first;
  final ivaCobrado = await db.watchIvaCobradoDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final ivaAcreditableDb = await db.watchIvaAcreditableDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final ivaRetenido = await db.watchIvaRetenidoDelMes(anio: periodo.anio, mes: periodo.mes).first;
  final isr = await ref.watch(espejoIsrDatosProvider.future);
  final iva = await ref.watch(espejoIvaDatosProvider.future);

  final ingresosDisminuir = manual('isr_ingresos_disminuir');
  final ingresosAdicionales = manual('isr_ingresos_adicionales');
  final ingresosExentos = manual('isr_ingresos_exentos');
  final ingresosDelMesSat = ingresosMes - ingresosDisminuir + ingresosAdicionales;
  final totalIngresosPeriodo = ingresosDelMesSat - ingresosExentos + ingresosAnteriores;
  final nomina = manual('isr_nomina_no_prellenada');
  final inversiones = manual('isr_deduccion_inversiones');
  final inmediata = manual('isr_deduccion_inmediata');
  final totalDeducciones = gastosMes + gastosAnteriores + nomina + inversiones + inmediata;
  final ptu = manual('isr_ptu', captura.ptuPagada);
  final perdidas = manual('isr_perdidas_fiscales', captura.perdidasFiscales);
  final pagosRegistradosAnteriores = await db.sumarCapturasSatCampoAntesDeMes(
    anio: periodo.anio,
    mes: periodo.mes,
    campoId: 'isr_pago_realizado',
  );
  final pagosSatPrevios = await db.maxCapturasSatCampoAntesDeMes(
    anio: periodo.anio,
    mes: periodo.mes,
    campoId: 'isr_pagos_provisionales_anteriores',
  );
  final pagosLegacyPrevios = await db.maxPagosProvisionalesLegacyAntesDeMes(
    anio: periodo.anio,
    mes: periodo.mes,
  );
  final pagosPrecargados = [
    pagosRegistradosAnteriores,
    pagosSatPrevios,
    pagosLegacyPrevios,
    captura.pagosProvisionalesAnteriores,
  ].reduce((a, b) => a > b ? a : b);
  final pagosProvisionales = valores.containsKey('isr_pagos_provisionales_anteriores') &&
          manual('isr_pagos_provisionales_anteriores') > 0
      ? manual('isr_pagos_provisionales_anteriores')
      : pagosPrecargados;
  final pagoRealizadoPeriodo = manual('isr_pago_realizado');
  final isrCargoMostrado =
      (isr.isrCausado - pagosProvisionales - isrRetenidoAcumulado).clamp(0, double.infinity).toDouble();

  final iva0Exportacion = manual('iva_0_exportacion');
  final ivaExentosCargo = manual('iva_exentos_cargo');
  final ivaNoObjeto = manual('iva_no_objeto');
  final ivaReintegro = manual('iva_reintegro_ajuste');
  final totalIvaCargo = ivaCobrado + ivaReintegro;
  final ivaTrasladadoPagado = manual('iva_trasladado_efectivamente_pagado', ivaAcreditableDb);
  final proporcionOpcion = opcion('iva_proporcion_opcion', 'Art. 5-B de la LIVA');
  final proporcion = manual('iva_proporcion');
  final ivaProporcionado = proporcionOpcion == 'Art. 5 de la LIVA' && proporcion > 0
      ? ivaTrasladadoPagado * (proporcion / 100)
      : ivaTrasladadoPagado;
  final ivaAcreditableActualizado = manual('iva_acreditable_actualizado');
  final totalIvaAcreditable = ivaProporcionado + ivaAcreditableActualizado;
  final otrasCargo = manual('iva_otras_cantidades_cargo');
  final otrasFavor = manual('iva_otras_cantidades_favor');
  final devolucion = manual('iva_devolucion_inmediata');
  final ivaNeto = totalIvaCargo - ivaRetenido - totalIvaAcreditable + otrasCargo - otrasFavor;
  final saldoFavor = ivaNeto < 0 ? ivaNeto.abs() : 0.0;
  final impuestoFavor = saldoFavor - devolucion;
  final impuestoCargo = ivaNeto > 0 ? ivaNeto : 0.0;

  CampoSat campo(String id, String label, CampoSatTipo tipo, double valor,
          {String? signo, String? helper, String? detalle, List<String> opciones = const [], String? opcionSeleccionada}) =>
      CampoSat(
        id: id,
        label: label,
        tipo: tipo,
        valor: valor < 0 && tipo != CampoSatTipo.calculado ? 0 : valor,
        signo: signo,
        helper: helper,
        detalle: detalle,
        opciones: opciones,
        opcionSeleccionada: opcionSeleccionada,
      );

  final secciones = <SeccionSat>[
    SeccionSat(id: 'isr_ingresos', titulo: 'Ingresos', impuesto: EspejoImpuesto.isr, campos: [
      campo('isr_copropiedad', 'Tus ingresos fueron obtenidos en copropiedad o sociedad conyugal',
          CampoSatTipo.cotejo, captura.copropiedad ? 1 : 0, helper: 'Default: No.'),
      campo('isr_ingresos_cobrados_mes', 'Ingresos cobrados del mes', CampoSatTipo.cotejo, ingresosMes,
          detalle: 'ingresos_mes'),
      campo('isr_ingresos_disminuir', 'Tienes ingresos a disminuir del mes', CampoSatTipo.ceroSugerido,
          ingresosDisminuir, signo: '-'),
      campo('isr_ingresos_adicionales', 'Tienes ingresos adicionales del mes', CampoSatTipo.ceroSugerido,
          ingresosAdicionales, signo: '+'),
      campo('isr_ingresos_mes', 'Ingresos del mes', CampoSatTipo.calculado, ingresosDelMesSat, signo: '='),
      campo('isr_ingresos_exentos', 'Ingresos exentos', CampoSatTipo.ceroSugerido, ingresosExentos, signo: '-'),
      campo('isr_ingresos_anteriores', 'Ingresos de meses anteriores', CampoSatTipo.cotejo, ingresosAnteriores,
          signo: '+', detalle: 'ingresos_anteriores'),
      campo('isr_total_ingresos_periodo', 'Total de ingresos del periodo', CampoSatTipo.calculado,
          totalIngresosPeriodo, signo: '='),
    ]),
    SeccionSat(id: 'isr_deducciones', titulo: 'Deducciones autorizadas', impuesto: EspejoImpuesto.isr, campos: [
      campo('isr_nomina_no_prellenada', 'Gastos de nomina del periodo no considerados en el prellenado',
          CampoSatTipo.ceroSugerido, nomina),
      campo('isr_compras_gastos_periodo', 'Compras y gastos del periodo', CampoSatTipo.cotejo, gastosMes,
          signo: '+',
          detalle: 'gastos_mes',
          helper: 'Soy612 muestra solo el mes activo; el total acumulado aparece abajo.'),
      campo('isr_deduccion_inversiones', 'Deduccion de inversiones del periodo', CampoSatTipo.ceroSugerido,
          inversiones, signo: '+'),
      campo('isr_deduccion_inmediata', 'Deduccion inmediata de inversiones', CampoSatTipo.ceroSugerido,
          inmediata, signo: '+'),
      campo('isr_facilidades_estimulos', 'Tienes facilidades administrativas y estimulos por aplicar',
          CampoSatTipo.cotejo, 0, helper: 'Default: No.'),
      campo('isr_total_deducciones', 'Total de deducciones autorizadas', CampoSatTipo.calculado,
          totalDeducciones, signo: '='),
    ]),
    SeccionSat(id: 'isr_determinacion', titulo: 'Determinacion', impuesto: EspejoImpuesto.isr, campos: [
      campo('isr_total_ingresos_periodo_det', 'Total de ingresos del periodo', CampoSatTipo.calculado,
          totalIngresosPeriodo),
      campo('isr_total_deducciones_det', 'Total de deducciones autorizadas', CampoSatTipo.calculado,
          totalDeducciones, signo: '-'),
      campo('isr_ptu', 'Participacion de los trabajadores en las utilidades', CampoSatTipo.manual, ptu, signo: '-'),
      campo('isr_perdidas_fiscales', 'Perdidas fiscales de ejercicios anteriores que se aplican en el periodo',
          CampoSatTipo.manual, perdidas, signo: '-'),
      campo('isr_base_gravable', 'Base gravable', CampoSatTipo.calculado, isr.baseGravableAcumulada, signo: '='),
      campo('isr_impuesto_causado', 'Impuesto causado', CampoSatTipo.calculado, isr.isrCausado),
      campo('isr_estimulos', 'Tienes estimulos por aplicar', CampoSatTipo.cotejo, 0, helper: 'Default: No.'),
      campo('isr_impuesto_periodo', 'Impuesto del periodo', CampoSatTipo.calculado, isr.isrCausado, signo: '-'),
      campo('isr_pagos_provisionales_anteriores', 'Pagos provisionales efectuados con anterioridad',
          CampoSatTipo.manual, pagosProvisionales,
          signo: '-',
          helper: 'Pre-cargado con pagos ISR registrados en meses previos; puedes ajustarlo para igualar SAT.'),
      campo('isr_total_retenido', 'Total de ISR retenido', CampoSatTipo.cotejo, isrRetenidoAcumulado,
          signo: '-', detalle: 'isr_retenido'),
      campo('isr_impuesto_cargo', 'Impuesto a cargo', CampoSatTipo.calculado, isrCargoMostrado, signo: '='),
    ]),
    SeccionSat(id: 'isr_pago', titulo: 'Pago', impuesto: EspejoImpuesto.isr, campos: [
      campo('isr_pago_a_cargo', 'A cargo', CampoSatTipo.calculado, isrCargoMostrado),
      campo('isr_pago_total_contribuciones', 'Total de contribuciones', CampoSatTipo.calculado, isrCargoMostrado,
          signo: '='),
      campo('isr_pago_total_aplicaciones', 'Total de aplicaciones', CampoSatTipo.ceroSugerido, 0, signo: '='),
      campo('isr_pago_cantidad_pagar', 'Cantidad a pagar', CampoSatTipo.calculado, isrCargoMostrado),
      campo('isr_pago_realizado', 'Pago ISR realizado para este periodo', CampoSatTipo.manual, pagoRealizadoPeriodo,
          helper: 'Registro interno: se sumara como pago previo en declaraciones posteriores.'),
    ]),
    SeccionSat(id: 'iva_cargo', titulo: 'IVA a cargo', impuesto: EspejoImpuesto.iva, campos: [
      campo('iva_base_16', 'Valor de los actos o actividades gravados a la tasa del 16%',
          CampoSatTipo.cotejo, baseIngresos16, detalle: 'ingresos_mes'),
      campo('iva_0_exportacion', 'Valor de actos gravados a la tasa del 0% exportacion',
          CampoSatTipo.ceroSugerido, iva0Exportacion, signo: '+'),
      campo('iva_0_otros', 'Valor de actos gravados a la tasa del 0% otros', CampoSatTipo.cotejo, baseIngresos0,
          signo: '+'),
      campo('iva_suma_actos_gravados', 'Suma de los actos o actividades gravados', CampoSatTipo.calculado,
          baseIngresos16 + baseIngresos0 + iva0Exportacion, signo: '='),
      campo('iva_exentos_cargo', 'Valor de actos por los que no se deba pagar el impuesto',
          CampoSatTipo.ceroSugerido, ivaExentosCargo),
      campo('iva_no_objeto', 'Valor de actos no objeto del impuesto', CampoSatTipo.ceroSugerido, ivaNoObjeto),
      campo('iva_cargo_16', 'IVA a cargo a la tasa del 16%', CampoSatTipo.calculado, ivaCobrado),
      campo('iva_reintegro_ajuste', 'Cantidad actualizada a reintegrarse derivada del ajuste',
          CampoSatTipo.ceroSugerido, ivaReintegro, signo: '+'),
      campo('iva_total_cargo', 'Total de IVA a cargo', CampoSatTipo.calculado, totalIvaCargo, signo: '='),
    ]),
    SeccionSat(id: 'iva_acreditable', titulo: 'IVA acreditable', impuesto: EspejoImpuesto.iva, campos: [
      campo('iva_pagados_16_base', 'Valor de actos pagados a la tasa del 16%', CampoSatTipo.cotejo, baseGastos16,
          detalle: 'gastos_mes'),
      campo('iva_region_frontera_base', 'Valor pagado sujeto al estimulo de la region fronteriza',
          CampoSatTipo.ceroSugerido, manual('iva_region_frontera_base')),
      campo('iva_importacion_16_base', 'Valor pagado en importacion a la tasa del 16%',
          CampoSatTipo.ceroSugerido, manual('iva_importacion_16_base')),
      campo('iva_pagados_0_base', 'Valor de los demas actos pagados a la tasa del 0%', CampoSatTipo.ceroSugerido, 0),
      campo('iva_exentos_pagados', 'Valor de actos pagados por los que no se pagara el IVA',
          CampoSatTipo.ceroSugerido, manual('iva_exentos_pagados')),
      campo('iva_pagado_16', 'IVA de actos pagados a la tasa del 16%', CampoSatTipo.calculado, ivaAcreditableDb),
      campo('iva_trasladado_efectivamente_pagado', 'IVA trasladado al contribuyente efectivamente pagado',
          CampoSatTipo.manual, ivaTrasladadoPagado),
      campo('iva_proporcion_opcion', 'Selecciona la proporcion de IVA que aplicaras', CampoSatTipo.cotejo, 0,
          opciones: const ['Art. 5-B de la LIVA', 'Art. 5 de la LIVA'], opcionSeleccionada: proporcionOpcion),
      campo('iva_proporcion', 'Proporcion de IVA', CampoSatTipo.ceroSugerido, proporcion),
      campo('iva_acreditable_bienes_indistintos', 'IVA acreditable de bienes utilizados indistintamente',
          CampoSatTipo.calculado, ivaProporcionado),
      campo('iva_acreditable_actualizado', 'Monto acreditable actualizado a incrementar derivado del ajuste',
          CampoSatTipo.ceroSugerido, ivaAcreditableActualizado, signo: '+'),
      campo('iva_total_acreditable', 'Total de IVA acreditable', CampoSatTipo.calculado, totalIvaAcreditable,
          signo: '='),
    ]),
    SeccionSat(id: 'iva_determinacion', titulo: 'Determinacion', impuesto: EspejoImpuesto.iva, campos: [
      campo('iva_det_total_cargo', 'Total de IVA a cargo', CampoSatTipo.calculado, totalIvaCargo),
      campo('iva_retenido', 'IVA retenido', CampoSatTipo.cotejo, ivaRetenido, detalle: 'iva_retenido'),
      campo('iva_det_total_acreditable', 'Total de IVA acreditable', CampoSatTipo.calculado, totalIvaAcreditable),
      campo('iva_otras_cantidades_cargo', 'Otras cantidades a cargo del contribuyente', CampoSatTipo.ceroSugerido,
          otrasCargo),
      campo('iva_otras_cantidades_favor', 'Otras cantidades a favor del contribuyente', CampoSatTipo.ceroSugerido,
          otrasFavor),
      campo('iva_saldo_favor', 'Saldo a favor', CampoSatTipo.calculado, saldoFavor),
      campo('iva_devolucion_inmediata', 'Devolucion inmediata obtenida', CampoSatTipo.ceroSugerido, devolucion),
      campo('iva_impuesto_favor', 'Impuesto a favor', CampoSatTipo.calculado, impuestoFavor < 0 ? 0 : impuestoFavor),
      campo('iva_impuesto_cargo', 'Impuesto a cargo', CampoSatTipo.calculado, impuestoCargo),
    ]),
    SeccionSat(id: 'iva_pago', titulo: 'Pago', impuesto: EspejoImpuesto.iva, campos: [
      campo('iva_pago_total_contribuciones', 'Total de contribuciones', CampoSatTipo.calculado, impuestoCargo),
      campo('iva_pago_total_aplicaciones', 'Total de aplicaciones', CampoSatTipo.ceroSugerido, 0),
      campo('iva_pago_cantidad_pagar', 'Cantidad a pagar', CampoSatTipo.calculado, impuestoCargo),
    ]),
  ];

  return EspejoSatGuiadoDatos(
    secciones: secciones,
    resumen: ResumenSatCompacto(
      ingresosMes: ingresosMes,
      ingresosAnteriores: ingresosAnteriores,
      gastosMes: gastosMes,
      gastosAnteriores: gastosAnteriores,
      isrRetenidoMes: isrRetenidoMes,
      isrRetenidoAnterior: isrRetenidoAnterior,
      ivaCobrado: ivaCobrado,
      ivaAcreditable: totalIvaAcreditable,
      ivaRetenido: ivaRetenido,
    ),
    isr: isr,
    iva: EspejoIvaDatos(
      ivaCobrado: ivaCobrado,
      ivaAcreditable: totalIvaAcreditable,
      saldoFavorAnterior: iva.saldoFavorAnterior,
      impuestoNeto: impuestoCargo > 0 ? impuestoCargo : -saldoFavor,
    ),
  );
});
