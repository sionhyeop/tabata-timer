import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/interval_step.dart';
import '../models/workout_config.dart';
import 'workout_cue.dart';

enum RunnerStatus { ready, running, paused, finished }

/// Plays back a precomputed timeline.
///
/// Everything is derived from a single position on the timeline:
/// `position = activeMs + offsetMs`, where `activeMs` comes from clock
/// differences (no drift, catches up after the app was backgrounded) and
/// `offsetMs` absorbs skips. The current step, remaining time and cues all
/// follow from that position.
class WorkoutRunner extends ChangeNotifier {
  WorkoutRunner({
    required this.config,
    required List<IntervalStep> steps,
    this.countdownBeeps = 3,
    this.halfwayAlert = true,
    this.onCue,
    int Function()? clock,
    this.autoTick = true,
  }) : assert(steps.isNotEmpty),
       _steps = List.of(steps),
       _clock = clock ?? _wallClock {
    _recomputeStarts();
  }

  static int _wallClock() => DateTime.now().millisecondsSinceEpoch;
  static const _tickInterval = Duration(milliseconds: 100);

  final WorkoutConfig config;
  final int countdownBeeps;
  final bool halfwayAlert;
  final bool autoTick;
  void Function(WorkoutCue cue)? onCue;

  final List<IntervalStep> _steps;
  final int Function() _clock;

  /// `_starts[i]` is where step i begins; the last entry is the total length,
  /// or null when the final step is open-ended.
  late List<int?> _starts;

  int _accumulatedMs = 0;
  int? _runStartedAt;
  int _offsetMs = 0;
  Timer? _ticker;

  RunnerStatus _status = RunnerStatus.ready;
  int _index = 0;
  int _lastCountdownSecond = -1;
  int _lastElapsedSecond = 0;
  bool _halfwayFired = false;
  bool _minuteFired = false;
  bool _completed = false;
  int _amrapRounds = 0;
  final List<int> _laps = [];
  final Map<Phase, int> _phaseMs = {};
  int _accountedMs = 0;
  DateTime? _startedAt;

  // --- State -------------------------------------------------------------

  List<IntervalStep> get steps => List.unmodifiable(_steps);
  RunnerStatus get status => _status;
  bool get isRunning => _status == RunnerStatus.running;
  bool get isPaused => _status == RunnerStatus.paused;
  bool get isFinished => _status == RunnerStatus.finished;
  bool get completed => _completed;
  DateTime? get startedAt => _startedAt;
  int get index => _index;
  IntervalStep get current => _steps[_index];
  IntervalStep? get next => _index + 1 < _steps.length ? _steps[_index + 1] : null;
  int get amrapRounds => _amrapRounds;
  List<int> get laps => List.unmodifiable(_laps);

  /// Time spent running, pauses excluded.
  int get activeMs => _accumulatedMs + (_runStartedAt == null ? 0 : _clock() - _runStartedAt!);

  int get positionMs {
    final pos = activeMs + _offsetMs;
    final total = totalMs;
    if (pos < 0) return 0;
    return total != null && pos > total ? total : pos;
  }

  int? get totalMs => _starts.last;
  int stepStartMs(int i) => _starts[i]!;

  int get stepElapsedMs {
    final elapsed = positionMs - _starts[_index]!;
    final d = current.durationMs;
    return d != null && elapsed > d ? d : elapsed;
  }

  int? get stepRemainingMs {
    final d = current.durationMs;
    return d == null ? null : d - stepElapsedMs;
  }

  double get stepProgress {
    final d = current.durationMs;
    if (d == null || d == 0) return 0;
    return (stepElapsedMs / d).clamp(0.0, 1.0);
  }

  int? get totalRemainingMs {
    final total = totalMs;
    return total == null ? null : total - positionMs;
  }

  /// Work intervals that were fully played.
  int get completedWorkRounds {
    final upTo = isFinished && _completed ? _steps.length : _index;
    var n = 0;
    for (var i = 0; i < upTo; i++) {
      if (_steps[i].phase == Phase.work) n++;
    }
    return n;
  }

  /// Active time spent in each phase (for the calorie estimate).
  Map<Phase, int> get phaseTimeMs => Map.unmodifiable(_phaseMs);

  // --- Controls ----------------------------------------------------------

  void start() {
    if (_status != RunnerStatus.ready) return;
    _startedAt = DateTime.now();
    _status = RunnerStatus.running;
    _runStartedAt = _clock();
    _enterStep(0);
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (!isRunning) return;
    _account();
    _accumulatedMs = activeMs;
    _runStartedAt = null;
    _ticker?.cancel();
    _status = RunnerStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (!isPaused) return;
    _runStartedAt = _clock();
    _status = RunnerStatus.running;
    _startTicker();
    notifyListeners();
  }

  void togglePause() => isRunning ? pause() : resume();

  void skipNext() {
    if (isFinished || _status == RunnerStatus.ready) return;
    if (_index >= _steps.length - 1) {
      finish(completed: true);
      return;
    }
    _jumpTo(_starts[_index + 1]!);
  }

  /// Restarts the current step, or goes to the previous one when the
  /// current step has only just begun.
  void skipPrevious() {
    if (isFinished || _status == RunnerStatus.ready) return;
    final target = stepElapsedMs > 2000 || _index == 0 ? _starts[_index]! : _starts[_index - 1]!;
    _jumpTo(target, reenter: true);
  }

