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

/// 운동 and 휴식 as one unit: the ratio bar on top, both values below, in a
/// card set slightly apart from the rest with a faint gradient edge.
class WorkRestCard extends StatelessWidget {
  const WorkRestCard({super.key, required this.work, required this.rest});

  final ConfigField work;
  final ConfigField rest;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentDeep.withValues(alpha: 0.6),
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.rest.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.2),
        child: AppCard(
          color: Color.alphaBlend(AppColors.accent.withValues(alpha: 0.06), palette.surface),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            children: [
              RatioBar(work: work.value, rest: rest.value),
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: ValueTile(field: work, bare: true)),
                    VerticalDivider(width: 28, thickness: 1, color: palette.border),
                    Expanded(child: ValueTile(field: rest, bare: true)),
                  ],
                ),
              ),
            ],
          ),
        ),
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

/// One continuous gradient — indigo → azure for work, blending into
/// teal → mint for rest — labelled inside with each share. The split slides
/// when values change, its marker bounces, and a soft sheen sweeps across.
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

  static const _barHeight = 26.0;
  static const _label = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    fontFeatures: tabularFigures,
    shadows: [Shadow(color: Color(0x40000000), blurRadius: 3)],
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
    final workPct = (_fraction * 100).round();
    return Semantics(
      label:
          '운동 ${widget.work}초 $workPct퍼센트, 휴식 ${widget.rest}초 ${100 - workPct}퍼센트, '
          '비율 ${ratioLabel(widget.work, widget.rest)}',
      child: ExcludeSemantics(
        child: SizedBox(
          height: _barHeight + 6,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _fraction),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, f, _) => LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final split = width * f;
                final restShown = widget.rest > 0;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      height: _barHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_barHeight / 2),
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
                            // Each share labelled inside its own part; text
                            // shortens, then hides, as a part narrows.
                            Positioned(
                              left: 12,
                              width: (split - 20).clamp(0, width),
                              top: 0,
                              bottom: 0,
                              child: _ShareLabel(
                                full: '운동 $workPct%',
                                short: '$workPct%',
                                align: Alignment.centerLeft,
                              ),
                            ),
                            Positioned(
                              right: 12,
                              width: restShown ? (width - split - 20).clamp(0, width) : width / 2,
                              top: 0,
                              bottom: 0,
                              child: _ShareLabel(
                                full: restShown ? '휴식 ${100 - workPct}%' : '휴식 없음',
                                short: restShown ? '${100 - workPct}%' : '',
                                align: Alignment.centerRight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (restShown) _marker(split, width),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// A slim glowing bar at the split that bounces when the ratio changes.
  Widget _marker(double split, double width) {
    const w = 4.0;
    return Positioned(
      left: (split - w / 2).clamp(0, width - w),
      top: 0,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        // A new key restarts the bounce whenever the ratio changes.
        key: ValueKey(_fraction),
        tween: Tween(begin: 1.4, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, scale, child) => Transform.scale(scaleY: scale, scaleX: 1, child: child),
        child: Container(
          width: w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentAlt.withValues(alpha: 0.8),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
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

/// Picks the longest of [full] / [short] that fits, or nothing.
class _ShareLabel extends StatelessWidget {
  const _ShareLabel({required this.full, required this.short, required this.align});

  final String full;
  final String short;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double widthOf(String text) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: _RatioBarState._label),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          return painter.width;
        }

        final available = constraints.maxWidth;
        final text = widthOf(full) <= available
            ? full
            : (short.isNotEmpty && widthOf(short) <= available ? short : null);
        if (text == null) return const SizedBox.shrink();
        return Align(
          alignment: align,
          child: Text(text, maxLines: 1, softWrap: false, style: _RatioBarState._label),
        );
      },
    );
  }
}
