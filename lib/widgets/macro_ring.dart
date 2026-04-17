import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class MacroRing extends StatelessWidget {
  final double consumed;
  final double target;
  final double size;
  final String unit;
  final String label;

  const MacroRing({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 180,
    this.unit = 'kcal',
    this.label = 'CALORIES',
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (target - consumed).clamp(0, double.infinity);
    final pct = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.2);
    final color = pct > 1.05
        ? AppColors.danger
        : pct > 0.9
            ? AppColors.warn
            : AppColors.accent;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(pct: pct.toDouble(), color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: size * 0.055,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  )),
              const SizedBox(height: 4),
              Text(remaining.round().toString(),
                  style: TextStyle(
                    fontSize: size * 0.30,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.0,
                  )),
              Text('left · $unit',
                  style: TextStyle(
                    fontSize: size * 0.06,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 4),
              Text(
                '${consumed.round()} / ${target.round()}',
                style: TextStyle(
                  fontSize: size * 0.06,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  _RingPainter({required this.pct, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.width * 0.09;
    final rect = Rect.fromCircle(
      center: center, radius: size.width / 2 - stroke / 2);

    final bg = Paint()
      ..color = AppColors.border
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, size.width / 2 - stroke / 2, bg);

    final fg = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color.withValues(alpha: 0.75), color],
      ).createShader(rect)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * pct.clamp(0.0, 1.0),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.pct != pct || old.color != color;
}

class MacroBar extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final Color color;
  final String unit;
  const MacroBar({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final pct = target == 0 ? 0.0 : (consumed / target).clamp(0.0, 1.2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      )),
            ),
            Text('${consumed.round()} / ${target.round()} $unit',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: pct.clamp(0.0, 1.0).toDouble(),
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
