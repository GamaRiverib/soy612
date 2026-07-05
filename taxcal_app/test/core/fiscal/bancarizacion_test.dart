import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/fiscal/bancarizacion.dart';

void main() {
  group('ReglaBancarizacion.violaBancarizacion', () {
    test('flags cash expense over 2000', () {
      expect(
        ReglaBancarizacion.violaBancarizacion(subtotal: 2500, formaPago: '01'),
        isTrue,
      );
    });

    test('does not flag exactly 2000 (boundary is exclusive)', () {
      expect(
        ReglaBancarizacion.violaBancarizacion(subtotal: 2000, formaPago: '01'),
        isFalse,
      );
    });

    test('does not flag non-cash forma de pago regardless of amount', () {
      expect(
        ReglaBancarizacion.violaBancarizacion(subtotal: 50000, formaPago: '03'),
        isFalse,
      );
    });
  });
}
