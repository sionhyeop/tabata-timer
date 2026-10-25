import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Perceived effort scale shown after a workout.
class RpeLevel {
  const RpeLevel(this.value, this.emoji, this.label, this.color);

  final int value;
  final String emoji;
  final String label;
  final Color color;

  static RpeLevel? of(int? value) {
    for (final level in rpeLevels) {
      if (level.value == value) return level;
    }
    return null;
  }
}

const rpeLevels = [
  RpeLevel(1, '😌', '가벼워요', AppColors.rest),
  RpeLevel(2, '🙂', '적당해요', AppColors.setRest),
  RpeLevel(3, '😤', '힘들어요', AppColors.prepare),
  RpeLevel(4, '🥵', '버거워요', AppColors.accentOrange),
  RpeLevel(5, '🔥', '한계예요', AppColors.accent),
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
