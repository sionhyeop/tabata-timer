import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/history_store.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';

/// Minutes per weekday, Monday–Sunday. Single series, so no legend: the
/// card title names it. Today is emphasized; tapping a day shows its value.
class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key, required this.stats, required this.today});

  final WeekStats stats;
  final DateTime today;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  int? _selected;

  int get _todayIndex => widget.stats.days.indexOf(dateOnly(widget.today));

  /// Label one bar only: the tapped day, else today, else the busiest day.
  int? get _labeled {
    final values = widget.stats.secondsPerDay;
    if (_selected != null) return _selected;
    final today = _todayIndex;
    if (today >= 0 && values[today] > 0) return today;
    final max = values.reduce(math.max);
    return max > 0 ? values.indexOf(max) : null;
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.stats.secondsPerDay;
    final maxValue = math.max(values.reduce(math.max), 60);
    final labeled = _labeled;
    final summary = [
      for (var i = 0; i < 7; i++)
        '${weekdayLabel(widget.stats.days[i])} ${formatMinutesLabel(values[i])}',
    ].join(', ');

    return Semantics(
      label: '요일별 운동 시간: $summary',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 132,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selected = _selected == i ? null : i),
                    child: _DayColumn(
                      label: weekdayLabel(widget.stats.days[i]),
                      value: values[i],
                      fraction: values[i] / maxValue,
                      isToday: i == _todayIndex,
                      isSelected: i == _selected,
                      showValue: i == labeled && values[i] > 0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.label,
    required this.value,
    required this.fraction,
    required this.isToday,
    required this.isSelected,
    required this.showValue,
  });

  final String label;
  final int value;
  final double fraction;
  final bool isToday;
  final bool isSelected;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final empty = value == 0;
    final palette = AppPalette.of(context);
    final color = isToday
        ? AppColors.accent
        : isSelected
        ? palette.textSecondary
        : palette.grayButton;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 18,
          child: showValue
              ? Text(
                  formatMinutesLabel(value),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFeatures: tabularFigures,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        // The plot takes whatever height the labels leave, so font metrics
        // that differ per platform can't overflow the column.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 16,
                // Empty days keep a short stub so the baseline reads as a row.
                height: empty ? 3 : math.max(6, constraints.maxHeight * fraction),
                decoration: BoxDecoration(
                  color: empty ? palette.surfaceHigh : color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
            color: isToday ? palette.textPrimary : palette.textSecondary,
          ),
        ),
      ],
    );
  }
}
