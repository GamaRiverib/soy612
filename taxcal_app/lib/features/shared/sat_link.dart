import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';

/// Abre el portal oficial del SAT en el navegador del sistema. No requiere
/// permiso INTERNET de la app: el intent lo resuelve el navegador.
Future<void> abrirPortalSat() =>
    launchUrl(Uri.parse('https://www.sat.gob.mx'), mode: LaunchMode.externalApplication);

/// [TextSpan] tocable que abre sat.gob.mx, para insertar dentro de avisos
/// legales (política de afirmaciones engañosas de Play Store: la fuente
/// gubernamental debe estar enlazada, no solo mencionada como texto).
TextSpan satLinkSpan(String texto, {required TextStyle style}) => TextSpan(
  text: texto,
  style: style.copyWith(
    color: AppColors.accentPrimaryText,
    decoration: TextDecoration.underline,
  ),
  recognizer: TapGestureRecognizer()..onTap = abrirPortalSat,
);
