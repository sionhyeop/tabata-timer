import 'package:flutter/material.dart';

import '../../engine/intensity.dart';
import '../../theme/app_colors.dart';

/// Perceived effort after a workout. Shares faces and colors with the
/// expected-intensity meter; only the wording is about how it felt.
class RpeLevel {
  const RpeLevel(this.intensity, this.label);

  final IntensityLevel intensity;
  final String label;

  int get value => intensity.value;
  String get emoji => intensity.emoji;
  Color get color => AppColors.intensityRamp[intensity.index];

  static RpeLevel? of(int? value) {
    for (final level in rpeLevels) {
      if (level.value == value) return level;
    }
    return null;
  }
}

const rpeLevels = [
  RpeLevel(IntensityLevel.light, '가벼워요'),
  RpeLevel(IntensityLevel.moderate, '적당해요'),
  RpeLevel(IntensityLevel.vigorous, '힘들어요'),
  RpeLevel(IntensityLevel.hard, '버거워요'),
  RpeLevel(IntensityLevel.extreme, '한계예요'),
];

/// Colored circle + caption, like the mood picker in the reference.
class RpeOption extends StatelessWidget {
  const RpeOption({
    super.key,
    required this.level,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final RpeLevel level;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: level.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: dimmed ? 0.4 : 1,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: level.color.withValues(alpha: selected ? 1 : 0.85),
                  border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(level.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 8),
              Text(
                level.label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
