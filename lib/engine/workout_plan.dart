import '../models/interval_step.dart';
import '../models/timer_mode.dart';
import '../models/workout_config.dart';

/// Expands a config into the full timeline the runner plays back.
///
/// The rest after the final round of a set is dropped: a set ends on work,
/// followed by the set rest (or a regular rest when no set rest is given).
List<IntervalStep> buildSteps(WorkoutConfig c, {int prepareSec = 0}) {
  final steps = <IntervalStep>[];
  if (prepareSec > 0 && c.mode != TimerMode.rest) {
    steps.add(IntervalStep(phase: Phase.prepare, durationMs: prepareSec * 1000));
  }

  String? exerciseFor(int round) =>
      c.exercises.isEmpty ? null : c.exercises[(round - 1) % c.exercises.length];

  switch (c.mode) {
    case TimerMode.tabata:
    case TimerMode.interval:
      final hasWarmCool = c.mode == TimerMode.interval;
      if (hasWarmCool && c.warmupSec > 0) {
        steps.add(IntervalStep(phase: Phase.warmup, durationMs: c.warmupSec * 1000));
      }
      for (var set = 1; set <= c.sets; set++) {
        for (var round = 1; round <= c.rounds; round++) {
          steps.add(
            IntervalStep(
              phase: Phase.work,
              durationMs: c.workSec * 1000,
              round: round,
              totalRounds: c.rounds,
              set: set,
              totalSets: c.sets,
              label: exerciseFor(round),
            ),
          );
          if (round < c.rounds && c.restSec > 0) {
            steps.add(
              IntervalStep(
                phase: Phase.rest,
                durationMs: c.restSec * 1000,
                round: round,
                totalRounds: c.rounds,
                set: set,
                totalSets: c.sets,
              ),
            );
          }
        }
        if (set < c.sets) {
          final betweenSec = c.setRestSec > 0 ? c.setRestSec : c.restSec;
          if (betweenSec > 0) {
            steps.add(
              IntervalStep(
                phase: c.setRestSec > 0 ? Phase.setRest : Phase.rest,
                durationMs: betweenSec * 1000,
                round: c.rounds,
                totalRounds: c.rounds,
                set: set,
                totalSets: c.sets,
              ),
            );
          }
        }
      }
      if (hasWarmCool && c.cooldownSec > 0) {
        steps.add(IntervalStep(phase: Phase.cooldown, durationMs: c.cooldownSec * 1000));
      }
    case TimerMode.emom:
      for (var round = 1; round <= c.rounds; round++) {
        steps.add(
          IntervalStep(
            phase: Phase.work,
            durationMs: c.workSec * 1000,
            round: round,
            totalRounds: c.rounds,
            label: exerciseFor(round),
          ),
        );
      }
    case TimerMode.amrap:
      steps.add(
        IntervalStep(phase: Phase.work, durationMs: c.workSec * 1000, label: exerciseFor(1)),
      );
    case TimerMode.forTime:
      steps.add(
        IntervalStep(
          phase: Phase.work,
          durationMs: c.workSec > 0 ? c.workSec * 1000 : null,
          label: exerciseFor(1),
          countUp: true,
        ),
      );
    case TimerMode.rest:
      steps.add(IntervalStep(phase: Phase.rest, durationMs: c.workSec * 1000));
  }
  return steps;
}

/// Total length in seconds without the get-ready countdown.
/// Null for an uncapped For Time workout.
int? workoutDurationSec(WorkoutConfig c) {
  var total = 0;
  for (final step in buildSteps(c)) {
    final d = step.durationMs;
    if (d == null) return null;
    total += d;
  }
  return total ~/ 1000;
}
