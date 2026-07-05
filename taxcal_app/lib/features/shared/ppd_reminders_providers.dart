import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../data/db/app_database.dart';

final _ingresosPendientesPpdProvider = StreamProvider.autoDispose<List<FacturaPendientePpd>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchIngresosPendientesPpdConContraparte();
});

final _egresosPendientesPpdProvider = StreamProvider.autoDispose<List<FacturaPendientePpd>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchEgresosPendientesPpdConContraparte();
});

/// Todas las facturas PPD pendientes (ingresos + egresos), ordenadas por
/// antigüedad (más antigua primero) — README, sección "Recordatorios de
/// conciliación PPD".
final facturasPendientesPpdProvider = Provider.autoDispose<AsyncValue<List<FacturaPendientePpd>>>((
  ref,
) {
  final ingresos = ref.watch(_ingresosPendientesPpdProvider);
  final egresos = ref.watch(_egresosPendientesPpdProvider);

  if (ingresos.isLoading || egresos.isLoading) {
    return const AsyncValue.loading();
  }
  if (ingresos.hasError) {
    return AsyncValue.error(ingresos.error!, ingresos.stackTrace ?? StackTrace.current);
  }
  if (egresos.hasError) {
    return AsyncValue.error(egresos.error!, egresos.stackTrace ?? StackTrace.current);
  }

  final combinadas = [...ingresos.requireValue, ...egresos.requireValue]
    ..sort((a, b) => a.factura.fechaEmision.compareTo(b.factura.fechaEmision));

  return AsyncValue.data(combinadas);
});

/// Contador para el badge de la campanita (Tablero y Facturas).
final contadorPendientesPpdProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(facturasPendientesPpdProvider).value?.length ?? 0;
});
