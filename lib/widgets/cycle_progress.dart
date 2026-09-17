import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Progresso da meta: roxo no início, azul no meio e verde ao concluir.
class CycleProgress extends StatelessWidget {
  final double value;
  const CycleProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final progress = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    return Semantics(
      label: 'Compatibilidade com seu objetivo',
      value: '${(progress * 100).round()}%',
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 700),
          builder: (context, current, _) {
            final color = current < 0.5
                ? Color.lerp(const Color(0xFF803DEB), const Color(0xFF2478E5),
                    current * 2)!
                : Color.lerp(const Color(0xFF2478E5), const Color(0xFF009E74),
                    (current - 0.5) * 2)!;
            return SizedBox.square(
              dimension: 106,
              child: CustomPaint(
                painter: _CyclePainter(current, color),
                child: Center(
                  child: Text('${(current * 100).round()}%',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: color)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CyclePainter extends CustomPainter {
  final double progress;
  final Color color;
  _CyclePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 12;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = const Color(0xFFE9E6F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    if (progress <= 0) return;
    const start = -math.pi / 2;
    // Um pequeno espaço mantém a seta visível mesmo com 100%.
    final sweep = progress * (2 * math.pi - 0.28);
    canvas.drawArc(bounds, start, sweep, false, track..color = color);
    final angle = start + sweep;
    final tip = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    final tangent = Offset(-math.sin(angle), math.cos(angle));
    final normal = Offset(math.cos(angle), math.sin(angle));
    final arrow = Path()
      ..moveTo((tip + tangent * 8).dx, (tip + tangent * 8).dy)
      ..lineTo((tip - tangent * 5 + normal * 7).dx,
          (tip - tangent * 5 + normal * 7).dy)
      ..lineTo((tip - tangent * 5 - normal * 7).dx,
          (tip - tangent * 5 - normal * 7).dy)
      ..close();
    canvas.drawPath(arrow, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CyclePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
