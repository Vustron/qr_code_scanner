import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedScannerOverlay extends HookWidget {
  const AnimatedScannerOverlay({
    super.key,
    required this.qrDetected,
  });

  final bool qrDetected;

  @override
  Widget build(BuildContext context) {
    final AnimationController scanLinePosition = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    final AnimationController pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    useEffect(() {
      scanLinePosition.repeat(reverse: true);
      pulseController.repeat();
      return () {
        scanLinePosition.dispose();
        pulseController.dispose();
      };
    }, const <Object?>[]);

    return CustomPaint(
      painter: ScannerOverlay(
        scanLinePosition: scanLinePosition,
        pulseProgress: pulseController,
        isDetected: qrDetected,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay({
    required this.scanLinePosition,
    required this.pulseProgress,
    required this.isDetected,
  }) : super(
            repaint: Listenable.merge(
                <Listenable?>[scanLinePosition, pulseProgress]));

  final Animation<double> scanLinePosition;
  final Animation<double> pulseProgress;
  final bool isDetected;

  @override
  void paint(Canvas canvas, Size size) {
    final Color borderColor = isDetected ? Colors.green : Colors.white;
    final double opacity = (1 - pulseProgress.value) * 0.8;

    final Paint borderPaint = Paint()
      ..color = borderColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const double scanAreaSize = 280.0;
    const double cornerRadius = 12.0;
    const double cornerSize = 30.0;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    final RRect roundedScanRect = RRect.fromRectAndRadius(
      scanRect,
      const Radius.circular(cornerRadius),
    );

    // Draw guidelines with grid pattern
    final Paint guidelinePaint = Paint()
      ..color = borderColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw grid lines
    const int gridLines = 4;
    const double spacing = scanAreaSize / gridLines;
    for (int i = 1; i < gridLines; i++) {
      final double pos = scanRect.left + (spacing * i);
      canvas.drawLine(
        Offset(pos, scanRect.top),
        Offset(pos, scanRect.bottom),
        guidelinePaint,
      );
      canvas.drawLine(
        Offset(scanRect.left, scanRect.top + (spacing * i)),
        Offset(scanRect.right, scanRect.top + (spacing * i)),
        guidelinePaint,
      );
    }

    // Draw scan line with enhanced glow
    if (!isDetected) {
      final Paint scanLinePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            borderColor.withOpacity(0),
            borderColor.withOpacity(0.8),
            borderColor.withOpacity(0),
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ).createShader(scanRect);

      final double scanLineY =
          scanRect.top + (scanRect.height * scanLinePosition.value);

      // Enhanced scan line glow
      canvas.drawLine(
        Offset(scanRect.left + 10, scanLineY),
        Offset(scanRect.right - 10, scanLineY),
        Paint()
          ..color = borderColor.withOpacity(0.4)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      canvas.drawLine(
        Offset(scanRect.left + 10, scanLineY),
        Offset(scanRect.right - 10, scanLineY),
        scanLinePaint..strokeWidth = 2,
      );
    }

    // Complete corner markers
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

    // Draw corner glows and borders
    final Paint glowPaint = Paint()
      ..color = borderColor.withOpacity(opacity)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final List<Offset> corner in corners) {
      canvas.drawPoints(PointMode.lines, corner, glowPaint);
      canvas.drawPoints(PointMode.lines, corner, borderPaint);
    }

    // Enhanced success indicator
    if (isDetected) {
      canvas.drawRRect(
        roundedScanRect,
        Paint()
          ..color = Colors.green.withOpacity(0.2)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlay oldDelegate) {
    return oldDelegate.scanLinePosition != scanLinePosition ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.isDetected != isDetected;
  }
}
