import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/xml/cfdi.dart';
import 'package:taxcal_app/core/xml/cfdi_parser.dart';

const _cfdiValidoPue = '''
<?xml version="1.0" encoding="UTF-8"?>
<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"
    Version="4.0" Folio="A100" Fecha="2026-06-15T12:00:00" SubTotal="1000.00" Total="1160.00"
    MetodoPago="PUE" FormaPago="03" TipoDeComprobante="I">
  <cfdi:Emisor Rfc="EMIS010101AA1" Nombre="Emisor de Prueba SA"/>
  <cfdi:Receptor Rfc="RECE010101AA2" Nombre="Receptor de Prueba SA"/>
  <cfdi:Impuestos TotalImpuestosTrasladados="160.00">
    <cfdi:Traslados>
      <cfdi:Traslado Impuesto="002" TasaOCuota="0.160000" Importe="160.00"/>
    </cfdi:Traslados>
  </cfdi:Impuestos>
  <cfdi:Complemento>
    <tfd:TimbreFiscalDigital UUID="AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"/>
  </cfdi:Complemento>
</cfdi:Comprobante>
''';

const _cfdiValidoPpdConRetenciones = '''
<?xml version="1.0" encoding="UTF-8"?>
<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"
    Version="4.0" Folio="B200" Fecha="2026-06-20T09:30:00" SubTotal="500.00" Total="546.00"
    MetodoPago="PPD" FormaPago="99" TipoDeComprobante="I">
  <cfdi:Emisor Rfc="EMIS020202BB1" Nombre="Servicios Profesionales SC"/>
  <cfdi:Receptor Rfc="RECE020202BB2" Nombre="Cliente Persona Moral SA"/>
  <cfdi:Impuestos TotalImpuestosTrasladados="80.00" TotalImpuestosRetenidos="34.00">
    <cfdi:Retenciones>
      <cfdi:Retencion Impuesto="001" Importe="50.00"/>
      <cfdi:Retencion Impuesto="002" Importe="53.33"/>
    </cfdi:Retenciones>
    <cfdi:Traslados>
      <cfdi:Traslado Impuesto="002" TasaOCuota="0.160000" Importe="80.00"/>
    </cfdi:Traslados>
  </cfdi:Impuestos>
  <cfdi:Complemento>
    <tfd:TimbreFiscalDigital UUID="11111111-2222-3333-4444-555555555555"/>
  </cfdi:Complemento>
</cfdi:Comprobante>
''';

const _cfdiSinTimbre = '''
<?xml version="1.0" encoding="UTF-8"?>
<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4"
    Version="4.0" Fecha="2026-06-15T12:00:00" SubTotal="1000.00" Total="1160.00"
    MetodoPago="PUE" FormaPago="03">
  <cfdi:Emisor Rfc="EMIS010101AA1" Nombre="Emisor de Prueba SA"/>
  <cfdi:Receptor Rfc="RECE010101AA2" Nombre="Receptor de Prueba SA"/>
</cfdi:Comprobante>
''';

void main() {
  group('parsearCfdi', () {
    test('extracts all fields from a PUE invoice', () {
      final resultado = parsearCfdi(_cfdiValidoPue);

      expect(resultado.uuid, 'AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE');
      expect(resultado.folio, 'A100');
      expect(resultado.fechaEmision, DateTime.parse('2026-06-15T12:00:00'));
      expect(resultado.metodoPago, 'PUE');
      expect(resultado.esPue, isTrue);
      expect(resultado.formaPago, '03');
      expect(resultado.subtotal, 1000.00);
      expect(resultado.total, 1160.00);
      expect(resultado.tasaIva, closeTo(16.0, 0.001));
      expect(resultado.ivaTrasladado, 160.00);
      expect(resultado.ivaRetenido, 0);
      expect(resultado.isrRetenido, 0);
      expect(resultado.emisorRfc, 'EMIS010101AA1');
      expect(resultado.emisorNombre, 'Emisor de Prueba SA');
      expect(resultado.receptorRfc, 'RECE010101AA2');
      expect(resultado.receptorNombre, 'Receptor de Prueba SA');
    });

    test('extracts ISR and IVA withholding for a PPD invoice', () {
      final resultado = parsearCfdi(_cfdiValidoPpdConRetenciones);

      expect(resultado.metodoPago, 'PPD');
      expect(resultado.esPue, isFalse);
      expect(resultado.ivaTrasladado, 80.00);
      expect(resultado.ivaRetenido, closeTo(53.33, 0.001));
      expect(resultado.isrRetenido, 50.00);
    });

    test('throws CfdiInvalidoException for a non-XML file', () {
      expect(() => parsearCfdi('esto no es xml'), throwsA(isA<CfdiInvalidoException>()));
    });

    test('throws CfdiInvalidoException when the UUID is missing', () {
      expect(() => parsearCfdi(_cfdiSinTimbre), throwsA(isA<CfdiInvalidoException>()));
    });

    test('throws CfdiInvalidoException for an empty string', () {
      expect(() => parsearCfdi(''), throwsA(isA<CfdiInvalidoException>()));
    });
  });
}
