import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/data/history_store.dart';
import 'package:tabata_timer/engine/workout_plan.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:tabata_timer/models/interval_step.dart';
import 'package:tabata_timer/models/timer_mode.dart';
import 'package:tabata_timer/models/workout_config.dart';
import 'package:tabata_timer/models/workout_record.dart';
import 'package:tabata_timer/services/calorie.dart';
import 'package:tabata_timer/services/cue_player.dart';
import 'package:tabata_timer/ui/widgets/value_tile.dart';

WorkoutRecord record(DateTime at, {int minutes = 4}) => WorkoutRecord(
  id: at.toIso8601String(),
  name: '타바타',
  mode: TimerMode.tabata,
  startedAt: at,
  activeMs: minutes * 60000,
  completed: true,
);

final ko = lookupAppLocalizations(const Locale('ko'));

void main() {
  group('history stats', () {
    // Saturday.
    final now = DateTime(2026, 10, 24, 21);

    test('week stats sum Monday through Sunday only', () {
      final stats = computeWeekStats([
        record(DateTime(2026, 10, 19, 7)), // Mon
        record(DateTime(2026, 10, 19, 19), minutes: 10), // Mon
        record(DateTime(2026, 10, 24, 8)), // Sat
        record(DateTime(2026, 10, 18, 8)), // previous Sunday
      ], now);
      expect(stats.days.first, DateTime(2026, 10, 19));
      expect(stats.days.last, DateTime(2026, 10, 25));
      expect(stats.secondsPerDay, [840, 0, 0, 0, 0, 240, 0]);
      expect(stats.count, 3);
      expect(stats.totalSec, 1080);
    });

    test('streak counts back from today or yesterday', () {
      final days = [24, 23, 22, 20];
      final records = [for (final d in days) record(DateTime(2026, 10, d, 9))];
      expect(computeStreak(records, now), 3);
      // No workout yet today: yesterday's streak still counts.
      expect(computeStreak(records, DateTime(2026, 10, 25, 9)), 3);
      // Two days off breaks it.
      expect(computeStreak(records, DateTime(2026, 10, 26, 9)), 0);
      expect(computeStreak([], now), 0);
    });

    test('streak crosses month boundaries', () {
      final records = [
        record(DateTime(2026, 11, 1, 9)),
        record(DateTime(2026, 10, 31, 9)),
        record(DateTime(2026, 10, 30, 9)),
      ];
      expect(computeStreak(records, DateTime(2026, 11, 1, 20)), 3);
    });
  });

  test('calorie estimate uses MET × kg × hours', () {
    // 30 min of work at 8 MET for 60 kg = 240 kcal; prepare is ignored.
    expect(estimateKcal({Phase.work: 30 * 60000, Phase.prepare: 600000}, 60), 240);
  });

  group('value stepping', () {
    ConfigField field(int v, {ValueKind kind = ValueKind.duration, int min = 0}) =>
        ConfigField(label: 'x', kind: kind, value: v, min: min, max: 3600, onChanged: (_) {});

    int up(int v) {
      late int out;
      ConfigField(
        label: 'x',
        kind: ValueKind.duration,
        value: v,
        min: 0,
        max: 3600,
        onChanged: (n) => out = n,
      ).increment();
      return out;
    }

    int down(int v) {
      late int out;
      ConfigField(
        label: 'x',
        kind: ValueKind.duration,
        value: v,
        min: 0,
        max: 3600,
        onChanged: (n) => out = n,
      ).decrement();
      return out;
    }

    test('5s under a minute, 15s under ten minutes, then minutes', () {
      expect(up(20), 25);
      expect(up(55), 60);
      expect(up(60), 75);
      expect(down(75), 60);
      expect(down(60), 55);
      expect(up(590), 600);
      expect(up(600), 660);
      expect(down(600), 585);
      expect(up(22), 25); // snaps to the grid
    });

    test('display', () {
      expect(field(20).display(ko), '20초');
      expect(field(90).display(ko), '1분 30초');
      expect(field(120).display(ko), '2분');
      expect(field(5, kind: ValueKind.count).display(ko), '5');
      expect(
        ConfigField(
          label: 'x',
          kind: ValueKind.duration,
          value: 0,
          min: 0,
          max: 60,
          zeroLabel: '없음',
          onChanged: (_) {},
        ).display(ko),
        '없음',
      );
    });
  });

  group('voice announcements', () {
    final circuit = WorkoutConfig.defaults(TimerMode.interval)
        .copyWith(rounds: 2, sets: 2, exercises: ['스쿼트', '버피']);
    final steps = buildSteps(circuit, prepareSec: 10);
    String say(int i) =>
        stepAnnouncement(steps[i], i + 1 < steps.length ? steps[i + 1] : null, circuit.mode, ko);

    test('circuit flow', () {
      expect(say(0), '준비하세요. 첫 운동은 스쿼트');
      expect(say(1), '스쿼트 시작');
      expect(say(2), '휴식. 다음은 버피');
      expect(say(3), '버피 시작');
      expect(say(4), '세트 휴식. 다음은 2세트');
      expect(say(5), '2세트. 스쿼트 시작');
      expect(say(steps.length - 1), '마지막 라운드! 버피 시작');
    });

    test('plain intervals say 운동 시작 / 휴식', () {
      final tabata = buildSteps(WorkoutConfig.defaults(TimerMode.tabata));
      expect(stepAnnouncement(tabata[0], tabata[1], TimerMode.tabata, ko), '운동 시작');
      expect(stepAnnouncement(tabata[1], tabata[2], TimerMode.tabata, ko), '휴식');
      expect(stepAnnouncement(tabata.last, null, TimerMode.tabata, ko), '마지막 라운드! 운동 시작');
    });

    test('emom rounds and rest timer', () {
      final emom = buildSteps(WorkoutConfig.defaults(TimerMode.emom).copyWith(rounds: 3));
      expect(stepAnnouncement(emom[0], emom[1], TimerMode.emom, ko), '1라운드 시작');
      expect(stepAnnouncement(emom[2], null, TimerMode.emom, ko), '마지막 라운드 시작');
      final rest = buildSteps(WorkoutConfig.defaults(TimerMode.rest)).single;
      expect(stepAnnouncement(rest, null, TimerMode.rest, ko), '휴식 시작');
    });
  });
}
