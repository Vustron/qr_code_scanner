import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/views.dart';

class HomeAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.showScanner,
    required this.torchEnabled,
    required this.scannerController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final ValueNotifier<bool> showScanner;
  final ValueNotifier<bool> torchEnabled;
  final MobileScannerController scannerController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          showScanner.value ? 'QR Scanner' : '',
          key: ValueKey<bool>(showScanner.value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: showScanner.value
          ? IconButton(
              icon: const Icon(
                FluentIcons.list_24_regular,
                color: Colors.white,
              ),
              onPressed: () {
                ref
                    .read(routerProvider)
                    .navigateToWithTransition(
                      const QrList(),
                      'rightToLeft',
                    )
                    .run()
                    .then(
                      (Either<String, Unit> either) => either.match(
                        (String error) => ref.read(toasterProvider).show(
                              context: context,
                              title: 'Error',
                              message: error,
                              type: 'error',
                            ),
                        (_) => null,
                      ),
                    );
              },
            )
          : null,
      actions: <Widget>[
        if (showScanner.value)
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                torchEnabled.value
                    ? FluentIcons.flashlight_24_filled
                    : FluentIcons.flashlight_off_24_filled,
                key: ValueKey<bool>(torchEnabled.value),
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              try {
                await scannerController.toggleTorch();
                torchEnabled.value = scannerController.hasTorch;
              } catch (e) {
                if (!context.mounted) return;
                ref
                    .read(toasterProvider)
                    .show(
                      context: context,
                      title: 'Error',
                      message: 'Failed to toggle torch',
                      type: 'error',
                    )
                    .run();
              }
            },
          ),
      ],
    );
  }
}
