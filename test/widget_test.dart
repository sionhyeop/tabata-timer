import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/app.dart';
import 'package:tabata_timer/data/app_scope.dart';

Future<AppServices> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final services = AppServices(prefs, silent: true);
  await tester.pumpWidget(TabataApp(services: services));
  await tester.pumpAndSettle();
  return services;
}

void main() {
  testWidgets('home shows tabata defaults and adjusts the total', (tester) async {
    await pumpApp(tester);

    expect(find.text('시작'), findsOneWidget);
    expect(find.text('0:20'), findsOneWidget);
    expect(find.text('0:10'), findsOneWidget);
    expect(find.text('3:50'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('라운드 늘리기'));
    await tester.pumpAndSettle();
    expect(find.text('9'), findsOneWidget);
    expect(find.text('4:20'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('운동 늘리기'));
    await tester.pumpAndSettle();
    expect(find.text('0:25'), findsOneWidget);
  });

  testWidgets('mode chips switch fields and remember values', (tester) async {
    final services = await pumpApp(tester);

    await tester.tap(find.text('AMRAP'));
    await tester.pumpAndSettle();
    expect(find.text('제한 시간'), findsOneWidget);
    expect(find.text('12:00'), findsWidgets);

    await tester.tap(find.text('타바타'));
    await tester.pumpAndSettle();
    expect(find.text('라운드'), findsOneWidget);
    expect(services.setup.mode.name, 'tabata');
  });

  testWidgets('tabs navigate', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('루틴'));
    await tester.pumpAndSettle();
    expect(find.text('내 루틴'), findsOneWidget);
    expect(find.text('클래식 타바타'), findsOneWidget);

    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 기록이 없어요'), findsOneWidget);

    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();
    expect(find.text('효과음'), findsOneWidget);
    expect(find.text('음성 안내'), findsOneWidget);
  });

  testWidgets('start a workout and stop it with confirmation', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('시작'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('준비'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('바로 시작'), findsOneWidget);

    await tester.tap(find.byTooltip('종료'));
    await tester.pumpAndSettle();
    expect(find.text('운동을 종료할까요?'), findsOneWidget);

    await tester.tap(find.text('종료'));
    await tester.pumpAndSettle();
    expect(find.text('운동을 종료할까요?'), findsNothing);
    expect(find.text('시작'), findsOneWidget);
  });
}
