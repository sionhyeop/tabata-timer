import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A slow blue ↔ violet glow behind the main screens.
///
/// Two soft light pools drift and change hue over [_period]. Because the
/// change is so slow, it repaints only ~12 times a second, and stops while
/// the app is in the background or the user asked for reduced motion.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child});

  final Widget child;

  /// Off in tests, where an endless animation would never settle.
  static bool motion = true;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground> with WidgetsBindingObserver {
  static const _period = Duration(seconds: 24);
  static const _frame = Duration(milliseconds: 83);

  final _t = ValueNotifier<double>(0.15);
  final _clock = Stopwatch();
  Timer? _timer;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _reducedMotion ? _stop() : _start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    state == AppLifecycleState.resumed && !_reducedMotion ? _start() : _stop();
  }

  void _start() {
    if (!AuroraBackground.motion || _timer != null) return;
    _clock.start();
    _timer = Timer.periodic(_frame, (_) {
      _t.value = (_clock.elapsedMilliseconds % _period.inMilliseconds) / _period.inMilliseconds;
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _clock.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _AuroraPainter(_t))),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t) : super(repaint: t);

  final ValueListenable<double> t;

  static const _hues = [AppColors.accentDeep, Color(0xFF8B5CF6), AppColors.accent];

  /// Eases around the hue cycle so no color lingers or snaps.
  static Color _cycle(double v) {
    final pos = (v % 1) * _hues.length;
    final i = pos.floor();
    final f = pos - i;
    final eased = f * f * (3 - 2 * f);
    return Color.lerp(_hues[i % _hues.length], _hues[(i + 1) % _hues.length], eased)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.bg);
    final v = t.value;
    final a = v * math.pi * 2;
    _glow(
      canvas,
      center: Offset(
        size.width * (0.3 + 0.25 * math.sin(a)),
        size.height * (0.02 + 0.04 * math.cos(a)),
      ),
      radius: size.width * 1.0,
      color: _cycle(v),
      opacity: 0.3,
    );
    _glow(
      canvas,
      center: Offset(
        size.width * (0.82 - 0.2 * math.sin(a + 1.3)),
        size.height * (0.4 + 0.06 * math.sin(a)),
      ),
      radius: size.width * 0.8,
      color: _cycle(v + 0.5),
      opacity: 0.13,
    );
  }

  void _glow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.35),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}
