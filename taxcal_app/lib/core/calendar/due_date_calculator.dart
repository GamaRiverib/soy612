import 'mx_holidays.dart';

/// Calculador de vencimientos inteligentes (sección 6.2 de la especificación
/// funcional): el plazo oficial es el día 17 del mes posterior al periodo
/// declarado, extendido por días hábiles adicionales según el sexto dígito
/// numérico del RFC del contribuyente, saltando fines de semana y feriados.
class DueDateCalculator {
  const DueDateCalculator._();

  /// Días hábiles adicionales otorgados según el sexto dígito del [rfc].
  static int diasHabilesExtraParaRfc(String rfc) {
    final digito = _sextoDigito(rfc);
    return switch (digito) {
      1 || 2 => 1,
      3 || 4 => 2,
      5 || 6 => 3,
      7 || 8 => 4,
      9 || 0 => 5,
      _ => throw ArgumentError('Sexto dígito de RFC fuera de rango: $digito'),
    };
  }

  static int _sextoDigito(String rfc) {
    final limpio = rfc.trim().toUpperCase();
    if (limpio.length < 6) {
      throw ArgumentError('RFC demasiado corto para calcular vencimiento: $rfc');
    }
    final digito = int.tryParse(limpio[5]);
    if (digito == null) {
      throw ArgumentError('El sexto carácter del RFC no es numérico: $rfc');
    }
    return digito;
  }

  /// Calcula la fecha límite de pago de la declaración provisional del
  /// periodo [mesPeriodo] (1-12) de [anio] para el [rfc] dado.
  static DateTime calcularVencimiento({
    required int anio,
    required int mesPeriodo,
    required String rfc,
  }) {
    if (mesPeriodo < 1 || mesPeriodo > 12) {
      throw ArgumentError('mesPeriodo debe estar entre 1 y 12: $mesPeriodo');
    }

    final mesPosterior = mesPeriodo == 12 ? 1 : mesPeriodo + 1;
    final anioPosterior = mesPeriodo == 12 ? anio + 1 : anio;
    var fecha = DateTime(anioPosterior, mesPosterior, 17);

    final diasExtra = diasHabilesExtraParaRfc(rfc);
    var agregados = 0;
    while (agregados < diasExtra) {
      fecha = fecha.add(const Duration(days: 1));
      if (MxHolidays.isBusinessDay(fecha)) agregados++;
    }

    // Salvaguarda explícita del texto normativo: si el día resultante cae en
    // fin de semana o feriado, se traslada al siguiente día hábil.
    while (!MxHolidays.isBusinessDay(fecha)) {
      fecha = fecha.add(const Duration(days: 1));
    }

    return fecha;
  }
}
