import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';

/// Bolsa de deducciones personales del ejercicio (sección 5.3 de la
/// especificación funcional; Art. 151 LISR).
class DeduccionesPersonalesEngine {
  const DeduccionesPersonalesEngine._();

  /// Un gasto personal es elegible si no se pagó en efectivo, salvo que sea
  /// un gasto funerario (única excepción del Art. 151 a la regla de
  /// bancarización de deducciones personales).
  static bool esElegible({required FormaPagoPersonal formaPago, required bool esFunerario}) {
    return formaPago != FormaPagoPersonal.efectivo || esFunerario;
  }

  /// Límite global anual = mín(15% de los ingresos anuales, 5 UMA anual).
  static double topeGlobalAnual({required double ingresosAnuales, required double umaAnual}) {
    final quincePorCientoIngresos = ingresosAnuales * 0.15;
    final cincoUma = umaAnual * 5;
    return quincePorCientoIngresos < cincoUma ? quincePorCientoIngresos : cincoUma;
  }

  /// Suma de los montos elegibles, acotada al [tope] global.
  static double sumaAplicada({
    required List<DeduccionPersonal> deducciones,
    required double tope,
  }) {
    final sumaElegible = deducciones
        .where((d) => esElegible(formaPago: d.formaPago, esFunerario: d.esFunerario))
        .fold(0.0, (acumulado, d) => acumulado + d.monto);
    return sumaElegible < tope ? sumaElegible : tope;
  }
}
