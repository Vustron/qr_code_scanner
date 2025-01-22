import 'package:flutter/material.dart';

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double scanAreaSize = 250;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path scanPath = Path()..addRect(scanRect);
    final Path finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      scanPath,
    );

    canvas.drawPath(
      finalPath,
      Paint()..color = Colors.black.withOpacity(0.5),
    );
    canvas.drawRect(scanRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
