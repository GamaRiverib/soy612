import 'package:intl/intl.dart';

final _formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: r'$', decimalDigits: 2);

/// Formatea un monto como `$1,160.00`, igual que el prototipo (`fmt.format`).
String formatMoney(num monto) => _formatoMoneda.format(monto);
