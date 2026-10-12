import 'package:flutter/material.dart';

/// Ultra-lightweight, 60fps CustomPainter for responsive market sparklines
class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;
  final bool showGradient;

  const SparklineChart({
    super.key,
    required this.data,
    Color? color,
    Color? lineColor,
    this.width = 72,
    this.height = 28,
    this.showGradient = true,
  }) : color = color ?? lineColor ?? const Color(0xFFF0B90B);

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return SizedBox(width: width, height: height);
    }
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: _SparklinePainter(
          data: data,
          lineColor: color,
          showGradient: showGradient,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final bool showGradient;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.showGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    double minVal = data.reduce((a, b) => a < b ? a : b);
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    if (range == 0) range = 1.0;

    final path = Path();
    final gradientPath = Path();

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalized = (data[i] - minVal) / range;
      // Invert Y because canvas Y points downwards
      final y = size.height - (normalized * (size.height - 4)) - 2;

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    // Fill gradient
    if (showGradient) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withOpacity(0.28),
            lineColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
      canvas.drawPath(gradientPath, fillPaint);
    }

    // Stroke line
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.75
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
