import 'package:flutter_test/flutter_test.dart';
import 'package:taxcal_app/core/fiscal/fiscal_data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FiscalDataRepository', () {
    late FiscalDataRepository repo;

    setUp(() {
      repo = FiscalDataRepository();
    });

    test('loads the 2026 monthly ISR table with 11 brackets', () async {
      final tabla = await repo.tarifaMensual(2026);
      expect(tabla.anio, 2026);
      expect(tabla.renglones, hasLength(11));
      expect(tabla.renglones.first.limiteInferior, 0.01);
      expect(tabla.renglones.first.limiteSuperior, 844.59);
      expect(tabla.renglones.last.limiteSuperior, double.infinity);
      expect(tabla.renglones.last.cuotaFija, 133488.54);
      expect(tabla.renglones.last.tasaPorcentaje, 35);
    });

    test('loads the 2021 monthly ISR table (earliest bundled year)', () async {
      final tabla = await repo.tarifaMensual(2021);
      expect(tabla.anio, 2021);
      expect(tabla.renglones.first.limiteSuperior, 644.58);
    });

    test('falls back to latest bundled year for a future request', () async {
      final tabla = await repo.tarifaMensual(2030);
      expect(tabla.anio, 2026);
    });

    test('falls back to earliest bundled year for a past request', () async {
      final tabla = await repo.tarifaMensual(2010);
      expect(tabla.anio, 2021);
    });

    test('loads the 2026 annual ISR table with 11 brackets', () async {
      final tabla = await repo.tarifaAnual(2026);
      expect(tabla.renglones, hasLength(11));
      expect(tabla.renglones.first.limiteSuperior, 10135.11);
      expect(tabla.renglones.last.cuotaFija, 1601862.46);
    });

    test('loads UMA 2026 values', () async {
      final uma = await repo.uma(2026);
      expect(uma.diario, 117.31);
      expect(uma.mensual, 3566.22);
      expect(uma.anual, 42794.64);
    });
  });
}
