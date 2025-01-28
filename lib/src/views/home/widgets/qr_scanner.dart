import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class QRScanner extends StatelessWidget {
  const QRScanner({
    super.key,
    required this.scannerKey,
    required this.scannerController,
    required this.onDetect,
  });

  final ValueNotifier<UniqueKey> scannerKey;
  final MobileScannerController scannerController;
  final Future<void> Function(BarcodeCapture capture) onDetect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: MobileScanner(
              key: scannerKey.value,
              controller: scannerController,
              onDetect: onDetect,
              errorBuilder: (BuildContext context, MobileScannerException error,
                  Widget? child) {
                return const ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Camera error',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
