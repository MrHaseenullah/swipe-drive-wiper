import 'package:flutter/material.dart';

/// A simple widget that displays a barcode-like pattern
class BarcodeWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color barColor;
  
  const BarcodeWidget({
    super.key,
    this.width = 300,
    this.height = 100,
    this.backgroundColor = Colors.white,
    this.barColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: CustomPaint(
        painter: BarcodePainter(barColor: barColor),
        size: Size(width, height),
      ),
    );
  }
}

/// A custom painter that draws a barcode-like pattern
class BarcodePainter extends CustomPainter {
  final Color barColor;
  
  BarcodePainter({this.barColor = Colors.black});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..strokeWidth = 2.0;
    
    // Draw barcode-like lines
    double x = 10;
    while (x < size.width - 10) {
      final lineWidth = (x % 7 == 0) ? 4.0 : 2.0;
      canvas.drawLine(
        Offset(x, 10),
        Offset(x, size.height - 10),
        paint..strokeWidth = lineWidth,
      );
      x += (x % 5 == 0) ? 8.0 : 4.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
