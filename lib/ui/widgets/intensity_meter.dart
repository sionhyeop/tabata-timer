import 'package:flutter/material.dart';

import '../../engine/intensity.dart';
import '../../theme/app_colors.dart';

/// Face + label + five rising bars, read like a signal meter.
class IntensityMeter extends StatelessWidget {
  const IntensityMeter({super.key, required this.level, this.compact = false});

  final IntensityLevel level;

  /// Smaller variant for list cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '예상 강도 ${level.label}, 5단계 중 ${level.value}단계',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              layoutBuilder: unclippedSwitcherLayout,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                child: child,
              ),
              child: Text(
                level.emoji,
                key: ValueKey(level),
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: compact ? 15 : 22, height: 1.25),
              ),
            ),
            SizedBox(width: compact ? 4 : 6),
            Text(
              level.label,
              style: TextStyle(
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w700,
                color: compact ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: compact ? 6 : 8),
            _Bars(level: level, compact: compact),
          ],
        ),
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.level, required this.compact});

  final IntensityLevel level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 4.0 : 6.0;
    final base = compact ? 5.0 : 7.0;
    final step = compact ? 2.5 : 3.5;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 5; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: EdgeInsets.only(right: i < 4 ? (compact ? 2 : 3) : 0),
            width: width,
            height: base + i * step,
            decoration: BoxDecoration(
              color: i < level.value
                  ? AppColors.intensityRamp[i]
                  : AppColors.grayButton.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

/// [AnimatedSwitcher] layout that lets children paint outside the box;
/// emoji glyphs are taller than their line height on some platforms.
Widget unclippedSwitcherLayout(Widget? current, List<Widget> previous) =>
    Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [...previous, ?current]);
