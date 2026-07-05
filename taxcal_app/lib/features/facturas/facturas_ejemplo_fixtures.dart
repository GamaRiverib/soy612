/// Las "3 facturas de ejemplo" del flujo de importación (README, sección
/// "Flujo de importación XML": "usar 3 facturas de ejemplo para probar sin
/// archivos reales"). Cubren los tres escenarios más representativos: un
/// ingreso PUE ya cobrado, un egreso PPD pendiente de pago, y un egreso PUE
/// pagado en efectivo por más de $2,000 (para disparar la alerta de
/// bancarización).
///
/// `{{RFC_PROPIO}}` se sustituye en tiempo de ejecución por el RFC
/// configurado del contribuyente, para que el ejemplo clasifique
/// correctamente sin importar qué RFC tenga configurado el usuario.
const String demoRfcPorDefecto = 'DEMO010101AA1';
const String demoNombrePorDefecto = 'Tu RFC de prueba';

const _fixtureIngresoPue = '''
<?xml version="1.0" encoding="UTF-8"?>
<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"
    Version="4.0" Folio="EJ-001" Fecha="2026-06-10T10:00:00" SubTotal="5000.00" Total="5800.00"
    MetodoPago="PUE" FormaPago="03" TipoDeComprobante="I">
  <cfdi:Emisor Rfc="{{RFC_PROPIO}}" Nombre="{{NOMBRE_PROPIO}}"/>
  <cfdi:Receptor Rfc="CLIE900101BB1" Nombre="Cliente Ejemplo SA de CV"/>
  <cfdi:Impuestos TotalImpuestosTrasladados="800.00">
    <cfdi:Traslados>
      <cfdi:Traslado Impuesto="002" TasaOCuota="0.160000" Importe="800.00"/>
    </cfdi:Traslados>
  </cfdi:Impuestos>
  <cfdi:Complemento>
    <tfd:TimbreFiscalDigital UUID="EJEMPLO01-0000-0000-0000-000000000001"/>
  </cfdi:Complemento>
</cfdi:Comprobante>
''';

const _fixtureEgresoPpdPendiente = '''
<?xml version="1.0" encoding="UTF-8"?>
<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"
    Version="4.0" Folio="EJ-002" Fecha="2026-06-18T16:30:00" SubTotal="1200.00" Total="1392.00"
    MetodoPago="PPD" FormaPago="99" TipoDeComprobante="I">
  <cfdi:Emisor Rfc="PROV850101CC2" Nombre="Proveedor de Servicios SC"/>
  <cfdi:Receptor Rfc="{{RFC_PROPIO}}" Nombre="{{NOMBRE_PROPIO}}"/>
  <cfdi:Impuestos TotalImpuestosTrasladados="192.00">
    <cfdi:Traslados>
      <cfdi:Traslado Impuesto="002" TasaOCuota="0.160000" Importe="192.00"/>
    </cfdi:Traslados>
  </cfdi:Impuestos>
  <cfdi:Complemento>
    <tfd:TimbreFiscalDigital UUID="EJEMPLO02-0000-0000-0000-000000000002"/>
  </cfdi:Complemento>
</cfdi:Comprobante>
''';

const _fixtureEgresoEfectivoBancarizacion = '''
<?xml version="1.0" encoding="UTF-8"?>
<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"
    Version="4.0" Folio="EJ-003" Fecha="2026-06-22T11:15:00" SubTotal="2500.00" Total="2900.00"
    MetodoPago="PUE" FormaPago="01" TipoDeComprobante="I">
  <cfdi:Emisor Rfc="PAPE770101DD3" Nombre="Papelería y Oficina SA"/>
  <cfdi:Receptor Rfc="{{RFC_PROPIO}}" Nombre="{{NOMBRE_PROPIO}}"/>
  <cfdi:Impuestos TotalImpuestosTrasladados="400.00">
    <cfdi:Traslados>
      <cfdi:Traslado Impuesto="002" TasaOCuota="0.160000" Importe="400.00"/>
    </cfdi:Traslados>
  </cfdi:Impuestos>
  <cfdi:Complemento>
    <tfd:TimbreFiscalDigital UUID="EJEMPLO03-0000-0000-0000-000000000003"/>
  </cfdi:Complemento>
</cfdi:Comprobante>
''';

/// Nombre de archivo sintético + contenido XML para cada una de las 3
/// facturas de ejemplo, con el RFC/nombre propio ya sustituido.
List<(String nombreArchivo, String contenidoXml)> generarFacturasDeEjemplo({
  required String rfcPropio,
  required String nombrePropio,
}) {
  String sustituir(String plantilla) => plantilla
      .replaceAll('{{RFC_PROPIO}}', rfcPropio)
      .replaceAll('{{NOMBRE_PROPIO}}', nombrePropio);

  return [
    ('ejemplo-ingreso-cobrado.xml', sustituir(_fixtureIngresoPue)),
    ('ejemplo-egreso-pendiente.xml', sustituir(_fixtureEgresoPpdPendiente)),
    ('ejemplo-egreso-efectivo.xml', sustituir(_fixtureEgresoEfectivoBancarizacion)),
  ];
}
