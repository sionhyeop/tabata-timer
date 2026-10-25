import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/app_scope.dart';
import '../../engine/workout_cue.dart';
import '../../engine/workout_plan.dart';
import '../../engine/workout_runner.dart';
import '../../models/interval_step.dart';
import '../../models/timer_mode.dart';
import '../../models/workout_config.dart';
import '../../models/workout_record.dart';
import '../../services/calorie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/common.dart';
import 'summary_page.dart';

/// Full-screen workout. The background takes the phase color so the state
/// is readable from across the room.
class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key, required this.config});

  final WorkoutConfig config;

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late final AppServices _services;
  late final WorkoutRunner _runner;
  bool _muted = false;
  bool _handledFinish = false;

  TimerMode get _mode => widget.config.mode;
  bool get _isMultiStep =>
      _mode == TimerMode.tabata || _mode == TimerMode.interval || _mode == TimerMode.emom;

  @override
  void initState() {
    super.initState();
    _services = AppScope.of(context);
    final settings = _services.settings.value;
    _runner = WorkoutRunner(
      config: widget.config,
      steps: buildSteps(widget.config, prepareSec: settings.prepareSec),
      countdownBeeps: settings.countdownBeeps,
      halfwayAlert: settings.halfwayAlert,
      onCue: _onCue,
    )..addListener(_onRunnerChanged);
    if (settings.keepScreenOn) _setWakelock(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runner.start());
  }

  @override
  void dispose() {
    _setWakelock(false);
    _services.cues.stopVoice();
    _runner.dispose();
    super.dispose();
  }

  void _setWakelock(bool on) =>
      WakelockPlus.toggle(enable: on).catchError((Object e) => debugPrint('wakelock: $e'));

  void _onCue(WorkoutCue cue) => _services.cues.handle(cue, mode: _mode, muted: _muted);

  void _onRunnerChanged() {
    if (!_runner.isFinished || _handledFinish) return;
    _handledFinish = true;

    if (_mode == TimerMode.rest) {
      // Rest timer stays open with "다시 / 닫기"; it is not logged.
      if (!_runner.completed) Navigator.pop(context);
      return;
    }

    final record = _buildRecord();
    if (!_runner.completed && record.activeMs < 30000) {
      Navigator.pop(context);
      return;
    }
    _services.history.add(record);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => SummaryPage(record: record),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  WorkoutRecord _buildRecord() {
    final phaseMs = _runner.phaseTimeMs;
    final startedAt = _runner.startedAt ?? DateTime.now();
    return WorkoutRecord(
      id: 'w${startedAt.microsecondsSinceEpoch}',
      name: widget.config.name,
      mode: _mode,
      startedAt: startedAt,
      activeMs: _runner.activeMs - (phaseMs[Phase.prepare] ?? 0),
      completed: _runner.completed,
      workRounds: _runner.completedWorkRounds,
      amrapRounds: _runner.amrapRounds,
      laps: _runner.laps,
      kcal: estimateKcal(phaseMs, _services.settings.value.weightKg),
    );
  }

  Future<void> _confirmStop() async {
    if (_runner.isFinished) {
      Navigator.pop(context);
      return;
    }
    final willRecord = _mode != TimerMode.rest && _runner.activeMs >= 30000;
    final ok = await showConfirmDialog(
      context,
      title: '운동을 종료할까요?',
      message: willRecord ? '지금까지 한 운동은 기록에 남아요.' : null,
      confirmLabel: '종료',
    );
    if (!ok || !mounted) return;
    _services.cues.stopVoice();
    _runner.finish(completed: false);
  }

  void _restartRest() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => WorkoutPage(config: widget.config),
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ListenableBuilder(
          listenable: _runner,
          builder: (context, _) {
            final restDone = _mode == TimerMode.rest && _runner.isFinished;
            final base = restDone ? AppColors.rest : AppColors.phase(_runner.current.phase);
            final bg = Color.lerp(base, Colors.black, _runner.isPaused ? 0.62 : 0.2)!;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              color: bg,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(child: _buildBody(restDone, base)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(bool restDone, Color base) {
    final step = _runner.current;
    return Column(
      children: [
        _TopBar(
          title: widget.config.name,
          muted: _muted,
          onClose: _confirmStop,
          onToggleMute: () {
            setState(() => _muted = !_muted);
            if (_muted) _services.cues.stopVoice();
          },
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showSets = widget.config.sets > 1 && step.totalSets > 1 && _isMultiStep;
              // Title (~42) + gap + subtitle slot (32) + set line, rest is ring.
              final reserved = 80.0 + (showSets ? 36 : 0);
              final ring = math.max(
                120.0,
                math.min(constraints.maxWidth * 0.78, (constraints.maxHeight - reserved) / 1.06),
              );
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      restDone ? '휴식 끝!' : _phaseTitle(step),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Fixed slot so pausing never shifts the layout.
                    SizedBox(
                      height: 32,
                      width: constraints.maxWidth - 40,
                      child: Center(
                        child: _runner.isPaused
                            ? const _PausedBadge()
                            : Text(
                                restDone ? '다음 세트를 시작하세요' : _phaseSubtitle(step),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: ring * 0.06),
                    _Ring(
                      size: ring,
                      progress: restDone ? 0 : _ringProgress(step),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: ring * 0.78,
                            // Sized to the ring; long times shrink, short ones
                            // never grow past it.
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                restDone ? '0' : _timeText(step),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ring * 0.4,
                                  fontWeight: FontWeight.w800,
                                  height: 1.0,
                                  fontFeatures: tabularFigures,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            restDone ? '' : _ringCaption(step),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showSets) ...[
                      const SizedBox(height: 14),
                      Text(
                        '세트 ${step.set} / ${step.totalSets}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(height: 84, child: Center(child: _buildAction(step, restDone, base))),
        ),
        if (_isMultiStep) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _Timeline(runner: _runner),
          ),
        ],
        if (!restDone) _buildTotals(),
        if (!restDone) _buildControls(base) else const SizedBox(height: 24),
      ],
    );
  }

  // --- Texts ---------------------------------------------------------------

  String _phaseTitle(IntervalStep step) {
    if (step.phase != Phase.work) return step.phase.label;
    return switch (_mode) {
      TimerMode.emom => 'EMOM',
      TimerMode.amrap => 'AMRAP',
      TimerMode.forTime => 'FOR TIME',
      _ => '운동',
    };
  }

  String _phaseSubtitle(IntervalStep step) {
    switch (step.phase) {
      case Phase.prepare:
        final first = _runner.next?.label;
        return first == null ? '곧 시작해요' : '첫 운동 · $first';
      case Phase.work:
        if (step.label != null) return step.label!;
        if (step.isLastRound) return '마지막 라운드!';
        return _mode == TimerMode.forTime ? '최대한 빠르게' : '힘내요!';
      case Phase.rest:
      case Phase.setRest:
        final upcoming = _runner.next;
        if (upcoming?.phase == Phase.work && upcoming?.label != null) {
          return '다음 · ${upcoming!.label}';
        }
        return '호흡을 가다듬어요';
      case Phase.warmup:
        return '가볍게 몸을 풀어요';
      case Phase.cooldown:
        return '천천히 정리해요';
    }
  }

  String _timeText(IntervalStep step) {
    if (step.countUp) return formatElapsedMs(_runner.stepElapsedMs);
    final sec = (_runner.stepRemainingMs! / 1000).ceil();
    // Short intervals read better as a bare number: "17" rather than "0:17".
    if (step.durationMs! <= 60000 && sec < 60) return '$sec';
    return formatClock(sec);
  }

  String _ringCaption(IntervalStep step) {
    switch (step.phase) {
      case Phase.prepare:
        return '시작까지';
      case Phase.setRest:
        return '세트 ${step.set} 완료';
      case Phase.warmup:
      case Phase.cooldown:
        return '남은 시간';
      case Phase.rest:
        if (_mode == TimerMode.rest) return '남은 휴식';
        return '라운드 ${step.round} / ${step.totalRounds}';
      case Phase.work:
        return switch (_mode) {
          TimerMode.amrap => '남은 시간',
          TimerMode.forTime =>
            step.durationMs == null ? '경과 시간' : '타임캡 ${formatClock(step.durationMs! ~/ 1000)}',
          _ => '라운드 ${step.round} / ${step.totalRounds}',
        };
    }
  }

  double _ringProgress(IntervalStep step) {
    if (step.durationMs == null) return (_runner.stepElapsedMs % 60000) / 60000;
    return step.countUp ? _runner.stepProgress : 1 - _runner.stepProgress;
  }

  String _describe(IntervalStep s) {
    final d = s.durationMs == null ? '' : ' ${formatClock(s.durationMs! ~/ 1000)}';
    return switch (s.phase) {
      Phase.work => switch (_mode) {
        TimerMode.amrap => 'AMRAP$d',
        TimerMode.forTime => s.label ?? 'For Time',
        TimerMode.emom => '${s.round}라운드${s.label != null ? ' · ${s.label}' : ''}',
        _ => '${s.label ?? '운동'}$d',
      },
      _ => '${s.phase.label}$d',
    };
  }

  // --- Sections ------------------------------------------------------------

  Widget _buildAction(IntervalStep step, bool restDone, Color base) {
    if (restDone) {
      return Row(
        children: [
          Expanded(
            child: _GlassButton(label: '닫기', onTap: () => Navigator.pop(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GlassButton(
              label: '다시 휴식',
              icon: Icons.replay_rounded,
              solid: true,
              foreground: base,
              onTap: _restartRest,
            ),
          ),
        ],
      );
    }
    final isMain = step.phase != Phase.prepare;
    if (isMain && _mode == TimerMode.amrap) {
      return _RoundCounter(
        rounds: _runner.amrapRounds,
        color: base,
        onAdd: () {
          HapticFeedback.mediumImpact();
          _runner.addRound();
        },
        onUndo: _runner.undoRound,
      );
    }
    if (isMain && _mode == TimerMode.forTime) {
      final laps = _runner.laps;
      return Row(
        children: [
          Expanded(
            child: _GlassButton(
              label: laps.isEmpty ? '랩' : '랩 ${laps.length} · ${formatLapMs(laps.last)}',
              icon: Icons.flag_outlined,
              onTap: () {
                HapticFeedback.mediumImpact();
                _runner.lap();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GlassButton(
              label: '완료',
              icon: Icons.check_rounded,
              solid: true,
              foreground: base,
              onTap: () => _runner.finish(completed: true),
            ),
          ),
        ],
      );
    }
    if (isMain && _mode == TimerMode.rest) {
      return _GlassButton(
        label: '+15초',
        icon: Icons.more_time_rounded,
        onTap: () => _runner.addTime(const Duration(seconds: 15)),
      );
    }
    final upcoming = _runner.next;
    return _InfoPill(text: upcoming == null ? '마지막이에요. 끝까지!' : '다음  ·  ${_describe(upcoming)}');
  }

  Widget _buildTotals() {
    final steps = _runner.steps;
    final prep = steps.first.phase == Phase.prepare ? steps.first.durationMs! : 0;
    final elapsed = math.max(0, _runner.positionMs - prep);
    final remaining = _runner.totalRemainingMs;
    final style = TextStyle(
      color: Colors.white.withValues(alpha: 0.85),
      fontSize: 15,
      fontWeight: FontWeight.w600,
      fontFeatures: tabularFigures,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Row(
        children: [
          Text('경과 ${formatElapsedMs(elapsed)}', style: style),
          const Spacer(),
          if (remaining != null && _mode != TimerMode.rest)
            Text('남은 ${formatRemainingMs(remaining)}', style: style),
        ],
      ),
    );
  }

  Widget _buildControls(Color base) {
    final preparing = _runner.current.phase == Phase.prepare;
    final canSkip = _isMultiStep || preparing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundIconButton(
            icon: Icons.skip_previous_rounded,
            tooltip: '이전',
            visible: _isMultiStep,
            onTap: _runner.skipPrevious,
          ),
          Semantics(
            button: true,
            label: _runner.isPaused ? '재개' : '일시정지',
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _runner.togglePause();
                },
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: Icon(
                    _runner.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 48,
                    color: base,
                  ),
                ),
              ),
            ),
          ),
          _RoundIconButton(
            icon: Icons.skip_next_rounded,
            tooltip: preparing ? '바로 시작' : '다음',
            visible: canSkip,
            onTap: _runner.skipNext,
          ),
        ],
      ),
    );
  }
}

// --- Pieces ----------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.muted,
    required this.onClose,
    required this.onToggleMute,
  });

  final String title;
  final bool muted;
  final VoidCallback onClose;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: '종료',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: muted ? '소리 켜기' : '소리 끄기',
            onPressed: onToggleMute,
            icon: Icon(
              muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _PausedBadge extends StatelessWidget {
  const _PausedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '일시정지',
        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.progress, required this.child});

  final double size;
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (progress <= 0) return;
    final arc = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

