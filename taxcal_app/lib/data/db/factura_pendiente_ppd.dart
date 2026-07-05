import 'app_database.dart';

/// Vista combinada de una factura PPD pendiente con el nombre de su
/// contraparte, usada en el bottom sheet de recordatorios de conciliación
/// (README, sección "Recordatorios de conciliación PPD").
class FacturaPendientePpd {
  const FacturaPendientePpd({
    required this.factura,
    required this.contraparteRazonSocial,
  });

  final Factura factura;
  final String contraparteRazonSocial;

  int diasEnEspera(DateTime hoy) {
    final emision = DateTime(
      factura.fechaEmision.year,
      factura.fechaEmision.month,
      factura.fechaEmision.day,
    );
    final hoyNormalizado = DateTime(hoy.year, hoy.month, hoy.day);
    final dias = hoyNormalizado.difference(emision).inDays;
    return dias < 0 ? 0 : dias;
  }
}
