import 'tarifa_isr.dart';

/// Resultado de aplicar una tabla de tarifa progresiva a una base gravable.
class ResultadoTarifaProgresiva {
  const ResultadoTarifaProgresiva({
    required this.renglon,
    required this.excedente,
    required this.impuestoMarginal,
    required this.impuestoCausado,
  });

  final TarifaRenglon? renglon;
  final double excedente;
  final double impuestoMarginal;
  final double impuestoCausado;
}

/// Aplica la fórmula de tarifa progresiva (Art. 96 / Art. 152 LISR):
/// `Impuesto Causado = (Excedente del Límite Inferior * % Excedente) + Cuota Fija`.
///
/// Si [baseGravable] es cero o negativa (pérdida del periodo), el impuesto
/// causado es 0 — no existe un renglón para bases no positivas.
ResultadoTarifaProgresiva aplicarTarifaProgresiva(
  TablaTarifaIsr tabla,
  double baseGravable,
) {
  if (baseGravable <= 0) {
    return const ResultadoTarifaProgresiva(
      renglon: null,
      excedente: 0,
      impuestoMarginal: 0,
      impuestoCausado: 0,
    );
  }

  final renglon = tabla.renglonPara(baseGravable);
  final excedente = baseGravable - renglon.limiteInferior;
  final marginal = excedente * (renglon.tasaPorcentaje / 100);
  final causado = marginal + renglon.cuotaFija;

  return ResultadoTarifaProgresiva(
    renglon: renglon,
    excedente: excedente,
    impuestoMarginal: marginal,
    impuestoCausado: causado,
  );
}
