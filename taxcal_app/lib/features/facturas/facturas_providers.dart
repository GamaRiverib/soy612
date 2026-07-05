import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../app_providers.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../shared/periodo_activo_controller.dart';
import '../tablero/tablero_providers.dart';

/// Segmented control Ingresos/Gastos (README, sección "3. Facturas").
final facturaFiltroProvider = StateProvider.autoDispose<TipoCfdi>((ref) => TipoCfdi.ingreso);

/// Texto libre del buscador ("Buscar por nombre o RFC").
final facturaSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final _facturasDelMesProvider = StreamProvider.autoDispose<List<FacturaConContraparte>>((ref) {
  final periodo = ref.watch(periodoActivoProvider);
  final filtro = ref.watch(facturaFiltroProvider);
  final db = ref.watch(appDatabaseProvider);

  return periodo.when(
    data: (p) => db.watchFacturasDelMesConContraparte(anio: p.anio, mes: p.mes, tipo: filtro),
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream<List<FacturaConContraparte>>.error(error, stackTrace),
  );
});

/// Lista final mostrada en la pantalla Facturas: del mes activo, del filtro
/// activo (Ingresos/Gastos), filtrada por el texto de búsqueda (nombre o RFC).
final facturasFiltradasProvider = Provider.autoDispose<AsyncValue<List<FacturaConContraparte>>>((
  ref,
) {
  final asyncFacturas = ref.watch(_facturasDelMesProvider);
  final query = ref.watch(facturaSearchProvider).trim().toLowerCase();

  if (query.isEmpty) return asyncFacturas;

  return asyncFacturas.whenData((lista) {
    return lista
        .where(
          (f) =>
              f.contraparteRazonSocial.toLowerCase().contains(query) ||
              f.contraparteRfc.toLowerCase().contains(query),
        )
        .toList(growable: false);
  });
});

/// Etiqueta y total del resumen del filtro activo (README: "resumen de total
/// del filtro activo"), reutilizando los mismos KPIs del Tablero.
class ResumenFiltroActivo {
  const ResumenFiltroActivo({required this.etiqueta, required this.total});

  final String etiqueta;
  final double total;
}

final resumenFiltroActivoProvider = Provider.autoDispose<AsyncValue<ResumenFiltroActivo>>((ref) {
  final filtro = ref.watch(facturaFiltroProvider);
  final esIngreso = filtro == TipoCfdi.ingreso;

  final asyncTotal = esIngreso
      ? ref.watch(ingresosCobradosDelMesProvider)
      : ref.watch(gastosDeduciblesDelMesProvider);

  return asyncTotal.whenData(
    (total) => ResumenFiltroActivo(
      etiqueta: esIngreso ? 'Ingresos cobrados este mes' : 'Gastos deducibles este mes',
      total: total,
    ),
  );
});
