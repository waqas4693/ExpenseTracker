import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

/// Reusable app logo widget
/// Can be used across the app for consistent branding
class AppLogo extends StatelessWidget {
  final double? size;
  final bool showText;
  final double spacing;

  const AppLogo({
    super.key,
    this.size,
    this.showText = true,
    this.spacing = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size ?? 100,
          height: size ?? 100,
          child: CustomPaint(painter: _MonexLogoPainter()),
        ),
        if (showText) ...[
          SizedBox(height: spacing),
          Text(
            AppConfig.appDisplayName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: AppConfig.textPrimaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the temporary Monex logo
/// Three parallel horizontal bars, angled upwards from left to right
/// Top and bottom bars are shorter, middle bar is longer
class _MonexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConfig.primaryColor
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final barHeight = 8.0;
    final angle = 0.15; // Slight upward angle

    // Top bar (shorter, angled up)
    final topBarWidth = 40.0;
    final topBarY = centerY - 20;
    final topBarPath = Path()
      ..moveTo(centerX - topBarWidth / 2, topBarY - barHeight / 2)
      ..lineTo(
        centerX + topBarWidth / 2 + (topBarY * angle),
        topBarY - barHeight / 2 + (topBarY * angle),
      )
      ..lineTo(
        centerX + topBarWidth / 2 + (topBarY * angle),
        topBarY + barHeight / 2 + (topBarY * angle),
      )
      ..lineTo(centerX - topBarWidth / 2, topBarY + barHeight / 2)
      ..close();
    canvas.drawPath(topBarPath, paint);

    // Middle bar (longer, angled up)
    final middleBarWidth = 60.0;
    final middleBarY = centerY;
    final middleBarPath = Path()
      ..moveTo(centerX - middleBarWidth / 2, middleBarY - barHeight / 2)
      ..lineTo(
        centerX + middleBarWidth / 2 + (middleBarY * angle),
        middleBarY - barHeight / 2 + (middleBarY * angle),
      )
      ..lineTo(
        centerX + middleBarWidth / 2 + (middleBarY * angle),
        middleBarY + barHeight / 2 + (middleBarY * angle),
      )
      ..lineTo(centerX - middleBarWidth / 2, middleBarY + barHeight / 2)
      ..close();
    canvas.drawPath(middleBarPath, paint);

    // Bottom bar (shorter, angled up)
    final bottomBarWidth = 40.0;
    final bottomBarY = centerY + 20;
    final bottomBarPath = Path()
      ..moveTo(centerX - bottomBarWidth / 2, bottomBarY - barHeight / 2)
      ..lineTo(
        centerX + bottomBarWidth / 2 + (bottomBarY * angle),
        bottomBarY - barHeight / 2 + (bottomBarY * angle),
      )
      ..lineTo(
        centerX + bottomBarWidth / 2 + (bottomBarY * angle),
        bottomBarY + barHeight / 2 + (bottomBarY * angle),
      )
      ..lineTo(centerX - bottomBarWidth / 2, bottomBarY + barHeight / 2)
      ..close();
    canvas.drawPath(bottomBarPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
