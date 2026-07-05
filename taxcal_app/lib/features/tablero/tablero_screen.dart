import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/money_formatter.dart';
import '../../core/formatting/month_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/month_bell_header.dart';
import '../shared/periodo_activo_controller.dart';
import 'tablero_providers.dart';

/// Radiografía rápida de la salud fiscal del mes activo (README, sección
/// "2. Tablero (Dashboard)").
class TableroScreen extends ConsumerWidget {
  const TableroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MonthBellHeader(),
            Expanded(child: _TableroBody()),
          ],
        ),
      ),
    );
  }
}

class _TableroBody extends ConsumerWidget {
  const _TableroBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datosAsync = ref.watch(tableroDatosProvider);
    final periodo = ref.watch(periodoActivoProvider).value;

    return datosAsync.when(
      data: (datos) {
        if (!datos.hayComprobantesEnElMes) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                periodo != null
                    ? 'Aún no hay facturas registradas en ${monthLabel(periodo.mes, periodo.anio)}.'
                    : 'Aún no hay facturas registradas.',
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  fontSize: 14,
                  color: AppColors.textSecondaryMax,
                  height: 1.4,
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            10,
            AppSpacing.screenHorizontal,
            24,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    label: 'Ingresos cobrados',
                    valor: datos.ingresosCobrados,
                    valorColor: AppColors.accentPrimaryText,
                    contador: datos.contadorIngresos,
                  ),
                ),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: _KpiCard(
                    label: 'Gastos deducibles',
                    valor: datos.gastosDeducibles,
                    valorColor: AppColors.textPrimary,
                    contador: datos.contadorGastos,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.cardGap),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Utilidad del mes', style: AppTypography.bodyStrong),
                  const SizedBox(height: 2),
                  Text(
                    'Ingresos cobrados menos gastos deducibles',
                    style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(datos.utilidadDelMes),
                    style: AppTypography.mono(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: datos.utilidadDelMes >= 0
                          ? AppColors.accentPrimaryText
                          : const Color(0xFFFF6666),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Impuestos proyectados', style: AppTypography.bodyStrong),
            const SizedBox(height: AppSpacing.cardGap),
            _ImpuestoCard(
              titulo: 'ISR provisional',
              subtitulo: 'Estimado, acumulado del año',
              valor: datos.isr.isrACargo < 0 ? 0 : datos.isr.isrACargo,
              valorColor: AppColors.accentSecondaryText,
            ),
            const SizedBox(height: AppSpacing.cardGap),
            _ImpuestoCard(
              titulo: 'IVA definitivo',
              subtitulo: datos.iva.esACargo ? 'A cargo este mes' : 'Saldo a favor este mes',
              valor: datos.iva.impuestoNeto.abs(),
              valorColor: datos.iva.esACargo
                  ? AppColors.accentSecondaryText
                  : AppColors.accentPrimaryText,
            ),
            const SizedBox(height: 20),
            Text(
              'Cálculo simplificado para este prototipo. No sustituye al cálculo oficial del SAT.',
              textAlign: TextAlign.center,
              style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'No se pudo calcular el Tablero: $error',
          style: AppTypography.sans(color: AppColors.errorNotDeductible),
        ),
      ),
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
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: child,
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.valor,
    required this.valorColor,
    required this.contador,
  });

  final String label;
  final double valor;
  final Color valorColor;
  final int contador;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label.copyWith(color: AppColors.textSecondaryMax)),
          const SizedBox(height: 6),
          Text(
            formatMoney(valor),
            style: AppTypography.mono(fontSize: 17, fontWeight: FontWeight.w700, color: valorColor),
          ),
          const SizedBox(height: 4),
          Text(
            '$contador comprobante${contador == 1 ? '' : 's'}',
            style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
          ),
        ],
      ),
    );
  }
}

class _ImpuestoCard extends StatelessWidget {
  const _ImpuestoCard({
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.valorColor,
  });

  final String titulo;
  final String subtitulo;
  final double valor;
  final Color valorColor;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: AppTypography.bodyStrong.copyWith(fontSize: 14)),
              const SizedBox(height: 1),
              Text(
                subtitulo,
                style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
              ),
            ],
          ),
          Text(
            formatMoney(valor),
            style: AppTypography.mono(fontSize: 17, fontWeight: FontWeight.w700, color: valorColor),
          ),
        ],
      ),
    );
  }
}
