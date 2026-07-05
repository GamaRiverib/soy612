import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/month_names.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/periodo_activo_controller.dart';
import '../shared/segmented_tabs.dart';
import 'capturas_espejo_controller.dart';

/// Paso 1 — Configuración (README, sección "4. Espejo SAT"): periodo
/// (solo lectura), tipo de declaración Normal/Complementaria, pregunta de
/// copropiedad, tal como la formula el SAT.
class EspejoConfigStep extends ConsumerWidget {
  const EspejoConfigStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoActivoProvider).value;
    final capturaAsync = ref.watch(capturaEspejoActivaProvider);
    final controller = ref.read(capturasEspejoControllerProvider.notifier);

    return Column(
      spacing: 12,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                'Periodo de la declaración',
                style: AppTypography.sans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryMax,
                ),
              ),
              Text(
                periodo != null ? monthLabel(periodo.mes, periodo.anio) : '',
                style: AppTypography.mono(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        capturaAsync.when(
          data: (captura) => Column(
            spacing: 12,
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      'Tipo de declaración',
                      style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    SegmentedTabs<TipoDeclaracion>(
                      selected: captura.tipoDeclaracion,
                      onChanged: controller.guardarTipoDeclaracion,
                      activeBackground: AppColors.accentPrimary,
                      activeTextColor: AppColors.accentPrimaryButtonText,
                      borderRadius: 7,
                      items: const [
                        (TipoDeclaracion.normal, 'Normal'),
                        (TipoDeclaracion.complementaria, 'Complementaria'),
                      ],
                    ),
                  ],
                ),
              ),
              _Card(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 3,
                        children: [
                          Text(
                            '¿Tus ingresos fueron obtenidos en copropiedad?',
                            style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Así lo pregunta el SAT en este mismo paso.',
                            style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: captura.copropiedad,
                      onChanged: controller.guardarCopropiedad,
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Text(
            'No se pudo cargar la configuración: $error',
            style: AppTypography.sans(color: AppColors.errorNotDeductible),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: child,
    );
  }
}
