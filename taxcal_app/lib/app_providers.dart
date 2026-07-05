import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/fiscal/fiscal_data_repository.dart';
import 'data/db/app_database.dart';
import 'data/prefs/app_preferences.dart';

/// Instancia única de la base de datos local (Drift/SQLite). Se cierra
/// automáticamente cuando el provider se descarta (no debería ocurrir en la
/// vida de la app, pero es correcto hacerlo en tests).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final fiscalDataRepositoryProvider = Provider<FiscalDataRepository>((ref) {
  return FiscalDataRepository();
});

/// `shared_preferences` requiere inicialización async; se expone como
/// [FutureProvider] y las pantallas que lo necesiten antes de renderizar
/// (Onboarding, Tablero) esperan a que resuelva.
final appPreferencesProvider = FutureProvider<AppPreferences>((ref) {
  return AppPreferences.create();
});
