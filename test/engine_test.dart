import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/engine/workout_cue.dart';
import 'package:tabata_timer/engine/workout_plan.dart';
import 'package:tabata_timer/engine/workout_runner.dart';
import 'package:tabata_timer/models/interval_step.dart';
import 'package:tabata_timer/models/timer_mode.dart';
import 'package:tabata_timer/models/workout_config.dart';

class FakeClock {
  int now = 1000000;
  int call() => now;
}

void main() {
  group('buildSteps', () {
    test('classic tabata drops the trailing rest', () {
      final steps = buildSteps(WorkoutConfig.defaults(TimerMode.tabata));
      expect(steps.where((s) => s.phase == Phase.work).length, 8);
      expect(steps.where((s) => s.phase == Phase.rest).length, 7);
      expect(steps.last.phase, Phase.work);
      expect(workoutDurationSec(WorkoutConfig.defaults(TimerMode.tabata)), 230);
    });

    test('prepare step is prepended except for the rest timer', () {
      final tabata = buildSteps(WorkoutConfig.defaults(TimerMode.tabata), prepareSec: 10);
      expect(tabata.first.phase, Phase.prepare);
      expect(tabata.first.durationMs, 10000);

      final rest = buildSteps(WorkoutConfig.defaults(TimerMode.rest), prepareSec: 10);
      expect(rest.single.phase, Phase.rest);
    });

    test('interval with sets, set rest, warmup and cooldown', () {
      final c = WorkoutConfig.defaults(TimerMode.interval).copyWith(
        workSec: 30,
        restSec: 15,
        rounds: 3,
        sets: 2,
        setRestSec: 60,
        warmupSec: 120,
        cooldownSec: 90,
        exercises: ['스쿼트', '푸시업'],
      );
      final phases = buildSteps(c).map((s) => s.phase).toList();
      expect(phases, [
        Phase.warmup,
        Phase.work,
        Phase.rest,
        Phase.work,
        Phase.rest,
        Phase.work,
        Phase.setRest,
        Phase.work,
        Phase.rest,
        Phase.work,
        Phase.rest,
        Phase.work,
        Phase.cooldown,
      ]);
      final labels = buildSteps(c).where((s) => s.phase == Phase.work).map((s) => s.label).toList();
      expect(labels, ['스쿼트', '푸시업', '스쿼트', '스쿼트', '푸시업', '스쿼트']);
      expect(workoutDurationSec(c), 120 + 2 * (90 + 30) + 60 + 90);
    });

    test('sets without set rest fall back to the regular rest', () {
      final c = WorkoutConfig.defaults(TimerMode.tabata)
          .copyWith(rounds: 2, sets: 2, setRestSec: 0);
      expect(buildSteps(c).map((s) => s.phase), [
        Phase.work,
        Phase.rest,
        Phase.work,
        Phase.rest,
        Phase.work,
        Phase.rest,
        Phase.work,
      ]);
    });

    test('tabata ignores warmup and cooldown', () {
      final c = WorkoutConfig.defaults(TimerMode.tabata).copyWith(warmupSec: 60, cooldownSec: 60);
      expect(workoutDurationSec(c), 230);
    });

    test('emom, amrap, for time', () {
      final emom = buildSteps(WorkoutConfig.defaults(TimerMode.emom));
      expect(emom.length, 10);
      expect(emom.every((s) => s.durationMs == 60000), isTrue);

      final amrap = buildSteps(WorkoutConfig.defaults(TimerMode.amrap));
      expect(amrap.single.durationMs, 12 * 60000);

      final capped = buildSteps(WorkoutConfig.defaults(TimerMode.forTime));
      expect(capped.single.countUp, isTrue);
      expect(capped.single.durationMs, 20 * 60000);

      final uncapped = WorkoutConfig.defaults(TimerMode.forTime).copyWith(workSec: 0);
      expect(buildSteps(uncapped).single.durationMs, isNull);
      expect(workoutDurationSec(uncapped), isNull);
    });
  });

  group('WorkoutRunner', () {
    late FakeClock clock;
    late List<WorkoutCue> cues;

    WorkoutRunner runnerFor(WorkoutConfig c, {int prepareSec = 0}) {
      clock = FakeClock();
      cues = [];
      return WorkoutRunner(
        config: c,
        steps: buildSteps(c, prepareSec: prepareSec),
        clock: clock.call,
        autoTick: false,
        onCue: cues.add,
      );
    }

    void advance(WorkoutRunner r, int ms, {int step = 100}) {
      for (var t = 0; t < ms; t += step) {
        clock.now += step;
        r.tick();
      }
    }

    final tiny = WorkoutConfig.defaults(TimerMode.tabata)
        .copyWith(workSec: 5, restSec: 4, rounds: 2);

    test('walks through steps and finishes', () {
      final r = runnerFor(tiny, prepareSec: 3);
      r.start();
      expect(r.current.phase, Phase.prepare);
      expect(r.stepRemainingMs, 3000);

      advance(r, 3000);
      expect(r.current.phase, Phase.work);
      expect(r.current.round, 1);

      advance(r, 5000);
      expect(r.current.phase, Phase.rest);

      advance(r, 4000 + 5000);
      expect(r.isFinished, isTrue);
      expect(r.completed, isTrue);
      expect(r.completedWorkRounds, 2);
      expect(cues.last.type, CueType.finished);
    });

    test('emits 3-2-1 countdown once per second and step-start cues', () {
      final r = runnerFor(tiny);
      r.start();
      advance(r, 5000);
      final countdown = cues
          .where((c) => c.type == CueType.countdown)
          .map((c) => c.secondsLeft)
          .toList();
      expect(countdown, [3, 2, 1]);
      final starts = cues
          .where((c) => c.type == CueType.stepStart)
          .map((c) => c.step!.phase)
          .toList();
      expect(starts, [Phase.work, Phase.rest]);
      expect(cues.first.next!.phase, Phase.rest);
    });

    test('pause freezes time, resume continues', () {
      final r = runnerFor(tiny);
      r.start();
      advance(r, 2000);
      r.pause();
      clock.now += 60000;
      r.tick();
      expect(r.stepElapsedMs, 2000);
      expect(r.activeMs, 2000);
      r.resume();
      advance(r, 1000);
      expect(r.stepElapsedMs, 3000);
    });

    test('catches up after a long gap (app in background)', () {
      final r = runnerFor(tiny);
      r.start();
      clock.now += 5000 + 4000 + 1500;
      r.tick();
      expect(r.index, 2);
      expect(r.stepElapsedMs, 1500);
      // Only the step we landed on is announced.
      expect(cues.where((c) => c.type == CueType.stepStart).length, 2);
    });

    test('skip next / previous', () {
      final r = runnerFor(tiny);
      r.start();
      advance(r, 1000);
      r.skipNext();
      expect(r.current.phase, Phase.rest);
      expect(r.stepElapsedMs, 0);

      advance(r, 500);
      r.skipPrevious(); // within 2s → previous step
      expect(r.current.phase, Phase.work);
      expect(r.index, 0);

      advance(r, 3000);
      r.skipPrevious(); // past 2s → restart current
      expect(r.index, 0);
      expect(r.stepElapsedMs, 0);

      r.skipNext();
      r.skipNext();
      r.skipNext(); // past the last step → finished
      expect(r.isFinished, isTrue);
    });

    test('addTime extends the current step', () {
      final r = runnerFor(WorkoutConfig.defaults(TimerMode.rest).copyWith(workSec: 30));
      r.start();
      advance(r, 20000);
      r.addTime(const Duration(seconds: 15));
      expect(r.stepRemainingMs, 25000);
      expect(r.totalMs, 45000);
      advance(r, 25000);
      expect(r.isFinished, isTrue);
    });

    test('halfway and one-minute cues for long work', () {
      final r = runnerFor(WorkoutConfig.defaults(TimerMode.amrap).copyWith(workSec: 180));
      r.start();
      advance(r, 180000, step: 250);
      final types = cues.map((c) => c.type).toList();
      expect(types.where((t) => t == CueType.halfway).length, 1);
      expect(types.where((t) => t == CueType.oneMinuteLeft).length, 1);
      expect(types.last, CueType.finished);
    });

    test('for time without cap runs until finished manually', () {
      final r = runnerFor(WorkoutConfig.defaults(TimerMode.forTime).copyWith(workSec: 0));
      r.start();
      advance(r, 65000, step: 500);
      expect(r.isRunning, isTrue);
      expect(r.stepRemainingMs, isNull);
      r.lap();
      expect(r.laps.single, 65000);
      r.finish(completed: true);
      expect(r.isFinished, isTrue);
      expect(r.activeMs, 65000);
    });

    test('amrap round counter', () {
      final r = runnerFor(WorkoutConfig.defaults(TimerMode.amrap));
      r.start();
      r.addRound();
      r.addRound();
      r.undoRound();
      expect(r.amrapRounds, 1);
    });

    test('tracks time per phase', () {
      final r = runnerFor(tiny);
      r.start();
      advance(r, 7000);
      r.pause();
      expect(r.phaseTimeMs[Phase.work], 5000);
      expect(r.phaseTimeMs[Phase.rest], 2000);
    });
  });
}
