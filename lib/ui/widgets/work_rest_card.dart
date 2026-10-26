import 'package:flutter/material.dart';

import '../../models/timer_mode.dart';
import '../../models/workout_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'common.dart';
import 'config_fields.dart';
import 'value_tile.dart';

const _mint = Color(0xFF2DD4BF);

/// The setup tiles for [config]: work and rest share one card with a live
/// ratio bar (interval modes), everything else goes in the grid.
class ConfigPanel extends StatelessWidget {
  const ConfigPanel({super.key, required this.config, required this.onChanged});

  final WorkoutConfig config;
  final void Function(WorkoutConfig updated) onChanged;

  @override
  Widget build(BuildContext context) {
    final fields = configFields(config, onChanged);
    final paired = config.mode == TimerMode.tabata || config.mode == TimerMode.interval;
    if (!paired) return ConfigGrid(fields: fields);
    return Column(
      children: [
        WorkRestCard(work: fields[0], rest: fields[1]),
        const SizedBox(height: 10),
        ConfigGrid(fields: fields.sublist(2)),
      ],
    );
  }
}

/// 운동 and 휴식 as one unit, with the ratio between them drawn on top.
class WorkRestCard extends StatelessWidget {
  const WorkRestCard({super.key, required this.work, required this.rest});

  final ConfigField work;
  final ConfigField rest;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          _RatioHeader(work: work.value, rest: rest.value),
          const SizedBox(height: 8),
          RatioBar(work: work.value, rest: rest.value),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ValueTile(field: work, bare: true)),
                const VerticalDivider(width: 28, thickness: 1, color: AppColors.border),
                Expanded(child: ValueTile(field: rest, bare: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "2 : 1" when the numbers reduce nicely, otherwise "2.8 : 1".
String ratioLabel(int work, int rest) {
  if (rest == 0) return '휴식 없음';
  int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
  final g = gcd(work, rest);
  final a = work ~/ g, b = rest ~/ g;
  if (a <= 12 && b <= 12) return '$a : $b';
  final r = work / rest;
  return r >= 1 ? '${r.toStringAsFixed(1)} : 1' : '1 : ${(1 / r).toStringAsFixed(1)}';
}

class _RatioHeader extends StatelessWidget {
  const _RatioHeader({required this.work, required this.rest});

  final int work;
  final int rest;

  @override
  Widget build(BuildContext context) {
    final total = work + rest;
    final workPct = total == 0 ? 100 : (work * 100 / total).round();
    const label = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFeatures: tabularFigures,
    );
    return Row(
      children: [
        Text('운동 $workPct%', style: label),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey(ratioLabel(work, rest)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ratioLabel(work, rest),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
        ),
        const Spacer(),
        Text('휴식 ${100 - workPct}%', style: label),
      ],
    );
  }
}

/// One continuous gradient — indigo → azure for work, blending into
/// teal → mint for rest — with the split sliding when values change, a
/// glowing knob at the split that bounces on change, and a soft sheen that
/// sweeps across whenever the ratio changes.
class RatioBar extends StatefulWidget {
  const RatioBar({super.key, required this.work, required this.rest});

  final int work;
  final int rest;

  @override
  State<RatioBar> createState() => _RatioBarState();
}

class _RatioBarState extends State<RatioBar> with SingleTickerProviderStateMixin {
  // One sweep when the bar appears and on every change — no idle animation,
  // so the screen can rest.
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sheen.isAnimating && _sheen.value == 0) _sweep();
  }

  @override
  void didUpdateWidget(RatioBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.work != widget.work || oldWidget.rest != widget.rest) _sweep();
  }

  void _sweep() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _sheen.forward(from: 0);
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  double get _fraction {
    final total = widget.work + widget.rest;
    return total == 0 ? 1 : widget.work / total;
  }

  @override
  Widget build(BuildContext context) {
    const barHeight = 12.0;
    const knob = 16.0;
    return Semantics(
      label: '운동 ${widget.work}초, 휴식 ${widget.rest}초, 비율 ${ratioLabel(widget.work, widget.rest)}',
      child: ExcludeSemantics(
        child: SizedBox(
          height: knob + 4,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _fraction),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, f, _) => LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final split = width * f;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      height: barHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(barHeight / 2),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(decoration: BoxDecoration(gradient: _gradient(f))),
                            AnimatedBuilder(
                              animation: _sheen,
                              builder: (context, _) => DecoratedBox(
                                decoration: BoxDecoration(gradient: _sheenAt(_sheen.value)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (f < 0.999)
                      Positioned(
                        left: (split - knob / 2).clamp(0, width - knob),
                        child: TweenAnimationBuilder<double>(
                          // A new key restarts the bounce whenever the ratio changes.
                          key: ValueKey(_fraction),
                          tween: Tween(begin: 1.35, end: 1),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Container(
                            width: knob,
                            height: knob,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surface, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentAlt.withValues(alpha: 0.7),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Blue for the work share, teal for the rest share, blended over a
  /// short band at the split so the two read as one bar.
  LinearGradient _gradient(double f) {
    if (f >= 0.999) {
      return const LinearGradient(colors: [AppColors.accentDeep, AppColors.accent]);
    }
    const blend = 0.06;
    final a = (f - blend).clamp(0.0, 1.0);
    final b = (f + blend).clamp(0.0, 1.0);
    return LinearGradient(
      colors: const [AppColors.accentDeep, AppColors.accent, AppColors.rest, _mint],
      stops: [0, a, b, 1],
    );
  }

  /// A narrow highlight crossing left to right.
  LinearGradient _sheenAt(double t) {
    final p = t * 1.4 - 0.2; // starts and ends just off the bar
    final s = [p - 0.12, p, p + 0.12].map((v) => v.clamp(0.0, 1.0)).toList();
    return LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.32),
        Colors.white.withValues(alpha: 0),
      ],
      stops: s,
    );
  }
}
