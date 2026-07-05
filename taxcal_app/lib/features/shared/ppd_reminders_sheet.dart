import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/money_formatter.dart';
import '../../data/db/factura_pendiente_ppd.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import 'conciliacion_ppd_sheet.dart';
import 'ppd_reminders_providers.dart';

/// Bottom sheet "Recordatorios de cobro y pago" (README, sección
/// "Recordatorios de conciliación PPD"): lista las facturas PPD pendientes
/// ordenadas por antigüedad, con color de urgencia según días de espera.
void showPpdRemindersSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.bottomSheet)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Recordatorios de cobro y pago',
                  style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final asyncPendientes = ref.watch(facturasPendientesPpdProvider);
                  return asyncPendientes.when(
                    data: (pendientes) {
                      if (pendientes.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                          child: _RecordatoriosVacio(),
                        );
                      }
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          itemCount: pendientes.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _RecordatorioTile(item: pendientes[index]);
                          },
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      child: Text(
                        'No se pudieron cargar los recordatorios: $error',
                        style: AppTypography.sans(color: AppColors.errorNotDeductible),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _RecordatoriosVacio extends StatelessWidget {
  const _RecordatoriosVacio();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('✅', style: TextStyle(fontSize: 30)),
        const SizedBox(height: 8),
        Text(
          'Sin recordatorios pendientes. ¡Vas al día!',
          textAlign: TextAlign.center,
          style: AppTypography.sans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondaryMax,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _RecordatorioTile extends ConsumerWidget {
  const _RecordatorioTile({required this.item});

  final FacturaPendientePpd item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = item.diasEnEspera(DateTime.now());
    final esIngreso = item.factura.tipoCfdi == TipoCfdi.ingreso;
    final tipoLabel = esIngreso ? 'Por cobrar' : 'Por pagar';
    final ageLabel = dias == 0 ? 'Emitida hoy' : 'Esperando hace $dias día${dias == 1 ? '' : 's'}';
    final ageColor = dias > 20
        ? AppColors.errorNotDeductible
        : dias > 7
        ? AppColors.accentSecondaryText
        : AppColors.textSecondaryMin;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.contraparteRazonSocial,
                  style: AppTypography.sans(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$tipoLabel · ${formatMoney(item.factura.total)}',
                  style: AppTypography.monoSmall.copyWith(color: AppColors.textSecondaryMax),
                ),
                const SizedBox(height: 2),
                Text(ageLabel, style: AppTypography.helper.copyWith(color: ageColor)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.accentPrimaryButtonText,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              showConciliacionPpdModal(
                context: context,
                ref: ref,
                uuid: item.factura.uuid,
                tipoCfdi: item.factura.tipoCfdi,
                contraparteRazonSocial: item.contraparteRazonSocial,
                total: item.factura.total,
              );
            },
            child: Text(
              'Conciliar ahora',
              style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
