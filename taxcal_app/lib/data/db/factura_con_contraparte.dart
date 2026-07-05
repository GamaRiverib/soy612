import 'app_database.dart';
import 'tables.dart';

/// Una factura junto con el nombre de su contraparte (receptor si es
/// ingreso, emisor si es egreso), para las tarjetas de la pantalla Facturas.
class FacturaConContraparte {
  const FacturaConContraparte({
    required this.factura,
    required this.contraparteRazonSocial,
  });

  final Factura factura;
  final String contraparteRazonSocial;

  String get contraparteRfc =>
      factura.tipoCfdi == TipoCfdi.ingreso ? factura.rfcReceptor : factura.rfcEmisor;
}
