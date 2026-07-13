import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../shared/periodo_activo_controller.dart';

/// Captura manual del periodo activo (o valores por defecto en 0 /
/// Normal / sin copropiedad si el usuario todavía no ha capturado nada para
/// ese mes).
final capturaEspejoActivaProvider = StreamProvider.autoDispose<CapturasEspejoData>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final db = ref.watch(appDatabaseProvider);

  return periodo.when(
    data: (p) => db
        .watchCapturaEspejo(anio: p.anio, mes: p.mes)
        .map((captura) => captura ?? _capturaVacia(p.anio, p.mes)),
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream<CapturasEspejoData>.error(error, stackTrace),
  );
});

CapturasEspejoData _capturaVacia(int anio, int mes) => CapturasEspejoData(
  anio: anio,
  mes: mes,
  ptuPagada: 0,
  perdidasFiscales: 0,
  pagosProvisionalesAnteriores: 0,
  saldoFavorIvaAnterior: 0,
  tipoDeclaracion: TipoDeclaracion.normal,
  copropiedad: false,
);

/// Escribe capturas manuales del Espejo SAT para el periodo activo.
class CapturasEspejoController extends Notifier<void> {
  @override
  void build() {}

  Future<void> _guardar({
    double? ptuPagada,
    double? perdidasFiscales,
    double? pagosProvisionalesAnteriores,
    double? saldoFavorIvaAnterior,
    TipoDeclaracion? tipoDeclaracion,
    bool? copropiedad,
  }) async {
    final periodo = await ref.read(periodoActivoProvider.future);
    final db = ref.read(appDatabaseProvider);
    await db.guardarCapturaEspejo(
      anio: periodo.anio,
      mes: periodo.mes,
      ptuPagada: ptuPagada,
      perdidasFiscales: perdidasFiscales,
      pagosProvisionalesAnteriores: pagosProvisionalesAnteriores,
      saldoFavorIvaAnterior: saldoFavorIvaAnterior,
      tipoDeclaracion: tipoDeclaracion,
      copropiedad: copropiedad,
    );
  }

  Future<void> guardarCampoSat(String campoId, double valor) async {
    final periodo = await ref.read(periodoActivoProvider.future);
    final db = ref.read(appDatabaseProvider);
    await db.guardarCapturaSatCampo(
      anio: periodo.anio,
      mes: periodo.mes,
      campoId: campoId,
      valor: valor,
    );
    switch (campoId) {
      case 'isr_ptu':
        await _guardar(ptuPagada: valor);
      case 'isr_perdidas_fiscales':
        await _guardar(perdidasFiscales: valor);
      case 'isr_pagos_provisionales_anteriores':
        await _guardar(pagosProvisionalesAnteriores: valor);
      case 'iva_saldo_favor_anterior':
        await _guardar(saldoFavorIvaAnterior: valor);
    }
  }

  Future<void> guardarOpcionSat(String campoId, String opcion) async {
    final periodo = await ref.read(periodoActivoProvider.future);
    final db = ref.read(appDatabaseProvider);
    await db.guardarCapturaSatCampo(
      anio: periodo.anio,
      mes: periodo.mes,
      campoId: campoId,
      opcion: opcion,
    );
  }

  Future<void> guardarPtuPagada(double valor) async {
    await _guardar(ptuPagada: valor);
    await guardarCampoSat('isr_ptu', valor);
  }

  Future<void> guardarPerdidasFiscales(double valor) async {
    await _guardar(perdidasFiscales: valor);
    await guardarCampoSat('isr_perdidas_fiscales', valor);
  }

  Future<void> guardarPagosProvisionalesAnteriores(double valor) =>
      _guardar(pagosProvisionalesAnteriores: valor)
          .then((_) => guardarCampoSat('isr_pagos_provisionales_anteriores', valor));

  Future<void> guardarSaldoFavorIvaAnterior(double valor) =>
      _guardar(saldoFavorIvaAnterior: valor).then((_) => guardarCampoSat('iva_saldo_favor_anterior', valor));

  Future<void> guardarTipoDeclaracion(TipoDeclaracion valor) => _guardar(tipoDeclaracion: valor);

  Future<void> guardarCopropiedad(bool valor) => _guardar(copropiedad: valor);
}

final capturasEspejoControllerProvider = NotifierProvider<CapturasEspejoController, void>(
  CapturasEspejoController.new,
);
