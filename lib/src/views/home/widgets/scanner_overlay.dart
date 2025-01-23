import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedScannerOverlay extends HookWidget {
  const AnimatedScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final AnimationController scanLinePosition = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    useEffect(() {
      scanLinePosition.repeat(reverse: true);
      return scanLinePosition.dispose;
    }, const <Object?>[]);

    return CustomPaint(
      painter: ScannerOverlay(scanLinePosition: scanLinePosition),
      child: const SizedBox.expand(),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({required this.scanLinePosition})
      : super(repaint: scanLinePosition);

  final Animation<double> scanLinePosition;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const double scanAreaSize = 280.0;
    const double cornerRadius = 12.0;
    const double cornerSize = 25.0;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw scan line with glow
    final Paint scanLinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0.8),
          Colors.white.withOpacity(0),
        ],
        stops: const <double>[0.0, 0.5, 1.0],
      ).createShader(scanRect);

    final double scanLineY =
        scanRect.top + (scanRect.height * scanLinePosition.value);

    // Add glow effect to scan line
    canvas.drawLine(
      Offset(scanRect.left + 10, scanLineY),
      Offset(scanRect.right - 10, scanLineY),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawLine(
      Offset(scanRect.left + 10, scanLineY),
      Offset(scanRect.right - 10, scanLineY),
      scanLinePaint..strokeWidth = 2,
    );

    // Draw corner markers
    final List<List<Offset>> corners = <List<Offset>>[
      // Top left
      <Offset>[
        Offset(scanRect.left, scanRect.top + cornerSize),
        Offset(scanRect.left, scanRect.top + cornerRadius),
        Offset(scanRect.left + cornerRadius, scanRect.top),
        Offset(scanRect.left + cornerSize, scanRect.top),
      ],
      // Top right
      <Offset>[
        Offset(scanRect.right - cornerSize, scanRect.top),
        Offset(scanRect.right - cornerRadius, scanRect.top),
        Offset(scanRect.right, scanRect.top + cornerRadius),
        Offset(scanRect.right, scanRect.top + cornerSize),
      ],
      // Bottom right
      <Offset>[
        Offset(scanRect.right, scanRect.bottom - cornerSize),
        Offset(scanRect.right, scanRect.bottom - cornerRadius),
        Offset(scanRect.right - cornerRadius, scanRect.bottom),
        Offset(scanRect.right - cornerSize, scanRect.bottom),
      ],
      // Bottom left
      <Offset>[
        Offset(scanRect.left + cornerSize, scanRect.bottom),
        Offset(scanRect.left + cornerRadius, scanRect.bottom),
        Offset(scanRect.left, scanRect.bottom - cornerRadius),
        Offset(scanRect.left, scanRect.bottom - cornerSize),
      ],
    ];

    // Draw glow behind corners
    final Paint glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final List<Offset> corner in corners) {
      canvas.drawPoints(PointMode.lines, corner, glowPaint);
      canvas.drawPoints(PointMode.lines, corner, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlay oldDelegate) =>
      oldDelegate.scanLinePosition != scanLinePosition;
}
