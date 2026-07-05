import 'package:shared_preferences/shared_preferences.dart';

/// Configuración de un solo registro (perfil fiscal, mes/año activo,
/// aceptación del aviso legal). No amerita una tabla relacional en Drift —
/// ver README, sección "Persistencia" del paso de Onboarding.
class AppPreferences {
  AppPreferences(this._prefs);

  static Future<AppPreferences> create() async {
    return AppPreferences(await SharedPreferences.getInstance());
  }

  final SharedPreferences _prefs;

  static const _keyAvisoLegalAceptado = 'onboarding_aviso_legal_aceptado';
  static const _keyNombreContribuyente = 'perfil_nombre_contribuyente';
  static const _keyRfcContribuyente = 'perfil_rfc_contribuyente';
  static const _keyAnioActivo = 'ejercicio_anio_activo';
  static const _keyMesActivo = 'ejercicio_mes_activo';

  bool get avisoLegalAceptado => _prefs.getBool(_keyAvisoLegalAceptado) ?? false;

  Future<void> aceptarAvisoLegal() => _prefs.setBool(_keyAvisoLegalAceptado, true);

  String? get nombreContribuyente => _prefs.getString(_keyNombreContribuyente);

  Future<void> guardarNombreContribuyente(String nombre) =>
      _prefs.setString(_keyNombreContribuyente, nombre);

  String? get rfcContribuyente => _prefs.getString(_keyRfcContribuyente);

  Future<void> guardarRfcContribuyente(String rfc) =>
      _prefs.setString(_keyRfcContribuyente, rfc);

  /// Ejercicio fiscal activo (año). El prototipo lo fija en 2026; en
  /// producción el usuario puede cambiarlo (README, sección "State Management").
  int get anioActivo => _prefs.getInt(_keyAnioActivo) ?? DateTime.now().year;

  Future<void> guardarAnioActivo(int anio) => _prefs.setInt(_keyAnioActivo, anio);

  /// Mes activo (1-12), compartido entre Tablero y Facturas.
  int get mesActivo => _prefs.getInt(_keyMesActivo) ?? DateTime.now().month;

  Future<void> guardarMesActivo(int mes) => _prefs.setInt(_keyMesActivo, mes);

  /// Usado por "Borrar todos los datos" en Configuración: no purga el
  /// perfil/aceptación legal, solo el estado transitorio del ejercicio activo
  /// no aplica aquí (ver [AppDatabase.borrarTodosLosDatos] para las colecciones).
  Future<void> reiniciarSeleccionDeEjercicio() async {
    await _prefs.remove(_keyAnioActivo);
    await _prefs.remove(_keyMesActivo);
  }
}
