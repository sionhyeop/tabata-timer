import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A one-shot burst that drifts down and settles near the top of the
/// screen, like the dots above the reference alarm list.
class Confetti extends StatefulWidget {
  const Confetti({super.key});

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  late final List<_Piece> _pieces = _generate();

  static const _colors = [
    AppColors.accent,
    AppColors.accentOrange,
    AppColors.prepare,
    AppColors.rest,
    AppColors.setRest,
    AppColors.warmCool,
    Colors.white,
  ];

  List<_Piece> _generate() {
    final random = math.Random(7);
    return List.generate(80, (_) {
      return _Piece(
        x: random.nextDouble(),
        startY: -0.05 - random.nextDouble() * 0.25,
        endY: random.nextDouble() * 0.38,
        drift: (random.nextDouble() - 0.5) * 0.08,
        size: 3 + random.nextDouble() * 4,
        color: _colors[random.nextInt(_colors.length)],
        isDot: random.nextBool(),
        spin: random.nextDouble() * math.pi,
        delay: random.nextDouble() * 0.3,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          CustomPaint(painter: _ConfettiPainter(_pieces, _controller.value), size: Size.infinite),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.startY,
    required this.endY,
    required this.drift,
    required this.size,
    required this.color,
    required this.isDot,
    required this.spin,
    required this.delay,
  });

  final double x;
  final double startY;
  final double endY;
  final double drift;
  final double size;
  final Color color;
  final bool isDot;
  final double spin;
  final double delay;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      final eased = Curves.easeOutCubic.transform(local);
      final y = (p.startY + (p.endY - p.startY) * eased) * size.height;
      final x = (p.x + p.drift * math.sin(local * math.pi * 2)) * size.width;
      paint.color = p.color.withValues(alpha: 0.9);
      if (p.isDot) {
        canvas.drawCircle(Offset(x, y), p.size / 2, paint);
      } else {
        canvas
          ..save()
          ..translate(x, y)
          ..rotate(p.spin + local * math.pi * 3);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size * 1.6, height: p.size * 0.7),
            const Radius.circular(1),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
