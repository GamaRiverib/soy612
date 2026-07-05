import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'onboarding_controller.dart';

/// Bloquea el uso de la app hasta aceptar el aviso legal (README, sección
/// "1. Onboarding"; especificación funcional, sección 6.4). Copy tomado
/// textualmente de `TaxCal_Prototipo.html`.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _legalChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _step == 0 ? _buildIntro() : _buildAvisoLegal(),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/branding/icon.png', fit: BoxFit.cover),
        ),
        const SizedBox(height: 20),
        Text(
          'TaxCal',
          style: AppTypography.sans(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tu escudo de tranquilidad fiscal. Traducimos tus facturas a un '
          'lenguaje simple, sin subirlas nunca a internet: todo se queda en '
          'tu teléfono.',
          textAlign: TextAlign.center,
          style: AppTypography.sans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondaryMax,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.accentPrimaryButtonText,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            onPressed: () => setState(() => _step = 1),
            child: Text(
              'Siguiente',
              style: AppTypography.sans(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPrimaryButtonText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvisoLegal() {
    final aceptando = ref.watch(onboardingStatusProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Antes de empezar',
          style: AppTypography.sans(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Esta aplicación constituye únicamente una bitácora '
                          'contable de uso privado y un simulador interactivo '
                          'diseñado para facilitar la preparación visual de tus '
                          'datos fiscales.\n\n',
                    ),
                    const TextSpan(
                      text: 'La herramienta carece de conexión, API o autorización '
                          'formal por parte del Servicio de Administración '
                          'Tributaria (SAT) o la Secretaría de Hacienda y Crédito '
                          'Público (SHCP).\n\n',
                    ),
                    const TextSpan(
                      text: 'El cálculo de los impuestos simulados se realiza de '
                          'forma indicativa, basada en la interpretación de las '
                          'guías de llenado del SAT. La presentación legal de tus '
                          'declaraciones y el cumplimiento de tus obligaciones '
                          'tributarias recaen bajo tu estricta responsabilidad '
                          'personal: deberás ingresar, validar y transmitir '
                          'manualmente tus datos directamente en el sitio web '
                          'oficial del SAT para obtener tu acuse de recibo y línea '
                          'de captura válidos.',
                    ),
                  ],
                ),
                style: AppTypography.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDisabled60,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => setState(() => _legalChecked = !_legalChecked),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: _legalChecked ? AppColors.accentPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _legalChecked
                          ? AppColors.accentPrimary
                          : AppColors.surfaceElevatedBorder,
                      width: 1.5,
                    ),
                  ),
                  child: _legalChecked
                      ? const Icon(Icons.check, size: 14, color: AppColors.background)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'He leído y entiendo que TaxCal es un simulador privado, sin '
                    'relación oficial con el SAT.',
                    style: AppTypography.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  _legalChecked ? AppColors.accentPrimary : AppColors.toggleTrackOff,
              foregroundColor: _legalChecked
                  ? AppColors.accentPrimaryButtonText
                  : AppColors.textSecondaryMax,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            onPressed: _legalChecked && !aceptando
                ? () => ref.read(onboardingStatusProvider.notifier).aceptar()
                : null,
            child: Text(
              'Aceptar y continuar',
              style: AppTypography.sans(fontSize: 15.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
