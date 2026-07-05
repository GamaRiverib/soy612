import 'package:flutter/material.dart';

/// Design tokens from `docs/Manual de Branding y Sistema de Identidad Visual.md`.
abstract final class AppColors {
  static const background = Color(0xFF1A1A1A);
  static const surface = Color(0xFF2A2A2A);
  static const surfaceElevatedBorder = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondaryMin = Color(0x66FFFFFF); // rgba(255,255,255,0.4)
  static const textSecondaryMax = Color(0x8CFFFFFF); // rgba(255,255,255,0.55)
  static const textDisabled60 = Color(0x99FFFFFF); // rgba(255,255,255,0.6)

  static const accentPrimary = Color(0xFF00CC44); // positivo
  static const accentPrimaryText = Color(0xFF3DDC7A);
  static const accentPrimaryButtonText = Color(0xFF0D1A10); // texto sobre botones verdes

  static const accentSecondary = Color(0xFFFF6600); // alertas/interacción
  static const accentSecondaryText = Color(0xFFFF9142);
  static const accentSecondaryTextLight = Color(0xFFFFB27A);

  static const requiredFieldBorder = Color(0xFFFF3333); // captura obligatoria
  static const errorNotDeductible = Color(0xFFFF6B6B);

  static const toggleTrackOff = Color(0xFF3A3A3A);
  static const toggleTrackOn = accentPrimary;

  static const modalScrim = Color(0x8C000000); // rgba(0,0,0,0.55)
}
