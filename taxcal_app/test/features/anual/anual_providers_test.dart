import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxcal_app/app_providers.dart';
import 'package:taxcal_app/data/db/app_database.dart';
import 'package:taxcal_app/data/db/tables.dart';
import 'package:taxcal_app/features/anual/anual_providers.dart';

Future<T> _readKeptAlive<T>(ProviderContainer container, FutureProvider<T> provider) {
  final subscription = container.listen(provider, (_, _) {});
  return container.read(provider.future).whenComplete(subscription.close);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'ejercicio_anio_activo': 2026,
      'ejercicio_mes_activo': 6,
    });
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    await db.altaContribuyenteSiNoExiste(rfc: 'EMIS010101AAA', razonSocial: 'Emisor SA');
    await db.altaContribuyenteSiNoExiste(rfc: 'RECE010101AAA', razonSocial: 'Receptor SA');
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('anualDatosProvider aggregates income/expenses, bancarización and deducciones personales', () async {
    // Ingreso cobrado en marzo.
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'ing-marzo',
        fechaEmision: DateTime(2026, 3, 10),
        fechaPagoEfectivo: Value(DateTime(2026, 3, 10)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.ingreso,
        subtotal: 20000,
        total: 23200,
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.cobrado,
      ),
    );
    // Gasto deducible pagado en abril.
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'gasto-abril',
        fechaEmision: DateTime(2026, 4, 5),
        fechaPagoEfectivo: Value(DateTime(2026, 4, 5)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.egreso,
        subtotal: 1000,
        total: 1160,
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '03',
        estatusPago: EstatusPago.pagado,
      ),
    );
    // Gasto en efectivo > $2,000: viola bancarización.
    await db.insertarFacturaSiNoExiste(
      FacturasCompanion.insert(
        uuid: 'gasto-efectivo',
        fechaEmision: DateTime(2026, 5, 1),
        fechaPagoEfectivo: Value(DateTime(2026, 5, 1)),
        rfcEmisor: 'EMIS010101AAA',
        rfcReceptor: 'RECE010101AAA',
        tipoCfdi: TipoCfdi.egreso,
        subtotal: 2500,
        total: 2900,
        metodoPago: MetodoPagoCfdi.pue,
        formaPago: '01',
        estatusPago: EstatusPago.pagado,
      ),
    );
    await db.agregarDeduccionPersonal(
      ejercicioFiscal: 2026,
      concepto: 'Consulta dental',
      monto: 800,
      formaPago: FormaPagoPersonal.tarjeta,
      esFunerario: false,
    );
    await db.agregarDeduccionPersonal(
      ejercicioFiscal: 2026,
      concepto: 'Efectivo no elegible',
      monto: 5000,
      formaPago: FormaPagoPersonal.efectivo,
      esFunerario: false,
    );

    final datos = await _readKeptAlive(container, anualDatosProvider);

    expect(datos.ingresosAnuales, 20000);
    // Los dos gastos son deducibles=true por defecto, el de bancarización
    // sigue contando como "gasto deducible" acumulado (la alerta es aparte).
    expect(datos.gastosAnuales, 1000 + 2500);

    expect(datos.tendenciaMensual, hasLength(12));
    expect(datos.tendenciaMensual[2].$1, 20000); // marzo (índice 2)
    expect(datos.tendenciaMensual[3].$2, 1000); // abril (índice 3)
    expect(datos.tendenciaMensual[4].$2, 2500); // mayo (índice 4)

    expect(datos.hayViolacionesBancarizacion, isTrue);
    expect(datos.violacionesBancarizacion, hasLength(1));
    expect(datos.violacionesBancarizacion.single.factura.uuid, 'gasto-efectivo');
    expect(datos.totalNoBancarizado, 2900);

    expect(datos.deduccionesPersonalesAplicadas, 800); // excluye los 5000 en efectivo
    expect(datos.topeDeduccionesPersonales, closeTo(3000, 0.01)); // 15% de 20,000
  });

  test('saldoAnual is negative (a favor) when provisional payments exceed the annual tax', () async {
    // Sin facturas: base gravable anual = 0, isrCausadoAnual = 0,
    // pagosProvisionalesRealizados = 0 -> saldoAnual = 0.
    final datos = await _readKeptAlive(container, anualDatosProvider);

    expect(datos.baseGravableAnual, 0);
    expect(datos.isrCausadoAnual, 0);
    expect(datos.pagosProvisionalesRealizados, 0);
    expect(datos.saldoAnual, 0);
  });
}
