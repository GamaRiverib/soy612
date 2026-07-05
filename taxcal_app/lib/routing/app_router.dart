import 'package:go_router/go_router.dart';

import '../features/anual/anual_screen.dart';
import '../features/configuracion/configuracion_screen.dart';
import '../features/espejo_sat/espejo_sat_screen.dart';
import '../features/facturas/facturas_screen.dart';
import '../features/tablero/tablero_screen.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/tablero',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/tablero', builder: (context, state) => const TableroScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/facturas', builder: (context, state) => const FacturasScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/espejo-sat', builder: (context, state) => const EspejoSatScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/anual', builder: (context, state) => const AnualScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/configuracion', builder: (context, state) => const ConfiguracionScreen()),
        ]),
      ],
    ),
  ],
);
