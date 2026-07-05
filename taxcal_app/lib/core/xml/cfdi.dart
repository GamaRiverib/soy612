/// Datos extraídos de un CFDI 4.0 (sección 4 de la especificación funcional).
class CfdiParseado {
  const CfdiParseado({
    required this.uuid,
    required this.folio,
    required this.fechaEmision,
    required this.metodoPago,
    required this.formaPago,
    required this.subtotal,
    required this.total,
    required this.tasaIva,
    required this.ivaTrasladado,
    required this.ivaRetenido,
    required this.isrRetenido,
    required this.emisorRfc,
    required this.emisorNombre,
    required this.receptorRfc,
    required this.receptorNombre,
  });

  final String uuid;
  final String? folio;
  final DateTime fechaEmision;

  /// 'PUE' o 'PPD'.
  final String metodoPago;

  /// Código numérico SAT de forma de pago (01, 03, 04, etc.).
  final String formaPago;
  final double subtotal;
  final double total;
  final double tasaIva;
  final double ivaTrasladado;
  final double ivaRetenido;
  final double isrRetenido;
  final String emisorRfc;
  final String emisorNombre;
  final String receptorRfc;
  final String receptorNombre;

  bool get esPue => metodoPago == 'PUE';
}

/// Se lanza cuando un archivo no es un CFDI 4.0 válido o le faltan campos
/// obligatorios (sección "Pantalla de resumen" del README: "manejo de
/// errores si algún XML no es un CFDI válido").
class CfdiInvalidoException implements Exception {
  const CfdiInvalidoException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
