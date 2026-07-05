import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/calendar/due_date_calculator.dart';
import '../../core/formatting/month_names.dart';
import '../../data/db/tables.dart';
import '../../data/prefs/app_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_typography.dart';
import '../shared/periodo_activo_controller.dart';

/// Perfil fiscal y mantenimiento de la base de datos local (README, sección
/// "6. Configuración").
class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(appPreferencesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                6,
                AppSpacing.screenHorizontal,
                2,
              ),
              child: Text('Configuración', style: AppTypography.screenTitle),
            ),
            Expanded(
              child: prefsAsync.when(
                data: (prefs) => _ConfiguracionBody(prefs: prefs),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'No se pudo cargar la configuración: $error',
                    style: AppTypography.sans(color: AppColors.errorNotDeductible),
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

class _ConfiguracionBody extends ConsumerStatefulWidget {
  const _ConfiguracionBody({required this.prefs});

  final AppPreferences prefs;

  @override
  ConsumerState<_ConfiguracionBody> createState() => _ConfiguracionBodyState();
}

class _ConfiguracionBodyState extends ConsumerState<_ConfiguracionBody> {
  late final TextEditingController _nombreController = TextEditingController(
    text: widget.prefs.nombreContribuyente ?? '',
  );
  late final TextEditingController _rfcController = TextEditingController(
    text: widget.prefs.rfcContribuyente ?? '',
  );
  bool _avisoAbierto = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  Future<void> _guardarNombre(String valor) async {
    await widget.prefs.guardarNombreContribuyente(valor);
    ref.invalidate(appPreferencesProvider);
  }

  Future<void> _guardarRfc(String valor) async {
    await widget.prefs.guardarRfcContribuyente(valor);
    ref.invalidate(appPreferencesProvider);
  }

  Future<void> _confirmarBorrado() async {
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
                '¿Borrar todos tus datos?',
                style: AppTypography.sans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                'Se eliminarán tus facturas, contribuyentes y deducciones guardadas en '
                'este dispositivo. Esta acción no se puede deshacer.',
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
                  'Sí, borrar todo',
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
      await ref.read(appDatabaseProvider).borrarTodosLosDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final rfc = _rfcController.text.trim().toUpperCase();
    final rfcValid = rfc.length == 12 || rfc.length == 13;
    final tipoPersona = rfc.length == 13
        ? 'Persona Física'
        : rfc.length == 12
        ? 'Persona Moral'
        : null;
    final rfcHelper = tipoPersona != null
        ? '$tipoPersona · ${rfc.length} caracteres'
        : 'Faltan ${(13 - rfc.length).clamp(0, 13)} caracteres para completar tu RFC.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        16,
        AppSpacing.screenHorizontal,
        28,
      ),
      children: [
        Text(
          'Perfil fiscal',
          style: AppTypography.sans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryMax,
          ),
        ),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre del contribuyente',
                    style: AppTypography.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryMax,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nombreController,
                    style: AppTypography.sans(fontSize: 14.5),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                    ),
                    onChanged: _guardarNombre,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RFC del contribuyente',
                    style: AppTypography.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryMax,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _rfcController,
                    maxLength: 13,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    style: AppTypography.mono(fontSize: 14.5, letterSpacing: 0.5),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: rfcValid
                            ? BorderSide(color: Colors.white.withValues(alpha: 0.12))
                            : const BorderSide(color: AppColors.requiredFieldBorder, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: rfcValid
                            ? BorderSide(color: Colors.white.withValues(alpha: 0.12))
                            : const BorderSide(color: AppColors.requiredFieldBorder, width: 1.5),
                      ),
                    ),
                    onChanged: (valor) {
                      setState(() {});
                      _guardarRfc(valor);
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rfcHelper,
                    style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        _PlazoLimiteCard(rfc: rfc),
        const SizedBox(height: 18),
        Text(
          'Base de datos local',
          style: AppTypography.sans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryMax,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: _ContadorCard(
                stream: db.watchContadorContribuyentes(),
                label: 'Contribuyentes',
              ),
            ),
            Expanded(
              child: _ContadorCard(
                stream: db.watchContadorFacturasPorTipo(TipoCfdi.ingreso),
                label: 'Ingresos',
              ),
            ),
            Expanded(
              child: _ContadorCard(
                stream: db.watchContadorFacturasPorTipo(TipoCfdi.egreso),
                label: 'Gastos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Acerca de TaxCal',
          style: AppTypography.sans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryMax,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _avisoAbierto = !_avisoAbierto),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'ⓘ Aviso legal ${_avisoAbierto ? '▴' : '▾'}',
              style: AppTypography.sans(fontSize: 12.5, color: AppColors.textSecondaryMax),
            ),
          ),
        ),
        if (_avisoAbierto)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
            child: Text(
              'Esta aplicación constituye únicamente una bitácora contable de uso '
              'privado y un simulador interactivo. Carece de conexión o autorización '
              'del SAT o la SHCP. La presentación legal de tus declaraciones es tu '
              'responsabilidad: siempre valida y transmite tus datos en el sitio '
              'oficial del SAT.',
              style: AppTypography.sans(
                fontSize: 12,
                color: AppColors.textSecondaryMin,
                height: 1.55,
              ),
            ),
          ),
        const SizedBox(height: 18),
        Text(
          'Zona de riesgo',
          style: AppTypography.sans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryMax,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _confirmarBorrado,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.requiredFieldBorder.withValues(alpha: 0.12),
              foregroundColor: AppColors.errorNotDeductible,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.requiredFieldBorder.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Borrar todos los datos',
              style: AppTypography.sans(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlazoLimiteCard extends ConsumerWidget {
  const _PlazoLimiteCard({required this.rfc});

  final String rfc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(periodoActivoProvider).value;
    DateTime? vencimiento;
    if (rfc.length >= 6 && periodo != null) {
      try {
        vencimiento = DueDateCalculator.calcularVencimiento(
          anio: periodo.anio,
          mesPeriodo: periodo.mes,
          rfc: rfc,
        );
      } on ArgumentError {
        vencimiento = null;
      }
    }

    return _Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu plazo límite de pago',
                  style: AppTypography.sans(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Según el sexto dígito de tu RFC. Se ajusta si cae en fin de semana o feriado.',
                  style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            vencimiento != null ? fechaCortaEs(vencimiento) : 'Captura tu RFC',
            textAlign: TextAlign.right,
            style: AppTypography.mono(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.accentSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContadorCard extends StatelessWidget {
  const _ContadorCard({required this.stream, required this.label});

  final Stream<int> stream;
  final String label;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                '${snapshot.data ?? 0}',
                style: AppTypography.mono(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.helper.copyWith(color: AppColors.textSecondaryMin),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(AppSpacing.cardPadding + 1),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: child,
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
