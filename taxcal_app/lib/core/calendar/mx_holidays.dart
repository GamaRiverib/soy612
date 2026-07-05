/// Días feriados oficiales de México relevantes para el calendario financiero
/// (sección 6.2 de la especificación funcional). Se calculan algorítmicamente
/// por año, sin necesidad de una tabla de datos.
class MxHolidays {
  const MxHolidays._();

  static Set<DateTime> forYear(int year) {
    return {
      DateTime(year, 1, 1), // Año nuevo
      _nthWeekdayOfMonth(year, 2, DateTime.monday, 1), // Primer lunes de febrero
      _nthWeekdayOfMonth(year, 3, DateTime.monday, 3), // Tercer lunes de marzo
      DateTime(year, 5, 1), // Día del trabajo
      DateTime(year, 9, 16), // Día de la independencia
      _nthWeekdayOfMonth(year, 11, DateTime.monday, 3), // Tercer lunes de noviembre
      DateTime(year, 12, 25), // Navidad
    };
  }

  static bool isHoliday(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return forYear(date.year).any((h) => h.isAtSameMomentAs(normalized));
  }

  static bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  static bool isBusinessDay(DateTime date) => !isWeekend(date) && !isHoliday(date);

  static DateTime _nthWeekdayOfMonth(int year, int month, int weekday, int n) {
    var date = DateTime(year, month, 1);
    var count = 0;
    while (true) {
      if (date.weekday == weekday) {
        count++;
        if (count == n) return date;
      }
      date = date.add(const Duration(days: 1));
    }
  }
}
