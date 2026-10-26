// Captures the main screens on a simulator/device for visual review.
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart -d <device>
//
// PNGs land in build/screenshots/.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/app.dart';
import 'package:tabata_timer/data/app_scope.dart';
import 'package:tabata_timer/models/timer_mode.dart';
import 'package:tabata_timer/models/workout_record.dart';
import 'package:tabata_timer/ui/widgets/aurora_background.dart';
import 'package:tabata_timer/ui/workout/summary_page.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester tester, int ms) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
    await tester.pump();
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 100));
    await binding.takeScreenshot(name);
  }

  testWidgets('screens', (tester) async {
    // A still frame; the endless glow animation would never settle.
    AuroraBackground.motion = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final services = AppServices(prefs);
    await services.cues.init();

    // Recent sessions on consecutive days (relative to now, so the streak
    // and list look right whatever time the test runs).
    final now = DateTime.now();
    final seeded = [
      (0, 4, 8, 4, '클래식 타바타', TimerMode.tabata),
      (1, 26, 18, 3, '전신 서킷', TimerMode.interval),
      (2, 12, 0, 4, 'AMRAP 12분', TimerMode.amrap),
      (3, 8, 16, 5, '더블 타바타', TimerMode.tabata),
    ];
    for (final (day, minutes, rounds, rpe, name, mode) in seeded) {
      final at = day == 0
          ? now.subtract(const Duration(minutes: 25))
          : DateTime(now.year, now.month, now.day - day, 19, 30);
      services.history.add(
        WorkoutRecord(
          id: 'seed-$day',
          name: name,
          mode: mode,
          startedAt: at,
          activeMs: minutes * 60000,
          completed: true,
          workRounds: rounds,
          amrapRounds: mode == TimerMode.amrap ? 7 : 0,
          rpe: rpe,
          kcal: minutes * 9,
        ),
      );
    }

    await tester.pumpWidget(TabataApp(services: services));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    await shot(tester, '01_home_tabata');

    await tester.tap(find.text('인터벌'));
    await tester.pumpAndSettle();
    await shot(tester, '02_home_interval');
    await tester.tap(find.text('타바타'));
    await tester.pumpAndSettle();

    // Workout: prepare → work → rest → paused → stop dialog.
    await tester.tap(find.text('시작'));
    await wait(tester, 1500);
    await shot(tester, '03_workout_prepare');

    await tester.tap(find.byTooltip('바로 시작'));
    await wait(tester, 2200);
    await shot(tester, '04_workout_work');

    await tester.tap(find.byTooltip('다음'));
    await wait(tester, 1500);
    await shot(tester, '05_workout_rest');

    await tester.tap(find.bySemanticsLabel('일시정지'));
    await wait(tester, 600);
    await shot(tester, '06_workout_paused');

    await tester.tap(find.byTooltip('종료'));
    await tester.pumpAndSettle();
    await shot(tester, '07_stop_dialog');
    await tester.tap(find.text('종료'));
    await tester.pumpAndSettle();

    // AMRAP with the round counter.
    await tester.tap(find.text('AMRAP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작'));
    await wait(tester, 500);
    await tester.tap(find.byTooltip('바로 시작'));
    await wait(tester, 800);
    await tester.tap(find.text('+1'));
    await tester.tap(find.text('+1'));
    await wait(tester, 800);
    await shot(tester, '08_workout_amrap');
    await tester.tap(find.byTooltip('종료'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('종료'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('타바타'));
    await tester.pumpAndSettle();

    // Run a tiny workout to the end: finish → saved → summary → rate.
    final tabata = services.setup.config;
    services.settings.update((s) => s.copyWith(prepareSec: 0));
    services.setup.update(tabata.copyWith(workSec: 5, rounds: 1));
    await tester.pumpAndSettle();
    final before = services.history.records.length;
    await tester.tap(find.text('시작'));
    await wait(tester, 6500);
    await wait(tester, 2800);
    expect(find.byType(SummaryPage), findsOneWidget);
    expect(services.history.records.length, before + 1);
    await tester.tap(find.text('힘들어요'));
    await tester.pumpAndSettle();
    await shot(tester, '09_summary');
    await tester.tap(find.text('기록하기'));
    await tester.pumpAndSettle();
    expect(services.history.records.firstWhere((r) => !r.id.startsWith('seed')).rpe, 3);
    services.settings.update((s) => s.copyWith(prepareSec: 5));
    services.setup.update(tabata);
    await tester.pumpAndSettle();

    await tester.tap(find.text('루틴'));
    await tester.pumpAndSettle();
    await shot(tester, '10_routines');

    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    await shot(tester, '11_history');

    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();
    await shot(tester, '12_settings');

    await tester.tap(find.text('목소리'));
    await wait(tester, 1500);
    await tester.pumpAndSettle();
    await shot(tester, '13_voice_sheet');
    await tester.tapAt(const Offset(20, 60)); // dismiss the sheet
    await tester.pumpAndSettle();

    await prefs.clear();
  });
}
