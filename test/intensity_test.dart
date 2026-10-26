import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/data/default_routines.dart';
import 'package:tabata_timer/engine/intensity.dart';
import 'package:tabata_timer/models/interval_step.dart';
import 'package:tabata_timer/models/timer_mode.dart';
import 'package:tabata_timer/models/workout_config.dart';
import 'package:tabata_timer/ui/widgets/work_rest_card.dart';

IntensityLevel? presetLevel(String id) =>
    estimateIntensity(defaultRoutines.firstWhere((r) => r.id == id));

void main() {
  group('estimateIntensity', () {
    test('built-in routines land on sensible levels', () {
      expect(presetLevel('preset-beginner'), IntensityLevel.moderate); // 20/20 × 6
      expect(presetLevel('preset-hiit3030'), IntensityLevel.vigorous); // 30/30 × 10
      expect(presetLevel('preset-classic'), IntensityLevel.hard); // 20/10 × 8
      expect(presetLevel('preset-double'), IntensityLevel.extreme); // 20/10 × 8 × 2
      expect(presetLevel('preset-circuit'), IntensityLevel.extreme); // 40/20 × 6 × 3
      expect(presetLevel('preset-emom10'), IntensityLevel.vigorous);
      expect(presetLevel('preset-amrap12'), IntensityLevel.hard);
    });

    test('more rest per work lowers the level', () {
      final easy = WorkoutConfig.defaults(TimerMode.tabata)
          .copyWith(workSec: 20, restSec: 40, rounds: 4);
      expect(estimateIntensity(easy), IntensityLevel.light);
    });

    test('rest timer has no intensity', () {
      expect(estimateIntensity(WorkoutConfig.defaults(TimerMode.rest)), isNull);
    });
  });

  group('workoutMascot', () {
    String face(
      Phase phase, {
      TimerMode mode = TimerMode.tabata,
      double progress = 0,
      int? remainingMs = 10000,
      bool lastRound = false,
      bool paused = false,
    }) => workoutMascot(
      phase: phase,
      mode: mode,
      stepProgress: progress,
      remainingMs: remainingMs,
      isLastRound: lastRound,
      paused: paused,
    );

    test('work gets tougher as the interval goes on', () {
      expect(face(Phase.work, progress: 0.1), '💪');
      expect(face(Phase.work, progress: 0.6), '😤');
      expect(face(Phase.work, progress: 0.9), '🥵');
      expect(face(Phase.work, progress: 0.1, lastRound: true), '🔥');
    });

    test('rest recovers, other phases have their own face', () {
      expect(face(Phase.rest, progress: 0.2), '😅');
      expect(face(Phase.rest, progress: 0.7), '😌');
      expect(face(Phase.setRest), '💧');
      expect(face(Phase.prepare, remainingMs: 8000), '🙂');
      expect(face(Phase.prepare, remainingMs: 2000), '😤');
      expect(face(Phase.work, paused: true), '☕');
    });

    test('long self-paced work flags the final minute', () {
      expect(face(Phase.work, mode: TimerMode.amrap, progress: 0.95, remainingMs: 30000), '🔥');
      expect(face(Phase.work, mode: TimerMode.forTime, remainingMs: null), '💪');
      expect(face(Phase.rest, mode: TimerMode.rest, remainingMs: 4000), '💪');
    });
  });

  test('work:rest ratio label', () {
    expect(ratioLabel(20, 10), '2 : 1');
    expect(ratioLabel(40, 20), '2 : 1');
    expect(ratioLabel(30, 30), '1 : 1');
    expect(ratioLabel(45, 15), '3 : 1');
    expect(ratioLabel(25, 10), '5 : 2');
    expect(ratioLabel(37, 13), '2.8 : 1');
    expect(ratioLabel(13, 37), '1 : 2.8');
    expect(ratioLabel(20, 0), '휴식 없음');
  });
}
