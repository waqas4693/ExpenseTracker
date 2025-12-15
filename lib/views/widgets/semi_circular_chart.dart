import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/config/app_config.dart';

class CategoryData {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  CategoryData({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class SemiCircularChart extends StatelessWidget {
  final List<CategoryData> categories;
  final double size;

  const SemiCircularChart({
    super.key,
    required this.categories,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by percentage descending
    final sortedCategories = List<CategoryData>.from(categories)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    // Generate colors for categories
    final colors = _generateColors(sortedCategories.length);

    return Column(
      children: [
        // Chart
        SizedBox(
          width: size,
          height: size / 2,
          child: CustomPaint(
            painter: _SemiCircularChartPainter(
              categories: sortedCategories,
              colors: colors,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Legend
        Column(
          children: sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final color = colors[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConfig.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Color> _generateColors(int count) {
    if (count == 0) return [];
    if (count == 1) return [AppConfig.primaryColor];
    if (count == 2) {
      return [AppConfig.primaryColor, AppConfig.primaryLightColor];
    }

    // Generate shades of blue for multiple categories
    final colors = <Color>[];
    final baseColor = AppConfig.primaryColor;
    final step = 0.3 / (count - 1);

    for (int i = 0; i < count; i++) {
      final factor = 1.0 - (step * i);
      colors.add(
        Color.fromRGBO(
          ((baseColor.r * 255.0) * factor).round(),
          ((baseColor.g * 255.0) * factor).round(),
          ((baseColor.b * 255.0) * factor).round(),
          1.0,
        ),
      );
    }

    return colors;
  }
}

class _SemiCircularChartPainter extends CustomPainter {
  final List<CategoryData> categories;
  final List<Color> colors;

  _SemiCircularChartPainter({required this.categories, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (categories.isEmpty) return;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Draw semi-circle segments
    double startAngle = math.pi; // Start from left (180 degrees)

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final sweepAngle = (category.percentage / 100) * math.pi;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(center.dx, center.dy)
        ..close();

      canvas.drawPath(path, paint);

      // Draw percentage text on segment
      if (category.percentage > 5) {
        // Only show percentage if segment is large enough
        final textAngle = startAngle + (sweepAngle / 2);
        final textRadius = radius * 0.7;
        final textX = center.dx + math.cos(textAngle) * textRadius;
        final textY = center.dy + math.sin(textAngle) * textRadius;

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${category.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.15, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
