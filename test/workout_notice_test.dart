import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/engine/workout_plan.dart';
import 'package:tabata_timer/models/timer_mode.dart';
import 'package:tabata_timer/models/workout_config.dart';
import 'package:tabata_timer/services/workout_notice.dart';
import 'package:tabata_timer/theme/app_colors.dart';

List<int> lengths(List<ProgressSegment> s) => [for (final x in s) x.seconds];

void main() {
  group('notificationSegments', () {
    test('few intervals: one segment each, get-ready left out', () {
      final c = WorkoutConfig.defaults(TimerMode.tabata).copyWith(rounds: 3);
      final s = notificationSegments(buildSteps(c, prepareSec: 5));
      expect(lengths(s), [20, 10, 20, 10, 20]);
      expect(s[0].color, AppColors.work);
      expect(s[1].color, AppColors.rest);
    });

    test('classic tabata: 15 intervals become 8 rounds', () {
      final s = notificationSegments(buildSteps(WorkoutConfig.defaults(TimerMode.tabata)));
      expect(lengths(s), [30, 30, 30, 30, 30, 30, 30, 20]);
    });

    test('many rounds fall back to sets, set rests stay visible', () {
      final c = WorkoutConfig.defaults(TimerMode.interval)
          .copyWith(workSec: 40, restSec: 20, rounds: 6, sets: 3, setRestSec: 60);
      final s = notificationSegments(buildSteps(c));
      expect(lengths(s), [340, 60, 340, 60, 340]);
      expect(s[1].color, AppColors.setRest);
    });

    test('never more than the platform limit, total preserved', () {
      final c = WorkoutConfig.defaults(TimerMode.emom).copyWith(workSec: 60, rounds: 30);
      final s = notificationSegments(buildSteps(c));
      expect(s.length, lessThanOrEqualTo(maxNotificationSegments));
      expect(lengths(s).reduce((a, b) => a + b), 30 * 60);
    });

    test('open-ended for time has no bar', () {
      final c = WorkoutConfig.defaults(TimerMode.forTime).copyWith(workSec: 0);
      expect(notificationSegments(buildSteps(c)), isEmpty);
    });
  });

  test('notice serializes for the platform channel', () {
    const notice = WorkoutNotice(
      title: '운동 · 라운드 1/8',
      text: '타바타 · 다음 휴식 0:10',
      time: '0:08',
      color: AppColors.work,
      segments: [ProgressSegment(30, AppColors.work)],
      positionSec: 12,
    );
    final map = notice.toMap();
    expect(map['position'], 12);
    expect(map['time'], '0:08');
    expect((map['segments'] as List).single, {'length': 30, 'color': AppColors.work.toARGB32()});
  });
}
