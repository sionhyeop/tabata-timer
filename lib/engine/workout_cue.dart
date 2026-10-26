import '../models/interval_step.dart';

enum CueType {
  stepStart,

  /// Every passing second that isn't part of the final countdown, so the
  /// user can hear the timer running.
  tick,
  countdown,
  halfway,
  oneMinuteLeft,
  finished,
}

/// Something the user should hear or feel. Emitted by [WorkoutRunner],
/// rendered by `CuePlayer` according to the user's settings.
class WorkoutCue {
  const WorkoutCue(this.type, {this.step, this.next, this.secondsLeft = 0});

  final CueType type;
  final IntervalStep? step;
  final IntervalStep? next;
  final int secondsLeft;

  @override
  String toString() =>
      'WorkoutCue(${type.name}${step != null ? ', ${step!.phase.name}' : ''}'
      '${type == CueType.countdown ? ', $secondsLeft' : ''})';
}
