import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/formatting/money_formatter.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';

/// Tarjeta base de un campo del Espejo SAT (README, sección "4. Espejo
/// SAT"): fondo `#2A2A2A`, radio 14, con label + helper opcional + botón
/// "Detalle" opcional.
class TarjetaCampo extends StatelessWidget {
  const TarjetaCampo({
    super.key,
    required this.label,
    this.helper,
    this.onDetalle,
    this.borderColor,
    required this.child,
  });

  final String label;
  final String? helper;
  final VoidCallback? onDetalle;
  final Color? borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
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
                    Text(
                      label,
                      style: AppTypography.sans(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    if (helper != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        helper!,
                        style: AppTypography.helper.copyWith(
                          color: AppColors.textSecondaryMin,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDetalle != null)
                TextButton(
                  onPressed: onDetalle,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                  child: Text(
                    'Detalle',
                    style: AppTypography.sans(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// Campo auto-calculado: fondo `#1A1A1A`, texto blanco 60% opacidad (Manual
/// de Branding, sección 6).
class CampoAuto extends StatelessWidget {
  const CampoAuto({
    super.key,
    required this.label,
    this.helper,
    this.onDetalle,
    required this.valorTexto,
    this.color = AppColors.textDisabled60,
    this.fontSize = 16,
  });

  final String label;
  final String? helper;
  final VoidCallback? onDetalle;
  final String valorTexto;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TarjetaCampo(
      label: label,
      helper: helper,
      onDetalle: onDetalle,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          valorTexto,
          style: AppTypography.mono(fontSize: fontSize, fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }
}

/// Campo de captura manual obligatoria: borde `#FF3333` 1.5px (Manual de
/// Branding, sección 6). Usa un [TextEditingController] inicializado una sola
/// vez para no perder el cursor en cada recálculo reactivo.
class CampoManual extends StatefulWidget {
  const CampoManual({
    super.key,
    required this.label,
    this.helper,
    required this.valorInicial,
    required this.onGuardar,
  });

  final String label;
  final String? helper;
  final double valorInicial;
  final ValueChanged<double> onGuardar;

  @override
  State<CampoManual> createState() => _CampoManualState();
}

class _CampoManualState extends State<CampoManual> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.valorInicial == 0 ? '' : _sinCerosInutiles(widget.valorInicial),
  );

  static String _sinCerosInutiles(double valor) {
    final texto = valor.toStringAsFixed(2);
    return texto.endsWith('.00') ? texto.substring(0, texto.length - 3) : texto;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TarjetaCampo(
      label: widget.label,
      helper: widget.helper,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Text(
              r'$',
              style: AppTypography.mono(fontSize: 15, color: AppColors.textSecondaryMin),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                style: AppTypography.mono(fontSize: 15),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: '0.00',
                  hintStyle: AppTypography.mono(fontSize: 15, color: AppColors.textSecondaryMin),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.requiredFieldBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.requiredFieldBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.requiredFieldBorder, width: 1.5),
                  ),
                ),
                onChanged: (texto) => widget.onGuardar(double.tryParse(texto) ?? 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo final auto-calculado (ISR a cargo / IVA neto): tipografía grande
/// mono, botón "Copiar" con feedback "¡Copiado!" (~1.5s).
class CampoFinal extends StatefulWidget {
  const CampoFinal({super.key, required this.label, required this.valor, required this.color});

  final String label;
  final double valor;
  final Color color;

  @override
  State<CampoFinal> createState() => _CampoFinalState();
}

class _CampoFinalState extends State<CampoFinal> {
  bool _copiado = false;
  Timer? _timer;

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: formatMoney(widget.valor)));
    if (!mounted) return;
    setState(() => _copiado = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TarjetaCampo(
      label: widget.label,
      borderColor: widget.color.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatMoney(widget.valor),
              style: AppTypography.mono(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
            TextButton(
              onPressed: _copiar,
              style: TextButton.styleFrom(
                backgroundColor: _copiado
                    ? AppColors.accentPrimary.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.08),
                foregroundColor: _copiado
                    ? AppColors.accentPrimaryText
                    : Colors.white.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _copiado ? '¡Copiado!' : 'Copiar',
                style: AppTypography.sans(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
