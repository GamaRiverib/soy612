import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app_providers.dart';
import '../../core/formatting/money_formatter.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';

/// Detalle de una factura con opción de eliminarla (README, sección "3.
/// Facturas": tocar una tarjeta abre su detalle completo).
Future<void> showFacturaDetalleModal({
  required BuildContext context,
  required WidgetRef ref,
  required FacturaConContraparte item,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.bottomSheet)),
    ),
    builder: (sheetContext) => _FacturaDetalleContent(item: item),
  );
}

class _FacturaDetalleContent extends ConsumerWidget {
  const _FacturaDetalleContent({required this.item});

  final FacturaConContraparte item;

  Future<void> _confirmarEliminar(BuildContext context, WidgetRef ref) async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.modalScrim,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                '¿Eliminar esta factura?',
                style: AppTypography.sans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                'Se eliminará "${item.contraparteRazonSocial}" por ${formatMoney(item.factura.total)}. '
                'Esta acción no se puede deshacer.',
                style: AppTypography.sans(
                  fontSize: 13,
                  color: AppColors.textSecondaryMax,
                  height: 1.5,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.requiredFieldBorder,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Sí, eliminar',
                  style: AppTypography.sans(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryMax),
                child: Text('Cancelar', style: AppTypography.sans(fontSize: 13.5)),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmado == true) {
      await ref.read(appDatabaseProvider).eliminarFactura(item.factura.uuid);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factura = item.factura;
    final esIngreso = factura.tipoCfdi == TipoCfdi.ingreso;

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
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Text(
            item.contraparteRazonSocial,
            style: AppTypography.sans(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            item.contraparteRfc,
            style: AppTypography.monoSmall.copyWith(color: AppColors.textSecondaryMin),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _Fila('Subtotal', formatMoney(factura.subtotal)),
                _Fila('Tasa de IVA', '${factura.tasaIva.toStringAsFixed(0)}%'),
                _Fila('IVA trasladado', formatMoney(factura.ivaTrasladado)),
                if (factura.ivaRetenido > 0) _Fila('IVA retenido', formatMoney(factura.ivaRetenido)),
                if (factura.isrRetenido > 0) _Fila('ISR retenido', formatMoney(factura.isrRetenido)),
                _Fila('Total', formatMoney(factura.total), destacado: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _Fila('Folio', factura.folioInterno ?? factura.uuid),
                _Fila('Fecha de emisión', DateFormat('yyyy-MM-dd').format(factura.fechaEmision)),
                if (factura.fechaPagoEfectivo != null)
                  _Fila(
                    esIngreso ? 'Fecha de cobro' : 'Fecha de pago',
                    DateFormat('yyyy-MM-dd').format(factura.fechaPagoEfectivo!),
                  ),
                _Fila('Método de pago', factura.metodoPago == MetodoPagoCfdi.pue ? 'PUE' : 'PPD'),
                _Fila('Forma de pago', 'Clave SAT ${factura.formaPago}'),
                if (!esIngreso) _Fila('Deducible', factura.esDeducible ? 'Sí' : 'No'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _confirmarEliminar(context, ref),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.requiredFieldBorder.withValues(alpha: 0.12),
                foregroundColor: AppColors.errorNotDeductible,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.requiredFieldBorder.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Eliminar factura',
                style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.etiqueta, this.valor, {this.destacado = false});

  final String etiqueta;
  final String valor;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: AppTypography.sans(
              fontSize: 13,
              fontWeight: destacado ? FontWeight.w600 : FontWeight.w500,
              color: destacado ? AppColors.textPrimary : AppColors.textSecondaryMax,
            ),
          ),
          Text(
            valor,
            style: AppTypography.mono(
              fontSize: 13,
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
              color: destacado ? AppColors.accentPrimaryText : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
