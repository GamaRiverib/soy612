import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';

/// Mes/año activos, compartidos entre Tablero y Facturas (README, sección
/// "State Management": "El selector de mes/año es compartido... cambiar de
/// mes recalcula reactivamente ambas pantallas").
class PeriodoActivo {
  const PeriodoActivo({required this.anio, required this.mes});

  final int anio;

  /// 1 = enero, 12 = diciembre.
  final int mes;

  PeriodoActivo copyWith({int? anio, int? mes}) =>
      PeriodoActivo(anio: anio ?? this.anio, mes: mes ?? this.mes);
}

class PeriodoActivoController extends AsyncNotifier<PeriodoActivo> {
  @override
  Future<PeriodoActivo> build() async {
    final prefs = await ref.watch(appPreferencesProvider.future);
    return PeriodoActivo(anio: prefs.anioActivo, mes: prefs.mesActivo);
  }

  Future<void> cambiarMes(int mes) async {
    final prefs = await ref.read(appPreferencesProvider.future);
    await prefs.guardarMesActivo(mes);
    final actual = state.value;
    if (actual != null) state = AsyncData(actual.copyWith(mes: mes));
  }

  Future<void> cambiarAnio(int anio) async {
    final prefs = await ref.read(appPreferencesProvider.future);
    await prefs.guardarAnioActivo(anio);
    final actual = state.value;
    if (actual != null) state = AsyncData(actual.copyWith(anio: anio));
  }
}

final periodoActivoProvider = AsyncNotifierProvider<PeriodoActivoController, PeriodoActivo>(
  PeriodoActivoController.new,
);
