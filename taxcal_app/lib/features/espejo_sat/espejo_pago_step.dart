import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../app_providers.dart';
import '../../core/formatting/money_formatter.dart';
import '../../core/formatting/month_names.dart';
import '../../core/pdf/papel_trabajo_generator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/periodo_activo_controller.dart';
import 'espejo_providers.dart';

/// Paso 3 — Pago (README, sección "4. Espejo SAT"): resumen de ISR + IVA,
/// total a pagar, fecha límite estimada, aviso legal colapsable.
class EspejoPagoStep extends ConsumerStatefulWidget {
  const EspejoPagoStep({super.key});

  @override
  ConsumerState<EspejoPagoStep> createState() => _EspejoPagoStepState();
}

class _EspejoPagoStepState extends ConsumerState<EspejoPagoStep> {
  bool _avisoAbierto = false;
  bool _copiadoTotal = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copiarTotal(double total) async {
    await Clipboard.setData(ClipboardData(text: formatMoney(total)));
    if (!mounted) return;
    setState(() => _copiadoTotal = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copiadoTotal = false);
    });
  }

  Future<void> _generarPdf({
    required EspejoIsrDatos isr,
    required EspejoIvaDatos iva,
    required double totalAPagar,
    required DateTime? fechaLimite,
  }) async {
    final prefs = await ref.read(appPreferencesProvider.future);
    final periodo = await ref.read(periodoActivoProvider.future);

    final bytes = await PapelTrabajoGenerator.generar(
      nombreContribuyente: prefs.nombreContribuyente ?? 'Sin capturar',
      rfcContribuyente: prefs.rfcContribuyente ?? 'Sin capturar',
      periodoLabel: monthLabel(periodo.mes, periodo.anio),
      isr: isr,
      iva: iva,
      totalAPagar: totalAPagar,
      fechaLimiteLabel: fechaLimite != null
          ? fechaLargaEs(fechaLimite)
          : 'captura tu RFC en Configuración',
    );

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    final isrAsync = ref.watch(espejoIsrDatosProvider);
    final ivaAsync = ref.watch(espejoIvaDatosProvider);
    final fechaAsync = ref.watch(espejoFechaLimiteProvider);

    if (isrAsync.isLoading || ivaAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (isrAsync.hasError || ivaAsync.hasError) {
      return Text(
        'No se pudo calcular el resumen de pago: ${isrAsync.error ?? ivaAsync.error}',
        style: AppTypography.sans(color: AppColors.errorNotDeductible),
      );
    }

    final isr = isrAsync.requireValue;
    final iva = ivaAsync.requireValue;
    final isrACargoMostrado = isr.isrACargo < 0 ? 0.0 : isr.isrACargo;
    final ivaLabel = iva.esACargo ? 'a cargo' : 'a favor';
    final ivaColor = iva.esACargo ? AppColors.accentSecondaryText : AppColors.accentPrimaryText;
    final totalAPagar = isr.isrACargo + (iva.impuestoNeto > 0 ? iva.impuestoNeto : 0);
    final totalMostrado = totalAPagar < 0 ? 0.0 : totalAPagar;

    return Column(
      spacing: 12,
      children: [
        _ResumenCard(
          titulo: 'ISR a cargo',
          subtitulo: 'Determinación · Propio',
          valor: isrACargoMostrado,
          color: AppColors.accentSecondaryText,
        ),
        _ResumenCard(
          titulo: 'IVA $ivaLabel',
          subtitulo: 'Determinación · Definitivo',
          valor: iva.impuestoNeto.abs(),
          color: ivaColor,
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card + 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                'Total a pagar este periodo',
                style: AppTypography.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryMax,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatMoney(totalMostrado),
                    style: AppTypography.mono(fontSize: 27, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => _copiarTotal(totalMostrado),
                    style: TextButton.styleFrom(
                      backgroundColor: _copiadoTotal
                          ? AppColors.accentPrimary.withValues(alpha: 0.18)
                          : const Color(0xFF3A3A3A),
                      foregroundColor: _copiadoTotal
                          ? AppColors.accentPrimaryText
                          : AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _copiadoTotal ? '¡Copiado!' : 'Copiar',
                      style: AppTypography.sans(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              fechaAsync.when(
                data: (fecha) => Text(
                  fecha != null
                      ? 'Fecha límite estimada: ${fechaLargaEs(fecha)}'
                      : 'Fecha límite estimada: captura tu RFC en Configuración.',
                  style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _generarPdf(
            isr: isr,
            iva: iva,
            totalAPagar: totalMostrado,
            fechaLimite: fechaAsync.value,
          ),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('Generar papel de trabajo (PDF)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _avisoAbierto = !_avisoAbierto),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ⓘ Aviso legal ${_avisoAbierto ? '▴' : '▾'}',
              style: AppTypography.sans(fontSize: 12.5, color: AppColors.textSecondaryMin),
            ),
          ),
        ),
        if (_avisoAbierto)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Esta app es tu bitácora privada y un simulador interactivo para '
              'que veas tus números antes de ir al SAT. No tenemos nexos '
              'oficiales con el gobierno; tú debes capturar y transmitir tus '
              'datos directamente en el portal oficial.',
              style: AppTypography.sans(
                fontSize: 12,
                color: AppColors.textSecondaryMin,
                height: 1.55,
              ),
            ),
          ),
      ],
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard({
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.color,
  });

  final String titulo;
  final String subtitulo;
  final double valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 1),
              Text(
                subtitulo,
                style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
              ),
            ],
          ),
          Text(
            formatMoney(valor),
            style: AppTypography.mono(fontSize: 18, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
