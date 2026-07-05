import 'package:xml/xml.dart';

import 'cfdi.dart';

/// Parsea el contenido de un CFDI 4.0. Es una función de nivel superior (top
/// level), sin dependencias de Flutter, para poder ejecutarse dentro de un
/// isolate vía `compute()` (sección 3 de la especificación técnica: "el
/// parseo... debe ejecutarse en procesos paralelos... mediante la API
/// `compute` de Dart").
CfdiParseado parsearCfdi(String xmlContent) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(xmlContent);
  } on XmlException {
    throw const CfdiInvalidoException('El archivo no es un XML válido.');
  }

  final comprobante = _primero(document.findAllElements('Comprobante', namespaceUri: '*'));
  if (comprobante == null) {
    throw const CfdiInvalidoException('No es un CFDI válido: falta el nodo Comprobante.');
  }

  final emisor = _primero(comprobante.findElements('Emisor', namespaceUri: '*'));
  final receptor = _primero(comprobante.findElements('Receptor', namespaceUri: '*'));
  if (emisor == null || receptor == null) {
    throw const CfdiInvalidoException('CFDI incompleto: falta el Emisor o el Receptor.');
  }

  final timbre = _primero(document.findAllElements('TimbreFiscalDigital', namespaceUri: '*'));
  final uuid = timbre?.getAttribute('UUID');
  if (uuid == null || uuid.isEmpty) {
    throw const CfdiInvalidoException(
      'CFDI sin timbrar: falta el UUID del Timbre Fiscal Digital.',
    );
  }

  final fechaTexto = comprobante.getAttribute('Fecha');
  final fecha = fechaTexto == null ? null : DateTime.tryParse(fechaTexto);
  if (fecha == null) {
    throw const CfdiInvalidoException('CFDI sin fecha de emisión válida.');
  }

  final emisorRfc = emisor.getAttribute('Rfc');
  final receptorRfc = receptor.getAttribute('Rfc');
  if (emisorRfc == null || emisorRfc.isEmpty || receptorRfc == null || receptorRfc.isEmpty) {
    throw const CfdiInvalidoException('CFDI incompleto: falta el RFC del Emisor o Receptor.');
  }

  var tasaIva = 16.0;
  var ivaTrasladado = 0.0;
  var ivaRetenido = 0.0;
  var isrRetenido = 0.0;

  final impuestos = _primero(comprobante.findElements('Impuestos', namespaceUri: '*'));
  if (impuestos != null) {
    for (final traslado in impuestos.findAllElements('Traslado', namespaceUri: '*')) {
      if (traslado.getAttribute('Impuesto') == '002') {
        ivaTrasladado += _numero(traslado.getAttribute('Importe'));
        final tasa = double.tryParse(traslado.getAttribute('TasaOCuota') ?? '');
        if (tasa != null) tasaIva = tasa * 100;
      }
    }
    for (final retencion in impuestos.findAllElements('Retencion', namespaceUri: '*')) {
      final importe = _numero(retencion.getAttribute('Importe'));
      switch (retencion.getAttribute('Impuesto')) {
        case '002':
          ivaRetenido += importe;
        case '001':
          isrRetenido += importe;
      }
    }
  }

  return CfdiParseado(
    uuid: uuid,
    folio: comprobante.getAttribute('Folio'),
    fechaEmision: fecha,
    metodoPago: comprobante.getAttribute('MetodoPago') ?? 'PUE',
    formaPago: comprobante.getAttribute('FormaPago') ?? '99',
    subtotal: _numero(comprobante.getAttribute('SubTotal')),
    total: _numero(comprobante.getAttribute('Total')),
    tasaIva: tasaIva,
    ivaTrasladado: ivaTrasladado,
    ivaRetenido: ivaRetenido,
    isrRetenido: isrRetenido,
    emisorRfc: emisorRfc,
    emisorNombre: emisor.getAttribute('Nombre') ?? emisorRfc,
    receptorRfc: receptorRfc,
    receptorNombre: receptor.getAttribute('Nombre') ?? receptorRfc,
  );
}

double _numero(String? valor) => double.tryParse(valor ?? '') ?? 0.0;

XmlElement? _primero(Iterable<XmlElement> elementos) =>
    elementos.isEmpty ? null : elementos.first;
