import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Segmented control genérico (usado por el stepper y los sub-tabs de
/// Espejo SAT, y el selector Normal/Complementaria).
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.activeBackground = const Color(0xFF3A3A3A),
    this.activeTextColor = AppColors.textPrimary,
    this.borderRadius = 9,
    this.fontSize = 12.5,
    this.padding = const EdgeInsets.symmetric(vertical: 9),
  });

  final List<(T value, String label)> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color activeBackground;
  final Color activeTextColor;
  final double borderRadius;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius + 3),
      ),
      child: Row(
        spacing: 3,
        children: [
          for (final (value, label) in items)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: () => onChanged(value),
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    color: value == selected ? activeBackground : Colors.transparent,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: AppTypography.sans(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: value == selected ? activeTextColor : AppColors.textSecondaryMax,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
