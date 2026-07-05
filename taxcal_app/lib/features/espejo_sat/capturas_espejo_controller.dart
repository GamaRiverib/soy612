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

  Future<void> guardarPtuPagada(double valor) => _guardar(ptuPagada: valor);

  Future<void> guardarPerdidasFiscales(double valor) => _guardar(perdidasFiscales: valor);

  Future<void> guardarPagosProvisionalesAnteriores(double valor) =>
      _guardar(pagosProvisionalesAnteriores: valor);

  Future<void> guardarSaldoFavorIvaAnterior(double valor) =>
      _guardar(saldoFavorIvaAnterior: valor);

  Future<void> guardarTipoDeclaracion(TipoDeclaracion valor) => _guardar(tipoDeclaracion: valor);

  Future<void> guardarCopropiedad(bool valor) => _guardar(copropiedad: valor);
}

final capturasEspejoControllerProvider = NotifierProvider<CapturasEspejoController, void>(
  CapturasEspejoController.new,
);
