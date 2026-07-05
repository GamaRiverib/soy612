import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/month_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import 'month_year_picker_sheet.dart';
import 'pending_ppd_bell.dart';
import 'periodo_activo_controller.dart';

/// Header compartido entre Tablero y Facturas: chip de mes/año (abre bottom
/// sheet) + campanita de recordatorios PPD con badge.
class MonthBellHeader extends ConsumerWidget {
  const MonthBellHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoActivoProvider).value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        6,
        AppSpacing.screenHorizontal,
        2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => showMonthYearPickerSheet(context, ref),
            child: Row(
              children: [
                Text(
                  periodo != null ? monthLabel(periodo.mes, periodo.anio) : '',
                  style: AppTypography.sans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryMax,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.expand_more, size: 18, color: AppColors.textSecondaryMax),
              ],
            ),
          ),
          const PendingPpdBell(),
        ],
      ),
    );
  }
}
