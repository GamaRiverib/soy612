import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/month_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import 'periodo_activo_controller.dart';

/// Bottom sheet del selector de mes/año, compartido entre Tablero y Facturas
/// (README, sección "State Management": "El selector de mes/año es
/// compartido... cambiar de mes recalcula reactivamente ambas pantallas").
void showMonthYearPickerSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.bottomSheet)),
    ),
    builder: (context) {
      return const SafeArea(
        child: Padding(padding: EdgeInsets.symmetric(vertical: 22), child: _MonthYearPickerBody()),
      );
    },
  );
}

class _MonthYearPickerBody extends ConsumerWidget {
  const _MonthYearPickerBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodoAsync = ref.watch(periodoActivoProvider);
    final periodo = periodoAsync.value;
    if (periodo == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final controller = ref.read(periodoActivoProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => controller.cambiarAnio(periodo.anio - 1),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${periodo.anio}',
              style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: () => controller.cambiarAnio(periodo.anio + 1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(12, (index) {
              final mes = index + 1;
              final seleccionado = mes == periodo.mes;
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadii.input),
                onTap: () {
                  controller.cambiarMes(mes);
                  Navigator.of(context).pop();
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: seleccionado ? AppColors.accentPrimary : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadii.input),
                  ),
                  child: Text(
                    monthNamesEs[index],
                    style: AppTypography.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: seleccionado
                          ? AppColors.accentPrimaryButtonText
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
