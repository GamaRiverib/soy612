import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app_providers.dart';
import '../../core/fiscal/bancarizacion.dart';
import '../../core/formatting/money_formatter.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/conciliacion_ppd_sheet.dart';
import '../shared/month_bell_header.dart';
import '../shared/periodo_activo_controller.dart';
import 'factura_detalle_sheet.dart';
import 'facturas_providers.dart';
import 'xml_import_sheet.dart';

/// Libro diario de CFDIs (README, sección "3. Facturas").
class FacturasScreen extends ConsumerWidget {
  const FacturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MonthBellHeader(),
            const _SegmentedFiltro(),
            const _Buscador(),
            const _ResumenFiltro(),
            const Expanded(child: _ListaFacturas()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showXmlImportSheet(context, ref),
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.accentPrimaryButtonText,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SegmentedFiltro extends ConsumerWidget {
  const _SegmentedFiltro();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(facturaFiltroProvider);

    Widget tab(String label, TipoCfdi valor) {
      final seleccionado = filtro == valor;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () => ref.read(facturaFiltroProvider.notifier).state = valor,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: seleccionado ? AppColors.background : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.sans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: seleccionado ? AppColors.textPrimary : AppColors.textSecondaryMax,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        16,
        AppSpacing.screenHorizontal,
        12,
      ),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 3,
        children: [tab('Ingresos', TipoCfdi.ingreso), tab('Gastos', TipoCfdi.egreso)],
      ),
    );
  }
}

class _Buscador extends ConsumerWidget {
  const _Buscador();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        14,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: AppColors.textSecondaryMax),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (texto) => ref.read(facturaSearchProvider.notifier).state = texto,
                style: AppTypography.sans(fontSize: 15),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Buscar por nombre o RFC',
                  hintStyle: AppTypography.sans(
                    fontSize: 15,
                    color: AppColors.textSecondaryMax,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenFiltro extends ConsumerWidget {
  const _ResumenFiltro();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumenAsync = ref.watch(resumenFiltroActivoProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        14,
      ),
      child: resumenAsync.when(
        data: (resumen) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              resumen.etiqueta,
              style: AppTypography.label.copyWith(color: AppColors.textSecondaryMin),
            ),
            Text(
              formatMoney(resumen.total),
              style: AppTypography.mono(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPrimaryText,
              ),
            ),
          ],
        ),
        loading: () => const SizedBox(height: 20),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}

class _ListaFacturas extends ConsumerWidget {
  const _ListaFacturas();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facturasAsync = ref.watch(facturasFiltradasProvider);
    final periodo = ref.watch(periodoActivoProvider).value;

    return facturasAsync.when(
      data: (facturas) {
        if (facturas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No encontramos facturas con ese criterio'
                '${periodo != null ? ' en ${_monthLabelEs(periodo.mes, periodo.anio)}' : ''}.',
                textAlign: TextAlign.center,
                style: AppTypography.sans(fontSize: 14, color: AppColors.textSecondaryMin),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            0,
            AppSpacing.screenHorizontal,
            24,
          ),
          itemCount: facturas.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
          itemBuilder: (context, index) => _FacturaCard(item: facturas[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'No se pudieron cargar las facturas: $error',
          style: AppTypography.sans(color: AppColors.errorNotDeductible),
        ),
      ),
    );
  }
}

String _monthLabelEs(int mes, int anio) {
  const nombres = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  return '${nombres[mes - 1]} $anio';
}

class _FacturaCard extends ConsumerWidget {
  const _FacturaCard({required this.item});

  final FacturaConContraparte item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factura = item.factura;
    final esIngreso = factura.tipoCfdi == TipoCfdi.ingreso;
    final cobradoLabel = esIngreso ? 'Cobrado' : 'Pagado';
    final pendienteLabel = esIngreso ? 'Pendiente de cobro' : 'Pendiente de pago';

    late final String badgeLabel;
    late final Color badgeBg;
    late final Color badgeColor;
    late final VoidCallback? onBadgeTap;

    if (factura.metodoPago == MetodoPagoCfdi.pue) {
      badgeLabel = '✓ $cobradoLabel';
      badgeBg = AppColors.accentPrimary.withValues(alpha: 0.14);
      badgeColor = AppColors.accentPrimaryText;
      onBadgeTap = null;
    } else if (factura.estatusPago == EstatusPago.pendiente) {
      badgeLabel = '$pendienteLabel ›';
      badgeBg = AppColors.accentSecondary.withValues(alpha: 0.16);
      badgeColor = AppColors.accentSecondaryText;
      onBadgeTap = () => showConciliacionPpdModal(
        context: context,
        ref: ref,
        uuid: factura.uuid,
        tipoCfdi: factura.tipoCfdi,
        contraparteRazonSocial: item.contraparteRazonSocial,
        total: factura.total,
      );
    } else {
      final fechaPago = factura.fechaPagoEfectivo != null
          ? DateFormat('yyyy-MM-dd').format(factura.fechaPagoEfectivo!)
          : '';
      badgeLabel = '✓ $cobradoLabel el $fechaPago';
      badgeBg = AppColors.accentPrimary.withValues(alpha: 0.14);
      badgeColor = AppColors.accentPrimaryText;
      onBadgeTap = null;
    }

    final violaBancarizacion = !esIngreso &&
        ReglaBancarizacion.violaBancarizacion(
          subtotal: factura.subtotal,
          formaPago: factura.formaPago,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: () => showFacturaDetalleModal(context: context, ref: ref, item: item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.contraparteRazonSocial,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyStrong,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.contraparteRfc} · Folio ${factura.folioInterno ?? factura.uuid.substring(0, 8)}',
                        style: AppTypography.monoSmall.copyWith(color: AppColors.textSecondaryMin),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatMoney(factura.total), style: AppTypography.amountMedium),
                    const SizedBox(height: 1),
                    Text(
                      DateFormat('yyyy-MM-dd').format(factura.fechaEmision),
                      style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Badge(label: badgeLabel, background: badgeBg, color: badgeColor, onTap: onBadgeTap),
                if (!esIngreso)
                  Row(
                    children: [
                      Text(
                        'Deducible',
                        style: AppTypography.sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryMax,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Switch's built-in thumb animation already runs at Flutter's
                      // default 200ms, matching the Manual de Branding rule.
                      Switch(
                        value: factura.esDeducible,
                        onChanged: (valor) => ref
                            .read(appDatabaseProvider)
                            .actualizarDeducible(uuid: factura.uuid, esDeducible: valor),
                      ),
                    ],
                  ),
              ],
            ),
            if (violaBancarizacion) const _AlertaBancarizacion(),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
        child: Text(
          label,
          style: AppTypography.sans(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }
}

class _AlertaBancarizacion extends StatelessWidget {
  const _AlertaBancarizacion();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.accentSecondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Pagaste en efectivo más de \$2,000. El SAT no permite deducir este gasto.',
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.accentSecondaryTextLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
