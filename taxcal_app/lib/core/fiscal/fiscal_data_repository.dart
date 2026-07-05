import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'tarifa_isr.dart';

/// Carga las tablas de tarifa ISR (mensual/anual) y UMA empaquetadas en
/// `assets/fiscal_data/`. Los años sin tabla bundleada usan la más cercana
/// disponible (más reciente si se pide un año futuro, más antigua si se pide
/// uno anterior a la primera tabla empaquetada).
///
/// Nota: el editor manual de tarifas para cuando el SAT publique una tabla
/// nueva antes de que la app se actualice queda fuera de alcance por ahora
/// (deuda técnica documentada en el plan de implementación).
class FiscalDataRepository {
  FiscalDataRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const _aniosTarifaMensual = [2021, 2022, 2023, 2024, 2025, 2026];
  static const _aniosTarifaAnual = [2026];
  static const _aniosUma = [2026];

  final Map<int, TablaTarifaIsr> _cacheMensual = {};
  final Map<int, TablaTarifaIsr> _cacheAnual = {};
  final Map<int, TablaUma> _cacheUma = {};

  Future<TablaTarifaIsr> tarifaMensual(int ejercicioFiscal) async {
    final anio = _anioDisponibleMasCercano(ejercicioFiscal, _aniosTarifaMensual);
    return _cacheMensual[anio] ??= await _cargarTabla(
      'assets/fiscal_data/isr_mensual_$anio.json',
      TablaTarifaIsr.fromJson,
    );
  }

  Future<TablaTarifaIsr> tarifaAnual(int ejercicioFiscal) async {
    final anio = _anioDisponibleMasCercano(ejercicioFiscal, _aniosTarifaAnual);
    return _cacheAnual[anio] ??= await _cargarTabla(
      'assets/fiscal_data/isr_anual_$anio.json',
      TablaTarifaIsr.fromJson,
    );
  }

  Future<TablaUma> uma(int ejercicioFiscal) async {
    final anio = _anioDisponibleMasCercano(ejercicioFiscal, _aniosUma);
    return _cacheUma[anio] ??= await _cargarTabla(
      'assets/fiscal_data/uma_$anio.json',
      TablaUma.fromJson,
    );
  }

  Future<T> _cargarTabla<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await _bundle.loadString(assetPath);
    return fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static int _anioDisponibleMasCercano(int solicitado, List<int> disponibles) {
    if (disponibles.contains(solicitado)) return solicitado;
    if (solicitado > disponibles.last) return disponibles.last;
    if (solicitado < disponibles.first) return disponibles.first;
    // Año dentro del rango pero sin tabla propia (no debería ocurrir con las
    // series actuales, que no tienen huecos) -> toma la más cercana hacia abajo.
    return disponibles.lastWhere((a) => a <= solicitado, orElse: () => disponibles.first);
  }
}
