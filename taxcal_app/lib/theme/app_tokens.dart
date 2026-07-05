/// Radios y espaciado (sección "Design Tokens" del README / Manual de Branding).
abstract final class AppRadii {
  static const card = 15.0;
  static const input = 11.0;
  static const bottomSheet = 22.0;
  static const badge = 10.0;
  static const fab = 26.0;
  static const toggle = 12.5;
}

abstract final class AppSpacing {
  static const screenHorizontal = 20.0;
  static const cardGap = 12.0;
  static const cardPadding = 14.0;
}

/// Regla mandatoria del Manual de Branding, sección 6: toda transición de
/// switches/toggles debe ser 200ms lineal.
abstract final class AppMotion {
  static const toggleDuration = Duration(milliseconds: 200);
}
