/// Resultado de la determinación definitiva de IVA del mes
/// (sección 5.2 de la especificación funcional). A diferencia del ISR, el
/// IVA se liquida de forma definitiva mes con mes, sin acumular ejercicios
/// anteriores.
class IvaResultado {
  const IvaResultado({
    required this.ivaCobrado,
    required this.ivaAcreditable,
    required this.impuestoNeto,
  });

  final double ivaCobrado;
  final double ivaAcreditable;

  /// Positivo = IVA a cargo del periodo. Negativo = saldo a favor del periodo.
  final double impuestoNeto;

  bool get esACargo => impuestoNeto > 0;
  bool get esSaldoAFavor => impuestoNeto < 0;
}

class IvaEngine {
  const IvaEngine._();

  /// [ivaCobrado] y [ivaAcreditable] son las sumas ya agregadas de
  /// `iva_trasladado` de facturas de ingreso (estatus COBRADO) y egreso
  /// (deducible y PAGADO) respectivamente, tasa 16%.
  static IvaResultado calcularDefinitivoMensual({
    required double ivaCobrado,
    required double ivaAcreditable,
    required double ivaRetenidoDelPeriodo,
    required double saldoAFavorPeriodosAnteriores,
  }) {
    final neto =
        ivaCobrado - ivaAcreditable - ivaRetenidoDelPeriodo - saldoAFavorPeriodosAnteriores;
    return IvaResultado(
      ivaCobrado: ivaCobrado,
      ivaAcreditable: ivaAcreditable,
      impuestoNeto: neto,
    );
  }
}
