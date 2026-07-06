import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/month_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/month_year_picker_sheet.dart';
import '../shared/periodo_activo_controller.dart';
import '../shared/segmented_tabs.dart';
import 'espejo_config_step.dart';
import 'espejo_determinacion_step.dart';
import 'espejo_pago_step.dart';
import 'espejo_providers.dart';

/// Formulario que replica el orden exacto de campos del portal oficial del
/// SAT (README, sección "4. Espejo SAT"): stepper de 3 pasos dentro de la
/// estética oscura de Soy612.
class EspejoSatScreen extends ConsumerWidget {
  const EspejoSatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoActivoProvider).value;
    final step = ref.watch(espejoStepProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                6,
                AppSpacing.screenHorizontal,
                2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => showMonthYearPickerSheet(context, ref),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                        Icon(Icons.expand_more, size: 16, color: AppColors.textSecondaryMax),
                      ],
                    ),
                  ),
                  Text('Espejo SAT', style: AppTypography.screenTitle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                16,
                AppSpacing.screenHorizontal,
                14,
              ),
              child: SegmentedTabs<EspejoStep>(
                selected: step,
                onChanged: (valor) => ref.read(espejoStepProvider.notifier).state = valor,
                items: const [
                  (EspejoStep.config, '1  Config'),
                  (EspejoStep.determinacion, '2  Determinación'),
                  (EspejoStep.pago, '3  Pago'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  0,
                  AppSpacing.screenHorizontal,
                  28,
                ),
                child: switch (step) {
                  EspejoStep.config => const EspejoConfigStep(),
                  EspejoStep.determinacion => const EspejoDeterminacionStep(),
                  EspejoStep.pago => const EspejoPagoStep(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
