import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../data/history_store.dart';
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
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: history,
        builder: (context, _) {
          final now = DateTime.now();
          final records = history.records;
          final children = <Widget>[
            const ScreenHeader(subtitle: '꾸준함이 실력이에요', title: '기록'),
            _WeekCard(week: history.weekStats(now), streak: history.streak(now), today: now),
            const SectionLabel('최근 운동'),
          ];
          if (records.isEmpty) {
            children.add(
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  '아직 기록이 없어요.\n첫 운동을 시작해 보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
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
                    day == dateOnly(now) ? '오늘' : formatDateLabel(day),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이번 주 운동 시간', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMinutesLabel(week.totalSec),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFeatures: tabularFigures,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              _Badge(text: '${week.count}회'),
              const SizedBox(width: 6),
              _Badge(text: streak > 0 ? '🔥 $streak일 연속' : '🔥 0일'),
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
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final WorkoutRecord record;

  String get _details {
    final r = record;
    final time = formatElapsedMs(r.activeMs);
    return switch (r.mode) {
      TimerMode.amrap => '$time · ${r.amrapRounds}라운드 · ${r.kcal}kcal',
      TimerMode.forTime =>
        '완료 $time${r.laps.isNotEmpty ? ' · 랩 ${r.laps.length}' : ''} · ${r.kcal}kcal',
      _ => '$time · ${r.workRounds}라운드 · ${r.kcal}kcal',
    };
  }

  Future<void> _delete(BuildContext context) async {
    final history = AppScope.of(context).history;
    final ok = await showConfirmDialog(context, title: '기록을 삭제할까요?', confirmLabel: '삭제');
    if (ok) history.delete(record.id);
  }

  @override
  Widget build(BuildContext context) {
    final rpe = RpeLevel.of(record.rpe);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
      onLongPress: () => _delete(context),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: AppColors.surfaceHigh, shape: BoxShape.circle),
            child: Icon(modeIcon(record.mode), color: AppColors.textPrimary, size: 22),
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
                      const Text(
                        '중단',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _details,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
                formatTimeOfDay(record.startedAt),
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              if (rpe != null) ...[
                const SizedBox(height: 4),
                Tooltip(
                  message: '강도 · ${rpe.label}',
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
            tooltip: '더보기',
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
            onSelected: (_) => _delete(context),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'delete',
                child: Text('삭제', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
