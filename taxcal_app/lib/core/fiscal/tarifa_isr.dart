/// Un renglón (rango) de una tabla de tarifa progresiva del ISR
/// (Art. 96 LISR mensual o Art. 152 LISR anual).
class TarifaRenglon {
  const TarifaRenglon({
    required this.limiteInferior,
    required this.limiteSuperior,
    required this.cuotaFija,
    required this.tasaPorcentaje,
  });

  factory TarifaRenglon.fromJson(Map<String, dynamic> json) {
    final limiteSuperiorJson = json['limiteSuperior'];
    return TarifaRenglon(
      limiteInferior: (json['limiteInferior'] as num).toDouble(),
      limiteSuperior: limiteSuperiorJson == null
          ? double.infinity
          : (limiteSuperiorJson as num).toDouble(),
      cuotaFija: (json['cuotaFija'] as num).toDouble(),
      tasaPorcentaje: (json['tasa'] as num).toDouble(),
    );
  }

  final double limiteInferior;
  final double limiteSuperior;
  final double cuotaFija;

  /// Porcentaje sobre el excedente del límite inferior, ej. 21.36 significa 21.36%.
  final double tasaPorcentaje;

  bool contiene(double baseGravable) =>
      baseGravable >= limiteInferior && baseGravable <= limiteSuperior;

  /// Escala límites y cuota fija por [factor] (usado para acumular la tarifa
  /// mensual de enero según el mes activo del ejercicio: sección 5.1.4 de la
  /// especificación funcional).
  TarifaRenglon escalar(int factor) => TarifaRenglon(
    limiteInferior: limiteInferior * factor,
    limiteSuperior: limiteSuperior.isInfinite ? limiteSuperior : limiteSuperior * factor,
    cuotaFija: cuotaFija * factor,
    tasaPorcentaje: tasaPorcentaje,
  );
}

/// Tabla completa de tarifa progresiva para un ejercicio/periodicidad dado.
class TablaTarifaIsr {
  const TablaTarifaIsr({required this.anio, required this.renglones});

  factory TablaTarifaIsr.fromJson(Map<String, dynamic> json) => TablaTarifaIsr(
    anio: json['anio'] as int,
    renglones: (json['renglones'] as List)
        .map((e) => TarifaRenglon.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );

  final int anio;
  final List<TarifaRenglon> renglones;

  /// Ubica el renglón correspondiente a [baseGravable]. Lanza [StateError] si
  /// ningún renglón la cubre (no debería ocurrir: el último renglón llega a
  /// infinito y el primero inicia en 0.01; valores negativos no están
  /// cubiertos intencionalmente, ver [TablaTarifaIsr.renglonPara]).
  TarifaRenglon renglonPara(double baseGravable) {
    for (final renglon in renglones) {
      if (renglon.contiene(baseGravable)) return renglon;
    }
    throw StateError(
      'No hay renglón de tarifa ISR $anio para base gravable $baseGravable',
    );
  }
}

/// Tabla de valores de la Unidad de Medida y Actualización (UMA) vigentes
/// para un ejercicio fiscal.
class TablaUma {
  const TablaUma({
    required this.anio,
    required this.diario,
    required this.mensual,
    required this.anual,
  });

  factory TablaUma.fromJson(Map<String, dynamic> json) => TablaUma(
    anio: json['anio'] as int,
    diario: (json['diario'] as num).toDouble(),
    mensual: (json['mensual'] as num).toDouble(),
    anual: (json['anual'] as num).toDouble(),
  );

  final int anio;
  final double diario;
  final double mensual;
  final double anual;
}
