import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    final ValueNotifier<bool> torchEnabled = useState(false);
    final ValueNotifier<UniqueKey> scannerKey = useState(UniqueKey());
    final ValueNotifier<bool> qrDetected = useState(false);
    final ValueNotifier<Barcode?> currentBarcode = useState<Barcode?>(null);

    final MobileScannerController scannerController = useMemoized(
      () => MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      ),
      <Object?>[scannerKey.value],
    );

    useEffect(() {
      return () {
        scannerController.dispose();
      };
    }, <Object?>[scannerKey.value]);

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
          currentBarcode.value = barcode;
          qrDetected.value = barcode.corners.isNotEmpty;

          await ref
              .read(audioPlayerControllerProvider)
              .onScanSuccess()
              .run()
              .then((Either<String, Unit> either) => either.match(
                    (String error) async {
                      if (!context.mounted) return;
                      await ref
                          .read(toasterProvider)
                          .show(
                            context: context,
                            title: 'Error',
                            message: error,
                            type: 'error',
                          )
                          .run();
                    },
                    (_) => null,
                  ));

          showScanner.value = false;
          scanResult.value = barcode.rawValue;
        },
      );
    }, <Object?>[showScanner, scanResult, qrDetected, currentBarcode]);

    final Null Function() onScanAgain = useCallback(() {
      scannerKey.value = UniqueKey();
      showScanner.value = true;
      scanResult.value = null;
      torchEnabled.value = false;
      qrDetected.value = false;
      currentBarcode.value = null;
    }, const <Object?>[]);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: HomeAppBar(
        showScanner: showScanner,
        torchEnabled: torchEnabled,
        scannerController: scannerController,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.black,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: Stack(
            key: ValueKey<bool>(showScanner.value),
            children: <Widget>[
              if (showScanner.value) ...<Widget>[
                QRScanner(
                  scannerKey: scannerKey,
                  scannerController: scannerController,
                  onDetect: onDetect,
                ),
                const Center(
                  child: AnimatedScannerOverlay(),
                ),
                const About(),
              ] else ...<Widget>[
                ResultView(
                  result: scanResult.value!,
                  onScanAgain: onScanAgain,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
