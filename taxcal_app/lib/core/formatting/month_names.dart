/// Nombres de mes en español, tal como en `MONTH_NAMES` del prototipo.
/// Índice 0 = enero.
const List<String> monthNamesEs = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

/// [mes] es 1-12.
String monthLabel(int mes, int anio) => '${monthNamesEs[mes - 1]} $anio';

/// Fecha larga en español, ej. "17 de julio de 2026" (README, sección
/// "4. Espejo SAT": "fecha límite estimada").
String fechaLargaEs(DateTime fecha) =>
    '${fecha.day} de ${monthNamesEs[fecha.month - 1].toLowerCase()} de ${fecha.year}';
