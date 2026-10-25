import 'package:flutter/material.dart';

import '../../data/app_scope.dart';
import '../../models/workout_config.dart';
import 'workout_page.dart';

/// Opens the full-screen workout for [config]. Routines are remembered for
/// the "최근 루틴" banner.
Future<void> launchWorkout(BuildContext context, WorkoutConfig config, {bool isRoutine = false}) {
  if (isRoutine) AppScope.of(context).routines.markUsed(config.id);
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => WorkoutPage(config: config),
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}
