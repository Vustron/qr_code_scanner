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
      scannerKey.value = UniqueKey();
      showScanner.value = true;
      scanResult.value = null;
      torchEnabled.value = false;
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
                Center(
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
                          errorBuilder: (BuildContext context,
                              MobileScannerException error, Widget? child) {
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
                ),
                const Center(
                  child: AnimatedScannerOverlay(),
                ),
                SafeArea(
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white24),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white.withOpacity(0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Position QR code within frame to scan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (BuildContext context) =>
                                const AboutBottomSheet(),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Made by Vustron',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
