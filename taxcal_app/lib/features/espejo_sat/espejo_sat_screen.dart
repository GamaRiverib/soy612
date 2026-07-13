import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/formatting/money_formatter.dart';
import '../../core/formatting/month_names.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/month_year_picker_sheet.dart';
import '../shared/periodo_activo_controller.dart';
import '../shared/segmented_tabs.dart';
import 'capturas_espejo_controller.dart';
import 'espejo_detalle_sheet.dart';
import 'espejo_providers.dart';

class EspejoSatScreen extends ConsumerWidget {
  const EspejoSatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoActivoProvider).value;
    final impuesto = ref.watch(espejoImpuestoProvider);
    final seccionId = ref.watch(espejoSeccionIdProvider);
    final datosAsync = ref.watch(espejoSatGuiadoProvider);

    return Scaffold(
      body: SafeArea(
        child: datosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Text(
              'No se pudo cargar el Espejo SAT: $error',
              style: AppTypography.sans(color: AppColors.errorNotDeductible),
            ),
          ),
          data: (datos) {
            final seccionesImpuesto =
                datos.secciones.where((s) => s.impuesto == impuesto).toList(growable: false);
            final seccion = seccionesImpuesto.firstWhere(
              (s) => s.id == seccionId,
              orElse: () => seccionesImpuesto.first,
            );

            return Column(
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
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.expand_more, size: 16, color: AppColors.textSecondaryMax),
                          ],
                        ),
                      ),
                      Text('Espejo SAT', style: AppTypography.screenTitle),
                      const SizedBox(height: 4),
                      Text(
                        'Guia de llenado no oficial para cotejar y capturar tu declaracion mensual.',
                        style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    14,
                    AppSpacing.screenHorizontal,
                    10,
                  ),
                  child: SegmentedTabs<EspejoImpuesto>(
                    selected: impuesto,
                    onChanged: (valor) {
                      ref.read(espejoImpuestoProvider.notifier).state = valor;
                      ref.read(espejoSeccionIdProvider.notifier).state =
                          valor == EspejoImpuesto.isr ? 'isr_ingresos' : 'iva_cargo';
                    },
                    items: const [
                      (EspejoImpuesto.isr, 'ISR'),
                      (EspejoImpuesto.iva, 'IVA'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final item = seccionesImpuesto[index];
                      final selected = item.id == seccion.id;
                      return ChoiceChip(
                        label: Text(item.titulo),
                        selected: selected,
                        onSelected: (_) => ref.read(espejoSeccionIdProvider.notifier).state = item.id,
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.accentPrimary,
                        labelStyle: AppTypography.sans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.accentPrimaryButtonText : AppColors.textSecondaryMax,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemCount: seccionesImpuesto.length,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      12,
                      AppSpacing.screenHorizontal,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ResumenCompacto(datos: datos, impuesto: impuesto),
                        const SizedBox(height: 12),
                        ...seccion.campos.map((campo) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CampoSatCard(campo: campo),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResumenCompacto extends StatelessWidget {
  const _ResumenCompacto({required this.datos, required this.impuesto});

  final EspejoSatGuiadoDatos datos;
  final EspejoImpuesto impuesto;

  @override
  Widget build(BuildContext context) {
    final filas = impuesto == EspejoImpuesto.isr
        ? [
            ('Ingresos anteriores', datos.resumen.ingresosAnteriores),
            ('Ingresos del periodo', datos.resumen.ingresosMes),
            ('Gastos anteriores', datos.resumen.gastosAnteriores),
            ('Gastos del periodo', datos.resumen.gastosMes),
            ('ISR retenido anterior', datos.resumen.isrRetenidoAnterior),
            ('ISR retenido del periodo', datos.resumen.isrRetenidoMes),
          ]
        : [
            ('IVA cobrado', datos.resumen.ivaCobrado),
            ('IVA acreditable', datos.resumen.ivaAcreditable),
            ('IVA retenido', datos.resumen.ivaRetenido),
            (
              datos.iva.impuestoNeto > 0 ? 'IVA a cargo' : 'IVA a favor',
              datos.iva.impuestoNeto.abs(),
            ),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        children: [
          for (final fila in filas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fila.$1,
                      style: AppTypography.sans(fontSize: 12.5, color: AppColors.textSecondaryMax),
                    ),
                  ),
                  Text(formatMoney(fila.$2), style: AppTypography.mono(fontSize: 13.5)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CampoSatCard extends ConsumerStatefulWidget {
  const _CampoSatCard({required this.campo});

  final CampoSat campo;

  @override
  ConsumerState<_CampoSatCard> createState() => _CampoSatCardState();
}

class _CampoSatCardState extends ConsumerState<_CampoSatCard> {
  late final TextEditingController _controller;
  Timer? _timer;
  bool _copiado = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.campo.valor == 0 ? '' : _numero(widget.campo.valor));
  }

  @override
  void didUpdateWidget(covariant _CampoSatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campo.id != widget.campo.id) {
      _controller.text = widget.campo.valor == 0 ? '' : _numero(widget.campo.valor);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _numero(widget.campo.valor)));
    if (!mounted) return;
    setState(() => _copiado = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final campo = widget.campo;
    final color = switch (campo.tipo) {
      CampoSatTipo.manual => AppColors.requiredFieldBorder,
      CampoSatTipo.ceroSugerido => AppColors.accentSecondaryText,
      CampoSatTipo.cotejo => AppColors.accentPrimaryText,
      CampoSatTipo.auto || CampoSatTipo.calculado => Colors.white.withValues(alpha: 0.16),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: color.withValues(alpha: campo.editable ? 0.8 : 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campo.label, style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(
                      _tipoLabel(campo),
                      style: AppTypography.helper.copyWith(color: color),
                    ),
                    if (campo.helper != null)
                      Text(
                        campo.helper!,
                        style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                      ),
                  ],
                ),
              ),
              if (campo.detalle != null)
                TextButton(
                  onPressed: () => _abrirDetalle(context, ref, campo.detalle!),
                  child: Text('Detalle', style: AppTypography.sans(fontSize: 11.5)),
                ),
            ],
          ),
          const SizedBox(height: 9),
          if (campo.opciones.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: campo.opcionSeleccionada,
              dropdownColor: AppColors.surface,
              decoration: _inputDecoration(),
              items: campo.opciones
                  .map((opcion) => DropdownMenuItem(value: opcion, child: Text(opcion)))
                  .toList(growable: false),
              onChanged: (valor) {
                if (valor != null) {
                  ref.read(capturasEspejoControllerProvider.notifier).guardarOpcionSat(campo.id, valor);
                }
              },
            )
          else
            Row(
              children: [
                if (campo.signo != null) ...[
                  SizedBox(
                    width: 20,
                    child: Text(campo.signo!, style: AppTypography.mono(color: AppColors.textSecondaryMin)),
                  ),
                ],
                Expanded(
                  child: campo.editable
                      ? TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                          style: AppTypography.mono(fontSize: 15),
                          decoration: _inputDecoration(hint: campo.tipo == CampoSatTipo.ceroSugerido ? '0' : '0.00'),
                          onChanged: (texto) => ref
                              .read(capturasEspejoControllerProvider.notifier)
                              .guardarCampoSat(campo.id, double.tryParse(texto) ?? 0),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _numeroVisible(campo.valor),
                            textAlign: TextAlign.right,
                            style: AppTypography.mono(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Copiar',
                  onPressed: _copiar,
                  icon: Icon(_copiado ? Icons.check : Icons.copy, size: 18),
                  color: _copiado ? AppColors.accentPrimaryText : AppColors.textSecondaryMax,
                ),
              ],
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String hint = '0.00'}) => InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: AppTypography.mono(fontSize: 15, color: AppColors.textSecondaryMin),
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
}

String _numero(double valor) {
  final fijo = valor.toStringAsFixed(2);
  return fijo.endsWith('.00') ? fijo.substring(0, fijo.length - 3) : fijo;
}

final _formatoNumero = NumberFormat.decimalPattern('es_MX');

String _numeroVisible(double valor) {
  final decimales = valor == valor.roundToDouble() ? 0 : 2;
  _formatoNumero.minimumFractionDigits = decimales;
  _formatoNumero.maximumFractionDigits = decimales;
  return _formatoNumero.format(valor);
}

String _tipoLabel(CampoSat campo) => switch (campo.tipo) {
      CampoSatTipo.cotejo => 'Cotejar contra SAT',
      CampoSatTipo.manual => 'Captura manual',
      CampoSatTipo.ceroSugerido => '0 sugerido si no aplica',
      CampoSatTipo.auto => 'Calculado por Soy612',
      CampoSatTipo.calculado => 'Resultado calculado',
    };

Future<void> _abrirDetalle(BuildContext context, WidgetRef ref, String detalle) async {
  final periodo = await ref.read(periodoActivoProvider.future);
  final inicioMes = DateTime(periodo.anio, periodo.mes);
  final finMes = DateTime(periodo.anio, periodo.mes + 1);
  final inicioAnio = DateTime(periodo.anio);

  if (!context.mounted) return;
  switch (detalle) {
    case 'ingresos_anteriores':
      showEspejoDetalleSheet(
        context,
        ref,
        categoria: 'ingresos',
        inicio: inicioAnio,
        finExclusivo: inicioMes,
      );
    case 'gastos_mes':
      showEspejoDetalleSheet(
        context,
        ref,
        categoria: 'gastos',
        inicio: inicioMes,
        finExclusivo: finMes,
      );
    case 'ingresos_mes':
    case 'iva_retenido':
    case 'isr_retenido':
      showEspejoDetalleSheet(
        context,
        ref,
        categoria: 'ingresos',
        inicio: inicioMes,
        finExclusivo: finMes,
      );
  }
}
