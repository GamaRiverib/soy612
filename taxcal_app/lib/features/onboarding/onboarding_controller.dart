import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';

/// Estado reactivo de aceptación del aviso legal bloqueante (sección 6.4 de
/// la especificación funcional). Se persiste en `shared_preferences` — ver
/// [AppPreferences.avisoLegalAceptado].
class OnboardingStatus extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(appPreferencesProvider.future);
    return prefs.avisoLegalAceptado;
  }

  Future<void> aceptar() async {
    final prefs = await ref.read(appPreferencesProvider.future);
    await prefs.aceptarAvisoLegal();
    state = const AsyncData(true);
  }
}

final onboardingStatusProvider = AsyncNotifierProvider<OnboardingStatus, bool>(
  OnboardingStatus.new,
);
