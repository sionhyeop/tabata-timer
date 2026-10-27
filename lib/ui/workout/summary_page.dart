import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../l10n/l10n.dart';
import '../../models/timer_mode.dart';
import '../../models/workout_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/rpe.dart';
import '../widgets/aurora_background.dart';
import 'confetti.dart';

/// Shown after a workout. The record is already saved; this screen only
/// adds the effort rating.
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key, required this.record});

  final WorkoutRecord record;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  int? _rpe;

  void _save() {
    AppScope.of(context).history.update(widget.record.copyWith(rpe: _rpe));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final s = context.l10n;
    final (roundsValue, roundsLabel) = switch (r.mode) {
      TimerMode.amrap => ('${r.amrapRounds}', s.fieldRounds),
      TimerMode.forTime => ('${r.laps.length}', s.lap),
      _ => ('${r.workRounds}', s.fieldRounds),
    };
    final palette = AppPalette.of(context);
    return Scaffold(
      body: AuroraBackground(
        child: Stack(
          children: [
            if (r.completed) const Positioned.fill(child: IgnorePointer(child: Confetti())),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                      children: [
                        Text(
                          r.completed ? s.workoutComplete : s.stoppedHere,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${r.name} · ${formatDateLabel(r.startedAt, s.localeName)} '
                          '${formatTimeOfDay(r.startedAt, s.localeName)}',
                          style: TextStyle(color: palette.textSecondary, fontSize: 15),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: _Stat(
                                value: formatElapsedMs(r.activeMs),
                                label: r.mode == TimerMode.forTime ? s.finishTime : s.workoutTime,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Stat(value: roundsValue, label: roundsLabel),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Stat(value: '${r.kcal}', label: s.kcalEstimated),
                            ),
                          ],
                        ),
                        if (r.laps.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _LapsCard(laps: r.laps),
                        ],
                        const SizedBox(height: 16),
                        AppCard(
                          padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                          child: Column(
                            children: [
                              Text(
                                s.howHard,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  for (final level in rpeLevels)
                                    Expanded(
                                      child: RpeOption(
                                        level: level,
                                        selected: _rpe == level.value,
                                        dimmed: _rpe != null && _rpe != level.value,
                                        onTap: () => setState(() => _rpe = level.value),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: s.logIt,
                                height: 52,
                                onPressed: _rpe == null ? null : _save,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        s.close,
                        style: TextStyle(color: palette.textSecondary, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppPalette.of(context).textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LapsCard extends StatelessWidget {
  const _LapsCard({required this.laps});

  final List<int> laps;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < laps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text(context.l10n.lapN(i + 1), style: TextStyle(color: palette.textSecondary)),
                  const Spacer(),
                  Text(
                    '+${formatLapMs(laps[i] - (i == 0 ? 0 : laps[i - 1]))}',
                    style: TextStyle(color: palette.textSecondary, fontFeatures: tabularFigures),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    formatLapMs(laps[i]),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
