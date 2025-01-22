import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/views.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> showScanner = useState(true);
    final ValueNotifier<String?> scanResult = useState<String?>(null);

    final Null Function() initScanning = useCallback(() {
      ref.read(audioPlayerControllerProvider).startScanning().run().then(
            (Either<String, Unit> either) => either.match(
              (String error) =>
                  debugPrint('Error initializing scanner: $error'),
              (_) => null,
            ),
          );
    }, <Object?>[]);

    final Future<void> Function(BarcodeCapture capture) onDetect =
        useCallback((BarcodeCapture capture) async {
      if (!showScanner.value) return;

      final Option<Barcode> barcodeOption = Option<Barcode>.fromNullable(
        capture.barcodes.firstWhere(
          (Barcode barcode) => barcode.rawValue != null,
          orElse: () => const Barcode(rawValue: null),
        ),
      );

      await barcodeOption.match(
        () => null,
        (Barcode barcode) async {
          await ref
              .read(audioPlayerControllerProvider)
              .onScanSuccess()
              .run()
              .then((Either<String, Unit> either) => either.match(
                    (String error) =>
                        debugPrint('Error on scan success: $error'),
                    (_) => null,
                  ));

          showScanner.value = false;
          scanResult.value = barcode.rawValue;
        },
      );
    }, <Object?>[showScanner, scanResult]);

    final Null Function() onScanAgain = useCallback(() {
      showScanner.value = true;
      initScanning();
    }, <Object?>[initScanning]);

    useEffect(() {
      initScanning();
      return () {
        ref
            .read(audioPlayerControllerProvider)
            .stop()
            .run()
            .then((Either<String, Unit> either) => either.match(
                  (String error) =>
                      debugPrint('Error stopping scanner: $error'),
                  (_) => null,
                ));
      };
    }, <Object?>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: <Widget>[
          if (showScanner.value) ...<Widget>[
            MobileScanner(
              onDetect: onDetect,
            ),
            CustomPaint(
              painter: ScannerOverlay(),
              child: const SizedBox.expand(),
            ),
          ] else ...<Widget>[
            ResultView(
              result: scanResult.value!,
              onScanAgain: onScanAgain,
            ),
          ],
        ],
      ),
    );
  }
}
