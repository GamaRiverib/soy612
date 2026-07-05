/// Regla de bancarización de egresos en efectivo (sección 6.1 de la
/// especificación funcional): un egreso mayor a $2,000 MXN pagado con
/// FormaPago "01" (efectivo) no tiene deducibilidad legal para ISR/IVA.
class ReglaBancarizacion {
  const ReglaBancarizacion._();

  static const double montoMaximoEfectivo = 2000.0;
  static const String formaPagoEfectivo = '01';

  static bool violaBancarizacion({
    required double subtotal,
    required String formaPago,
  }) {
    return formaPago == formaPagoEfectivo && subtotal > montoMaximoEfectivo;
  }
}
