import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qrcode_scanner/src/controllers/qr_code_controller.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/models.dart';

class QrListAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const QrListAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<QRCode>> qrHistory =
        ref.watch(qrHistoryNotifierProvider);
    final QRCodeController qr = ref.watch(qrCodeControllerProvider);
    return AppBar(
      title: const Text(
        'Saved QR List',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(FluentIcons.arrow_left_24_regular),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      actions: <Widget>[
        qrHistory.when(
          data: (List<QRCode> qrCodes) => qrCodes.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(
                    FluentIcons.delete_24_regular,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    qr.deleteAllQRCodes().run().then(
                          (Either<String, Unit> either) => either.match(
                            (String error) => ref.read(toasterProvider).show(
                                  context: context,
                                  title: 'Error',
                                  message: error,
                                  type: 'error',
                                ),
                            (_) {
                              ref.read(toasterProvider).show(
                                    context: context,
                                    title: 'Success',
                                    message: 'All QR codes deleted',
                                    type: 'success',
                                  );
                            },
                          ),
                        );
                  },
                ),
          error: (_, __) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