  /// Extends the current step, e.g. "+15초" on the rest timer.
  void addTime(Duration extra) {
    final d = current.durationMs;
    if (d == null || isFinished) return;
    _steps[_index] = current.copyWith(durationMs: d + extra.inMilliseconds);
    _recomputeStarts();
    _lastCountdownSecond = _remainingSecond(positionMs) ?? -1;
    notifyListeners();
  }

  void addRound() {
    if (isFinished || _status == RunnerStatus.ready) return;
    _amrapRounds++;
    notifyListeners();
  }

  void undoRound() {
    if (_amrapRounds == 0 || isFinished) return;
    _amrapRounds--;
    notifyListeners();
  }

  void lap() {
    if (isFinished || _status == RunnerStatus.ready) return;
    _laps.add(stepElapsedMs);
    notifyListeners();
  }

  void finish({required bool completed}) {
    if (isFinished) return;
    _account();
    _accumulatedMs = activeMs;
    _runStartedAt = null;
    _ticker?.cancel();
    _status = RunnerStatus.finished;
    _completed = completed;
    if (completed) _emit(const WorkoutCue(CueType.finished));
    notifyListeners();
  }

  /// Advances the timeline. Called by the internal ticker; public so tests
  /// can drive it with a fake clock.
  @visibleForTesting
  void tick() {
    if (!isRunning) return;
    _sync();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // --- Internals ---------------------------------------------------------

  void _startTicker() {
    _ticker?.cancel();
    if (autoTick) _ticker = Timer.periodic(_tickInterval, (_) => tick());
  }

  void _recomputeStarts() {
    final starts = <int?>[0];
    var acc = 0;
    for (final step in _steps) {
      final d = step.durationMs;
      if (d == null) {
        starts.add(null);
        break;
      }
      acc += d;
      starts.add(acc);
    }
    _starts = starts;
  }

  void _jumpTo(int target, {bool reenter = false}) {
    _account();
    _offsetMs += target - (activeMs + _offsetMs);
    _sync(reenter: reenter);
  }

  void _sync({bool reenter = false}) {
    _account();
    final pos = activeMs + _offsetMs;
    final total = totalMs;
    if (total != null && pos >= total) {
      _index = _steps.length - 1;
      finish(completed: true);
      return;
    }
    final i = _indexAt(pos);
    if (i != _index || reenter) {
      _enterStep(i);
    } else {
      _checkCues(pos);
    }
    notifyListeners();
  }

  int _indexAt(int pos) {
    for (var i = _steps.length - 1; i > 0; i--) {
      if (pos >= _starts[i]!) return i;
    }
    return 0;
  }

  void _enterStep(int i) {
    _index = i;
    _halfwayFired = false;
    _minuteFired = false;
    _lastElapsedSecond = 0;
    // The step-start sound covers the first second; beep only after that.
    _lastCountdownSecond = _remainingSecond(activeMs + _offsetMs) ?? -1;
    _emit(WorkoutCue(CueType.stepStart, step: current, next: next));
  }

  int? _remainingSecond(int pos) {
    final d = current.durationMs;
    if (d == null) return null;
    return ((d - (pos - _starts[_index]!)) / 1000).ceil();
  }

  void _checkCues(int pos) {
    final d = current.durationMs;
    if (d == null) {
      // Open-ended step: tick on elapsed seconds.
      final elapsedSecond = (pos - _starts[_index]!) ~/ 1000;
      if (elapsedSecond > _lastElapsedSecond) {
        _lastElapsedSecond = elapsedSecond;
        _emit(WorkoutCue(CueType.tick, step: current));
      }
      return;
    }
    final remaining = d - (pos - _starts[_index]!);
    final second = (remaining / 1000).ceil();
    if (second != _lastCountdownSecond) {
      _lastCountdownSecond = second;
      if (second >= 1 && second <= countdownBeeps) {
        _emit(WorkoutCue(CueType.countdown, step: current, secondsLeft: second));
      } else if (second >= 1) {
        _emit(WorkoutCue(CueType.tick, step: current, secondsLeft: second));
      }
    }
    // Late events (e.g. after returning from background) are dropped
    // rather than announced out of context.
    if (halfwayAlert &&
        !_halfwayFired &&
        current.phase == Phase.work &&
        d >= 30000 &&
        remaining <= d / 2) {
      _halfwayFired = true;
      if (remaining > d / 2 - 1500) {
        _emit(WorkoutCue(CueType.halfway, step: current));
      }
    }
    if (!_minuteFired && d >= 120000 && remaining <= 60000) {
      _minuteFired = true;
      if (remaining > 58500) {
        _emit(WorkoutCue(CueType.oneMinuteLeft, step: current));
      }
    }
  }

  void _account() {
    final now = activeMs;
    final delta = now - _accountedMs;
    if (delta > 0 && _status != RunnerStatus.ready) {
      _phaseMs[current.phase] = (_phaseMs[current.phase] ?? 0) + delta;
    }
    _accountedMs = now;
  }

  void _emit(WorkoutCue cue) => onCue?.call(cue);
}
