import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/timer_mode.dart';
import '../../theme/app_colors.dart';

class ModeChips extends StatelessWidget {
  const ModeChips({super.key, required this.selected, required this.onChanged});

  final TimerMode selected;
  final ValueChanged<TimerMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Bleed to the screen edge so chips scroll under the gutter.
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: TimerMode.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final mode = TimerMode.values[i];
          final isSelected = mode == selected;
          return Material(
            color: isSelected ? palette.textPrimary : palette.surface,
            borderRadius: BorderRadius.circular(21),
            child: InkWell(
              borderRadius: BorderRadius.circular(21),
              onTap: () => onChanged(mode),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: Text(
                    mode.label(context.l10n),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? palette.bg : palette.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
