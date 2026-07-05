import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

const _mesesAbrev = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

/// Gráfico de barras de 12 meses (README, sección "5. Anual"): ingresos en
/// verde `#00CC44` vs. gastos en naranja `#FF6600`, escalado al valor máximo
/// del año, con un piso visual de 2px para valores > 0 (fiel al prototipo:
/// `Math.max(2, (monthlyValue / maxMonthly) * 84)`).
class TendenciaMensualChart extends StatelessWidget {
  const TendenciaMensualChart({super.key, required this.tendenciaMensual});

  final List<(double ingresos, double gastos)> tendenciaMensual;

  @override
  Widget build(BuildContext context) {
    final maximo = tendenciaMensual.fold<double>(
      0,
      (acumulado, mes) => [acumulado, mes.$1, mes.$2].reduce((a, b) => a > b ? a : b),
    );

    return SizedBox(
      height: 100,
      child: BarChart(
        BarChartData(
          maxY: maximo > 0 ? maximo : 1,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 5,
          barTouchData: const BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 16,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _mesesAbrev[value.toInt().clamp(0, 11)],
                    style: AppTypography.sans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryMin,
                    ),
                  ),
                ),
              ),
            ),
          ),
          barGroups: [
            for (var mes = 0; mes < tendenciaMensual.length; mes++)
              BarChartGroupData(
                x: mes,
                barsSpace: 2,
                barRods: [
                  BarChartRodData(
                    toY: tendenciaMensual[mes].$1,
                    color: AppColors.accentPrimary,
                    width: 6,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                  BarChartRodData(
                    toY: tendenciaMensual[mes].$2,
                    color: AppColors.accentSecondary,
                    width: 6,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
