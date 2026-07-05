import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app_providers.dart';
import '../../core/formatting/money_formatter.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';

/// Bottom sheet "Detalle" (README, sección "4. Espejo SAT"): lista las
/// facturas (folio, emisor/receptor, subtotal) que integran la suma exacta
/// de un campo auto-calculado, para auditar el prellenado.
void showEspejoDetalleSheet(
  BuildContext context,
  WidgetRef ref, {
  required String categoria, // 'ingresos' | 'gastos'
  required DateTime inicio,
  required DateTime finExclusivo,
}) {
  final tipo = categoria == 'ingresos' ? TipoCfdi.ingreso : TipoCfdi.egreso;
  final titulo = categoria == 'ingresos'
      ? 'Facturas que integran la suma'
      : 'Gastos que integran la suma';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.bottomSheet)),
    ),
    builder: (context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Text(titulo, style: AppTypography.sans(fontSize: 16, fontWeight: FontWeight.w700)),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final db = ref.watch(appDatabaseProvider);
                      return StreamBuilder(
                        stream: db.watchFacturasParaDetalle(
                          tipo: tipo,
                          inicio: inicio,
                          finExclusivo: finExclusivo,
                        ),
                        builder: (context, snapshot) {
                          final items = snapshot.data ?? const [];
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (items.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'Sin comprobantes acumulados todavía.',
                                textAlign: TextAlign.center,
                                style: AppTypography.sans(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryMin,
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final factura = item.factura;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.contraparteRazonSocial,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.sans(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Folio ${factura.folioInterno ?? factura.uuid.substring(0, 8)} · '
                                            '${DateFormat('yyyy-MM-dd').format(factura.fechaEmision)}',
                                            style: AppTypography.helper.copyWith(
                                              color: AppColors.textSecondaryMin,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(formatMoney(factura.total), style: AppTypography.amountMedium),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
