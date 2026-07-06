import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/onboarding_controller.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: Soy612App()));
}

/// Decide de forma reactiva entre el gate de Onboarding y la app principal
/// (go_router). Solo uno de los dos `MaterialApp` existe en el árbol en un
/// momento dado — el cambio ocurre una sola vez, al aceptar el aviso legal.
class Soy612App extends ConsumerWidget {
  const Soy612App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingStatusProvider);

    return onboarding.when(
      data: (aceptado) => aceptado ? _MainApp(theme: buildAppTheme()) : _OnboardingApp(theme: buildAppTheme()),
      loading: () => _LoadingApp(theme: buildAppTheme()),
      error: (error, stackTrace) => _ErrorApp(theme: buildAppTheme(), error: error),
    );
  }
}

class _MainApp extends StatelessWidget {
  const _MainApp({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Soy612',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: appRouter,
    );
  }
}

class _OnboardingApp extends StatelessWidget {
  const _OnboardingApp({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soy612',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const OnboardingScreen(),
    );
  }
}

class _LoadingApp extends StatelessWidget {
  const _LoadingApp({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class _ErrorApp extends StatelessWidget {
  const _ErrorApp({required this.theme, required this.error});

  final ThemeData theme;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: Center(child: Text('Ocurrió un error al iniciar Soy612: $error')),
      ),
    );
  }
}
