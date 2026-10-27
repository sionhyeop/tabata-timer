import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/history_store.dart';
import '../../l10n/l10n.dart';
import '../../models/timer_mode.dart';
import '../../models/workout_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/mode_icon.dart';
import '../widgets/rpe.dart';
import 'weekly_chart.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppScope.of(context).history;
    final palette = AppPalette.of(context);
    final s = context.l10n;
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: history,
        builder: (context, _) {
          final now = DateTime.now();
          final records = history.records;
          final children = <Widget>[
            ScreenHeader(subtitle: s.historyTagline, title: s.tabHistory),
            _WeekCard(week: history.weekStats(now), streak: history.streak(now), today: now),
            SectionLabel(s.recentWorkouts),
          ];
          if (records.isEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  s.noHistory,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.textSecondary, height: 1.5),
                ),
              ),
            );
          }
          DateTime? lastDay;
          for (final record in records) {
            final day = dateOnly(record.startedAt);
            if (day != lastDay) {
              lastDay = day;
              children.add(
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: Text(
                    day == dateOnly(now) ? s.today : formatDateLabel(day, s.localeName),
                    style: TextStyle(color: palette.textSecondary, fontSize: 13),
                  ),
                ),
              );
            }
            children
              ..add(_RecordCard(record: record))
              ..add(const SizedBox(height: 10));
          }
          return ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: children);
        },
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.week, required this.streak, required this.today});

  final WeekStats week;
  final int streak;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.weekTime,
            style: TextStyle(color: AppPalette.of(context).textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMinutesLabel(s, week.totalSec),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFeatures: tabularFigures,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 12),
              // Longer wording (English) stacks the badges instead of
              // overflowing.
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Badge(text: s.workoutCount(week.count)),
                    _Badge(text: streak > 0 ? s.streakDays(streak) : s.streakNone),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeeklyBarChart(stats: week, today: today),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.of(context).surfaceHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final WorkoutRecord record;

  String _details(AppLocalizations s) {
    final r = record;
    final time = formatElapsedMs(r.activeMs);
    return switch (r.mode) {
      TimerMode.amrap => [time, s.rounds(r.amrapRounds), s.kcal(r.kcal)],
      TimerMode.forTime => [
        s.finishedIn(time),
        if (r.laps.isNotEmpty) s.laps(r.laps.length),
        s.kcal(r.kcal),
      ],
      _ => [time, s.rounds(r.workRounds), s.kcal(r.kcal)],
    }.join(' · ');
  }

  Future<void> _delete(BuildContext context) async {
    final history = AppScope.of(context).history;
    final s = context.l10n;
    final ok = await showConfirmDialog(context, title: s.deleteRecordTitle, confirmLabel: s.delete);
    if (ok) history.delete(record.id);
  }

  @override
  Widget build(BuildContext context) {
    final rpe = RpeLevel.of(record.rpe);
    final palette = AppPalette.of(context);
    final s = context.l10n;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
      onLongPress: () => _delete(context),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: palette.surfaceHigh, shape: BoxShape.circle),
            child: Icon(modeIcon(record.mode), color: palette.textPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        record.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (!record.completed) ...[
                      const SizedBox(width: 6),
                      Text(s.stopped, style: TextStyle(color: palette.textTertiary, fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _details(s),
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatTimeOfDay(record.startedAt, s.localeName),
                style: TextStyle(color: palette.textTertiary, fontSize: 12),
              ),
              if (rpe != null) ...[
                const SizedBox(height: 4),
                Tooltip(
                  message: s.rpeTooltip(rpe.label(s)),
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rpe.color.withValues(alpha: 0.22),
                      border: Border.all(color: rpe.color.withValues(alpha: 0.6), width: 1.5),
                    ),
                    child: Text(rpe.emoji, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
          PopupMenuButton<String>(
            tooltip: s.more,
            icon: Icon(Icons.more_vert, color: palette.textSecondary, size: 20),
            onSelected: (_) => _delete(context),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(s.delete, style: const TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
