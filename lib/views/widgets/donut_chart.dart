import 'package:flutter/material.dart';
import 'dart:math' as math;

class DonutChart extends StatelessWidget {
  final double value;
  final double total;
  final Color color;
  final String centerLabel;
  final String centerValue;
  final String legendLabel;
  final String legendValue;

  const DonutChart({
    super.key,
    required this.value,
    required this.total,
    required this.color,
    required this.centerLabel,
    required this.centerValue,
    required this.legendLabel,
    required this.legendValue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    final sweepAngle = (percentage / 100) * 2 * math.pi;

    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Donut chart
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    sweepAngle: sweepAngle,
                    color: color,
                  ),
                ),
              ),
              // Center text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    centerLabel,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    centerValue,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$legendLabel (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(width: 8),
            Text(
              legendValue,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double sweepAngle;
  final Color color;

  DonutChartPainter({required this.sweepAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 40) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
