import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/providers.dart';

class QrListAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const QrListAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        IconButton(
          icon: const Icon(
            FluentIcons.delete_24_regular,
            color: Colors.white70,
          ),
          onPressed: () {
            ref.read(dbControllerProvider).deleteAllQRCodes().run().then(
                  (Either<String, Unit> either) => either.match(
                    (String error) => ref
                        .read(toasterProvider)
                        .show(
                          context: context,
                          title: 'Error',
                          message: error,
                          type: 'error',
                        )
                        .run(),
                    (_) async {
                      // ignore: unused_result
                      await ref.refresh(qrHistoryProvider.future);
                      if (!context.mounted) return;
                      ref
                          .read(toasterProvider)
                          .show(
                            context: context,
                            title: 'Success',
                            message: 'All QR codes deleted',
                            type: 'success',
                          )
                          .run();
                    },
                  ),
                );
          },
        ),
      ],
    );
  }
}
