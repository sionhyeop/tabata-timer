import 'dart:ui';

import '../models/interval_step.dart';
import '../theme/app_colors.dart';

/// One colored stretch of the notification's progress bar.
class ProgressSegment {
  const ProgressSegment(this.seconds, this.color);

  final int seconds;
  final Color color;

  ProgressSegment extendedBy(int more) => ProgressSegment(seconds + more, color);
}

/// Android draws at most this many segments and merges everything into one
/// bar beyond it.
const maxNotificationSegments = 10;

/// The workout (get-ready excluded) as at most [max] phase-colored segments.
///
/// Tries the finest grouping that fits: one segment per interval, then one
/// per round (work + the rest after it), then one per set; failing all of
/// those, equal chunks.
List<ProgressSegment> notificationSegments(
  List<IntervalStep> steps, {
  int max = maxNotificationSegments,
}) {
  final body = [
    for (final s in steps)
      if (s.phase != Phase.prepare && (s.durationMs ?? 0) > 0) s,
  ];
  if (body.isEmpty) return const [];
  int sec(IntervalStep s) => (s.durationMs! / 1000).round();

  final perStep = [for (final s in body) ProgressSegment(sec(s), AppColors.phase(s.phase))];
  if (perStep.length <= max) return perStep;

  final perRound = <ProgressSegment>[];
  for (var i = 0; i < body.length; i++) {
    final s = body[i];
    if (s.phase == Phase.rest && i > 0 && body[i - 1].phase == Phase.work) {
      perRound.last = perRound.last.extendedBy(sec(s));
    } else {
      perRound.add(ProgressSegment(sec(s), AppColors.phase(s.phase)));
    }
  }
  if (perRound.length <= max) return perRound;

  final perSet = <ProgressSegment>[];
  int? openSet;
  for (final s in body) {
    final inSet = s.phase == Phase.work || s.phase == Phase.rest;
    if (inSet && openSet == s.set && perSet.isNotEmpty) {
      perSet.last = perSet.last.extendedBy(sec(s));
    } else {
      perSet.add(ProgressSegment(sec(s), inSet ? AppColors.work : AppColors.phase(s.phase)));
      openSet = inSet ? s.set : null;
    }
  }
  if (perSet.length <= max) return perSet;

  final total = body.fold(0, (sum, s) => sum + sec(s));
  final chunk = (total / max).ceil();
  return [
    for (var start = 0; start < total; start += chunk)
      ProgressSegment(start + chunk > total ? total - start : chunk, AppColors.work),
  ];
}

/// Everything the workout notification shows; see WorkoutNotification.kt.
class WorkoutNotice {
  const WorkoutNotice({
    required this.title,
    required this.text,
    required this.time,
    required this.color,
    required this.segments,
    required this.positionSec,
  });

  /// Phase and round, e.g. "운동 · 라운드 3/8".
  final String title;

  /// Expanded view only: routine and what comes next.
  final String text;

  /// Time left in the interval (or elapsed, when open-ended).
  final String time;
  final Color color;
  final List<ProgressSegment> segments;

  /// Seconds into the workout, on the same scale as [segments].
  final int positionSec;

  Map<String, Object?> toMap() => {
    'title': title,
    'text': text,
    'time': time,
    'color': color.toARGB32(),
    'segments': [
      for (final s in segments) {'length': s.seconds, 'color': s.color.toARGB32()},
    ],
    'position': positionSec,
  };
}
