import 'dart:math';
import 'dart:ui';

double calculateQRSize(List<Point<int>> corners) {
  if (corners.length < 4) return 0;

  final double width = (corners[1].x - corners[0].x).abs().toDouble();
  final double height = (corners[2].y - corners[1].y).abs().toDouble();

  return (width + height) / 2;
}

double calculateZoomLevel(double qrSize) {
  const double minZoom = 0.0;
  const double maxZoom = 1.0;
  const double targetSize = 200.0;

  if (qrSize <= 0) return minZoom;

  final double zoomFactor = (targetSize / qrSize).clamp(minZoom, maxZoom);
  return zoomFactor;
}

double calculateScannerSize(List<Offset> corners) {
  if (corners.isEmpty) return 280.0;

  double minX = double.infinity;
  double maxX = -double.infinity;
  double minY = double.infinity;
  double maxY = -double.infinity;

  for (final Offset corner in corners) {
    minX = min(minX, corner.dx);
    maxX = max(maxX, corner.dx);
    minY = min(minY, corner.dy);
    maxY = max(maxY, corner.dy);
  }

  final double width = maxX - minX;
  final double height = maxY - minY;

  return max(width, height) * 1.2;
}
