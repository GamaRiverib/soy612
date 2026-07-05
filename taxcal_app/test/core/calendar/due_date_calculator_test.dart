import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/calendar/due_date_calculator.dart';

void main() {
  group('DueDateCalculator.diasHabilesExtraParaRfc', () {
    test('maps sixth RFC digit to extra business days', () {
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA01AAA'), 1);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA02AAA'), 1);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA03AAA'), 2);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA04AAA'), 2);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA05AAA'), 3);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA06AAA'), 3);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA07AAA'), 4);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA08AAA'), 4);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA09AAA'), 5);
      expect(DueDateCalculator.diasHabilesExtraParaRfc('AAAA00AAA'), 5);
    });

    test('throws for RFC too short', () {
      expect(() => DueDateCalculator.diasHabilesExtraParaRfc('AAA'), throwsArgumentError);
    });

    test('throws for non-numeric sixth character', () {
      expect(() => DueDateCalculator.diasHabilesExtraParaRfc('AAAAAX'), throwsArgumentError);
    });
  });

  group('DueDateCalculator.calcularVencimiento', () {
    test('June 2026 period, digit 1 -> skips weekend to Monday Jul 20', () {
      // Base: July 17, 2026 is a Friday. +1 business day skips Sat/Sun -> Jul 20.
      final result = DueDateCalculator.calcularVencimiento(
        anio: 2026,
        mesPeriodo: 6,
        rfc: 'AAAA01AAA',
      );
      expect(result, DateTime(2026, 7, 20));
    });

    test('June 2026 period, digit 0 -> +5 business days lands on Jul 24', () {
      final result = DueDateCalculator.calcularVencimiento(
        anio: 2026,
        mesPeriodo: 6,
        rfc: 'AAAA00AAA',
      );
      expect(result, DateTime(2026, 7, 24));
    });

    test('December period rolls into January of next year', () {
      // Base: Jan 17, 2026 is a Saturday. +2 business days -> Jan 19 (Mon), Jan 20 (Tue).
      final result = DueDateCalculator.calcularVencimiento(
        anio: 2025,
        mesPeriodo: 12,
        rfc: 'AAAA03AAA',
      );
      expect(result, DateTime(2026, 1, 20));
    });

    test('rejects mesPeriodo out of range', () {
      expect(
        () => DueDateCalculator.calcularVencimiento(anio: 2026, mesPeriodo: 0, rfc: 'AAAA01AAA'),
        throwsArgumentError,
      );
      expect(
        () => DueDateCalculator.calcularVencimiento(anio: 2026, mesPeriodo: 13, rfc: 'AAAA01AAA'),
        throwsArgumentError,
      );
    });
  });
}
