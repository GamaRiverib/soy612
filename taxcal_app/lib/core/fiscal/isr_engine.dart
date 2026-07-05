import 'tarifa_isr.dart';
import 'tarifa_progresiva.dart';

/// Resultado del cálculo de ISR provisional mensual acumulado
/// (sección 5.1 de la especificación funcional).
class IsrProvisionalResultado {
  const IsrProvisionalResultado({
    required this.baseGravableAcumulada,
    required this.isrCausado,
    required this.isrACargo,
  });

  final double baseGravableAcumulada;
  final double isrCausado;

  /// Positivo = ISR a cargo del periodo. Negativo = saldo a favor.
  final double isrACargo;
}

class IsrEngine {
  const IsrEngine._();

  /// Calcula el ISR provisional mensual acumulado del ejercicio.
  ///
  /// [tarifaEneroMensual] debe ser la tabla mensual de enero del ejercicio
  /// activo; se escala por [mesActivo] (1 = enero, 12 = diciembre) siguiendo
  /// la mecánica oficial de acumulación mensual (sección 5.1.4).
  static IsrProvisionalResultado calcularProvisionalMensual({
    required double ingresosCobradosAcumulados,
    required double deduccionesAutorizadasAcumuladas,
    required double ptuPagada,
    required double perdidasFiscalesAnteriores,
    required TablaTarifaIsr tarifaEneroMensual,
    required int mesActivo,
    required double pagosProvisionalesAnteriores,
    required double isrRetenidoAcumulado,
  }) {
    if (mesActivo < 1 || mesActivo > 12) {
      throw ArgumentError('mesActivo debe estar entre 1 y 12: $mesActivo');
    }

    final baseGravable = ingresosCobradosAcumulados -
        deduccionesAutorizadasAcumuladas -
        ptuPagada -
        perdidasFiscalesAnteriores;

    final tarifaEscalada = TablaTarifaIsr(
      anio: tarifaEneroMensual.anio,
      renglones: tarifaEneroMensual.renglones
          .map((r) => r.escalar(mesActivo))
          .toList(growable: false),
    );

    final resultado = aplicarTarifaProgresiva(tarifaEscalada, baseGravable);
    final isrACargo =
        resultado.impuestoCausado - pagosProvisionalesAnteriores - isrRetenidoAcumulado;

    return IsrProvisionalResultado(
      baseGravableAcumulada: baseGravable,
      isrCausado: resultado.impuestoCausado,
      isrACargo: isrACargo,
    );
  }
}
