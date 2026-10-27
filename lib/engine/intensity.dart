import '../models/interval_step.dart';
import '../models/timer_mode.dart';
import '../models/workout_config.dart';

/// Five-step effort scale shared by the expected-intensity meter and the
/// post-workout rating, so the same face always means the same effort.
enum IntensityLevel {
  light('😌'),
  moderate('🙂'),
  vigorous('😤'),
  hard('🥵'),
  extreme('🔥');

  const IntensityLevel(this.emoji);

  final String emoji;

  /// 1 – 5.
  int get value => index + 1;

  static IntensityLevel ofValue(int value) => IntensityLevel.values[(value - 1).clamp(0, 4)];
}

/// Rough expected effort from the plan alone.
///
/// Work-to-rest ratio drives most of it (Tabata's 2:1 is brutal), total
/// work time adds the rest. Self-paced modes get a middle density score.
/// Null for the rest timer, which isn't a workout.
IntensityLevel? estimateIntensity(WorkoutConfig c) {
  final int densityPts;
  final double workMin;
  switch (c.mode) {
    case TimerMode.tabata:
    case TimerMode.interval:
      final ratio = c.restSec == 0 ? double.infinity : c.workSec / c.restSec;
      densityPts = ratio >= 2
          ? 3
          : ratio >= 4 / 3
          ? 2
          : ratio >= 1
          ? 1
          : 0;
      workMin = c.workSec * c.rounds * c.sets / 60;
    case TimerMode.emom:
      densityPts = 1;
      workMin = c.workSec * c.rounds / 60;
    case TimerMode.amrap:
      densityPts = 1;
      workMin = c.workSec / 60;
    case TimerMode.forTime:
      densityPts = 1;
      workMin = c.workSec == 0 ? 10 : c.workSec / 60;
    case TimerMode.rest:
      return null;
  }
  final durationPts = workMin >= 12
      ? 2
      : workMin >= 5
      ? 1
      : 0;
  return IntensityLevel.ofValue(1 + densityPts + durationPts);
}

/// The little face inside the workout ring: it reacts to how hard the
/// current moment is.
String workoutMascot({
  required Phase phase,
  required TimerMode mode,
  required double stepProgress,
  required int? remainingMs,
  required bool isLastRound,
  required bool paused,
}) {
  if (paused) return '☕';
  switch (phase) {
    case Phase.prepare:
      return remainingMs != null && remainingMs <= 3000 ? '😤' : '🙂';
    case Phase.warmup:
      return '🤸';
    case Phase.cooldown:
      return '🧘';
    case Phase.setRest:
      return '💧';
    case Phase.rest:
      if (mode == TimerMode.rest) {
        return remainingMs != null && remainingMs <= 5000 ? '💪' : '😌';
      }
      return stepProgress < 0.5 ? '😅' : '😌';
    case Phase.work:
      if (mode == TimerMode.amrap || mode == TimerMode.forTime) {
        if (remainingMs != null && remainingMs <= 60000) return '🔥';
        if (remainingMs == null) return '💪';
      } else if (isLastRound && stepProgress < 0.6) {
        return '🔥';
      }
      return stepProgress < 0.45
          ? '💪'
          : stepProgress < 0.8
          ? '😤'
          : '🥵';
  }
}
