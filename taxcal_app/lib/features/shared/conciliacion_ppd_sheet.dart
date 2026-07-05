import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app_providers.dart';
import '../../core/formatting/money_formatter.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';

/// Modal de conciliación PPD (README, sección "Modal de conciliación PPD";
/// especificación funcional, sección 2.2). Copy tomado del prototipo para el
/// caso de ingreso; la variante de egreso sigue el mismo tono.
Future<void> showConciliacionPpdModal({
  required BuildContext context,
  required WidgetRef ref,
  required String uuid,
  required TipoCfdi tipoCfdi,
  required String contraparteRazonSocial,
  required double total,
}) {
  final esIngreso = tipoCfdi == TipoCfdi.ingreso;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.bottomSheet)),
    ),
    builder: (sheetContext) {
      var fechaSeleccionada = DateTime.now();

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 22,
              bottom: MediaQuery.of(context).viewInsets.bottom + 34,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Text(
                  esIngreso ? '¿Ya te pagaron esta factura?' : '¿Ya pagaste esta factura?',
                  style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  esIngreso
                      ? 'Esta factura está guardada a la espera de que el dinero entre '
                            'a tu banco. Dinos cuándo te pagaron para sumarla a ese mes.'
                      : 'Esta factura está guardada a la espera de que el dinero salga '
                            'de tu banco. Dinos cuándo la pagaste para sumarla a ese mes.',
                  style: AppTypography.sans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryMax,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contraparteRazonSocial,
                        style: AppTypography.sans(fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatMoney(total),
                        style: AppTypography.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryMin,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  esIngreso ? 'Fecha en que recibiste el pago' : 'Fecha en que hiciste el pago',
                  style: AppTypography.sans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryMax,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.input),
                  onTap: () async {
                    final elegida = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (elegida != null) {
                      setState(() => fechaSeleccionada = elegida);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadii.input),
                      border: Border.all(color: AppColors.surfaceElevatedBorder),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(fechaSeleccionada),
                      style: AppTypography.sans(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: AppColors.accentPrimaryButtonText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () async {
                      final db = ref.read(appDatabaseProvider);
                      await db.conciliarPagoPpd(
                        uuid: uuid,
                        fechaPagoEfectivo: fechaSeleccionada,
                        tipoCfdi: tipoCfdi,
                      );
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                    child: Text(
                      'Sumar al mes correspondiente',
                      style: AppTypography.sans(fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
