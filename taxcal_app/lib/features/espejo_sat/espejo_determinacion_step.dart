import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/money_formatter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../shared/periodo_activo_controller.dart';
import '../shared/segmented_tabs.dart';
import 'capturas_espejo_controller.dart';
import 'espejo_detalle_sheet.dart';
import 'espejo_field_cards.dart';
import 'espejo_providers.dart';

/// Paso 2 — Determinación (README, sección "4. Espejo SAT"): sub-tabs ISR
/// Propio / IVA Definitivo, cada uno con sus tarjetas de campos.
class EspejoDeterminacionStep extends ConsumerWidget {
  const EspejoDeterminacionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtab = ref.watch(espejoSubtabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        SegmentedTabs<EspejoSubtab>(
          selected: subtab,
          onChanged: (valor) => ref.read(espejoSubtabProvider.notifier).state = valor,
          borderRadius: 8,
          fontSize: 13,
          padding: const EdgeInsets.symmetric(vertical: 8),
          items: const [
            (EspejoSubtab.isr, 'ISR Propio'),
            (EspejoSubtab.iva, 'IVA Definitivo'),
          ],
        ),
        switch (subtab) {
          EspejoSubtab.isr => const _IsrPropioTab(),
          EspejoSubtab.iva => const _IvaDefinitivoTab(),
        },
        Text(
          'Los campos con borde rojo requieren tu captura. Los grises se '
          'calculan solos con tus facturas.',
          textAlign: TextAlign.center,
          style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin, height: 1.5),
        ),
      ],
    );
  }
}

class _IsrPropioTab extends ConsumerWidget {
  const _IsrPropioTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosAsync = ref.watch(espejoIsrDatosProvider);
    final periodo = ref.watch(periodoActivoProvider).value;
    final controller = ref.read(capturasEspejoControllerProvider.notifier);

    return datosAsync.when(
      data: (datos) {
        final inicioAnio = periodo != null ? DateTime(periodo.anio) : DateTime(2026);
        final finMesActivo = periodo != null
            ? DateTime(periodo.anio, periodo.mes + 1)
            : DateTime(2026, 1);

        return Column(
          spacing: 12,
          children: [
            CampoAuto(
              label: 'Ingresos acumulados',
              helper: 'Suma de facturas cobradas de enero a la fecha.',
              onDetalle: () => showEspejoDetalleSheet(
                context,
                ref,
                categoria: 'ingresos',
                inicio: inicioAnio,
                finExclusivo: finMesActivo,
              ),
              valorTexto: _dinero(datos.ingresosAcumulados),
            ),
            CampoAuto(
              label: 'Deducciones acumuladas',
              helper: 'Suma de gastos deducibles pagados de enero a la fecha.',
              onDetalle: () => showEspejoDetalleSheet(
                context,
                ref,
                categoria: 'gastos',
                inicio: inicioAnio,
                finExclusivo: finMesActivo,
              ),
              valorTexto: _dinero(datos.deduccionesAcumuladas),
            ),
            CampoManual(
              label: 'PTU pagada en el ejercicio',
              helper: 'Requiere tu captura — no viene en tus CFDIs.',
              valorInicial: datos.ptuPagada,
              onGuardar: controller.guardarPtuPagada,
            ),
            CampoManual(
              label: 'Pérdidas fiscales de ejercicios anteriores',
              helper: 'Requiere tu captura.',
              valorInicial: datos.perdidasFiscales,
              onGuardar: controller.guardarPerdidasFiscales,
            ),
            const CampoAuto(
              label: 'Subsidio al empleo',
              helper: 'Dejamos este espacio en blanco a propósito: es un '
                  'truco para evitar un fallo conocido del portal del SAT si '
                  'no tienes empleados.',
              valorTexto: '(vacío a propósito)',
              color: AppColors.accentSecondaryText,
            ),
            CampoAuto(
              label: 'Base gravable acumulada',
              valorTexto: _dinero(datos.baseGravableAcumulada),
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
            CampoManual(
              label: 'Pagos provisionales de meses anteriores',
              helper: 'Requiere tu captura.',
              valorInicial: datos.pagosProvisionalesAnteriores,
              onGuardar: controller.guardarPagosProvisionalesAnteriores,
            ),
            CampoFinal(
              label: 'ISR a cargo del periodo',
              valor: datos.isrACargo,
              color: AppColors.accentSecondaryText,
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Text(
        'No se pudo calcular el ISR: $error',
        style: AppTypography.sans(color: AppColors.errorNotDeductible),
      ),
    );
  }
}

class _IvaDefinitivoTab extends ConsumerWidget {
  const _IvaDefinitivoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosAsync = ref.watch(espejoIvaDatosProvider);
    final periodo = ref.watch(periodoActivoProvider).value;
    final controller = ref.read(capturasEspejoControllerProvider.notifier);

    return datosAsync.when(
      data: (datos) {
        final inicioMes = periodo != null
            ? DateTime(periodo.anio, periodo.mes)
            : DateTime(2026, 1);
        final finMes = periodo != null
            ? DateTime(periodo.anio, periodo.mes + 1)
            : DateTime(2026, 2);

        return Column(
          spacing: 12,
          children: [
            CampoAuto(
              label: 'IVA cobrado (16%)',
              helper: 'De tus ingresos ya cobrados este mes.',
              onDetalle: () => showEspejoDetalleSheet(
                context,
                ref,
                categoria: 'ingresos',
                inicio: inicioMes,
                finExclusivo: finMes,
              ),
              valorTexto: _dinero(datos.ivaCobrado),
            ),
            CampoAuto(
              label: 'IVA acreditable (16%)',
              helper: 'De tus gastos deducibles ya pagados este mes.',
              onDetalle: () => showEspejoDetalleSheet(
                context,
                ref,
                categoria: 'gastos',
                inicio: inicioMes,
                finExclusivo: finMes,
              ),
              valorTexto: _dinero(datos.ivaAcreditable),
            ),
            CampoManual(
              label: 'Saldo a favor de periodos anteriores',
              helper: 'Si el SAT te debe IVA de un mes pasado, captúralo aquí.',
              valorInicial: datos.saldoFavorAnterior,
              onGuardar: controller.guardarSaldoFavorIvaAnterior,
            ),
            CampoFinal(
              label: datos.esACargo ? 'IVA a cargo del periodo' : 'Saldo a favor de IVA',
              valor: datos.impuestoNeto.abs(),
              color: datos.esACargo ? AppColors.accentSecondaryText : AppColors.accentPrimaryText,
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Text(
        'No se pudo calcular el IVA: $error',
        style: AppTypography.sans(color: AppColors.errorNotDeductible),
      ),
    );
  }
}

String _dinero(double valor) => formatMoney(valor < 0 ? 0.0 : valor);
