import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Prosa/navegación (Geist Sans) vs. cifras/folios/RFC (Geist Mono).
/// Ver sección 3 del Manual de Branding.
abstract final class AppTypography {
  static TextStyle sans({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.geist(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static TextStyle mono({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.geistMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  // Tamaños usados (sección 3, Manual de Branding).
  static TextStyle get screenTitle => sans(fontSize: 30, fontWeight: FontWeight.w700);
  static TextStyle get amountLarge => mono(fontSize: 22, fontWeight: FontWeight.w700);
  static TextStyle get amountMedium => mono(fontSize: 17, fontWeight: FontWeight.w700);
  static TextStyle get body => sans(fontSize: 15, fontWeight: FontWeight.w500);
  static TextStyle get bodyStrong => sans(fontSize: 15.5, fontWeight: FontWeight.w600);
  static TextStyle get label => sans(fontSize: 12.5, fontWeight: FontWeight.w500);
  static TextStyle get helper => sans(fontSize: 10.5, fontWeight: FontWeight.w500);
  static TextStyle get monoSmall => mono(fontSize: 12, fontWeight: FontWeight.w500);
}