/// Every interval as a bar; work bars are taller. Filled = done.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.runner});

  final WorkoutRunner runner;

  @override
  Widget build(BuildContext context) {
    final steps = runner.steps;
    final first = steps.first.phase == Phase.prepare ? 1 : 0;
    final gap = steps.length - first > 40 ? 1.0 : 2.0;
    return SizedBox(
      height: 10,
      child: Row(
        children: [
          for (var i = first; i < steps.length; i++)
            Expanded(
              flex: math.max(1, (steps[i].durationMs ?? 0) ~/ 1000),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: gap / 2),
                child: _Segment(
                  isWork: steps[i].phase == Phase.work,
                  fill: i < runner.index
                      ? 1
                      : i == runner.index
                      ? runner.stepProgress
                      : 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.isWork, required this.fill});

  final bool isWork;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: isWork ? 10 : 5,
          color: Colors.white.withValues(alpha: isWork ? 0.3 : 0.18),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fill,
            heightFactor: 1,
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.solid = false,
    this.foreground,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool solid;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? (foreground ?? AppColors.bg) : Colors.white;
    return Material(
      color: solid ? Colors.white : Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, color: fg, size: 24), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AMRAP: one big target to tap after every round.
class _RoundCounter extends StatelessWidget {
  const _RoundCounter({
    required this.rounds,
    required this.color,
    required this.onAdd,
    required this.onUndo,
  });

  final int rounds;
  final Color color;
  final VoidCallback onAdd;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: '라운드 취소',
          onPressed: rounds > 0 ? onUndo : null,
          icon: const Icon(Icons.undo_rounded),
          color: Colors.white,
          disabledColor: Colors.white.withValues(alpha: 0.3),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onAdd,
              child: SizedBox(
                height: 72,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '라운드',
                        style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$rounds',
                        style: TextStyle(
                          color: color,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '+1',
                        style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 52),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.visible,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: visible
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
