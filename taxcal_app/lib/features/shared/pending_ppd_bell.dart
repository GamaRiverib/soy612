import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'ppd_reminders_providers.dart';
import 'ppd_reminders_sheet.dart';

/// Campanita con badge (contador) en Tablero y Facturas (README, sección
/// "Recordatorios de conciliación PPD").
class PendingPpdBell extends ConsumerWidget {
  const PendingPpdBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contador = ref.watch(contadorPendientesPpdProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => showPpdRemindersSheet(context, ref),
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.textPrimary,
        ),
        if (contador > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.accentSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                '$contador',
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
