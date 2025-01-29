import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/controllers.dart';
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
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        title: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                FluentIcons.delete_24_filled,
                                color: Colors.red.shade300,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Delete All',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        content: const Text(
                          'Are you sure you want to delete all QR codes? This action cannot be undone.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        actionsPadding: const EdgeInsets.all(16),
                        actions: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              backgroundColor: Colors.red.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              qr.deleteAllQRCodes().run().then(
                                    (Either<String, Unit> either) =>
                                        either.match(
                                      (String error) => ref
                                          .read(toasterProvider)
                                          .show(
                                            context: context,
                                            title: 'Error',
                                            message: error,
                                            type: 'error',
                                          )
                                          .run(),
                                      (_) => ref
                                          .read(toasterProvider)
                                          .show(
                                            context: context,
                                            title: 'Success',
                                            message: 'All QR codes deleted',
                                            type: 'success',
                                          )
                                          .run(),
                                    ),
                                  );
                            },
                            child: Text(
                              'Delete All',
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
