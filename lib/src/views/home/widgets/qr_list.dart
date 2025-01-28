import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/controllers.dart';
import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/models.dart';
import 'package:qrcode_scanner/src/views.dart';

class QrList extends HookConsumerWidget {
  const QrList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<QRCode>> qrCodes =
        ref.watch(qrHistoryNotifierProvider);
    final QRCodeController qr = ref.watch(qrCodeControllerProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const QrListAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(qrHistoryNotifierProvider.notifier).refresh();
        },
        child: qrCodes.when(
          data: (List<QRCode> codes) {
            if (codes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FluentIcons.history_24_regular,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No QR codes scanned yet',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: codes.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final QRCode code = codes[index];
                return Dismissible(
                  key: Key(code.id),
                  background: Container(
                    color: Colors.red.shade900,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      FluentIcons.delete_24_filled,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await qr.deleteQRCode(code.id).run().then(
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
                              if (!context.mounted) return;
                              ref
                                  .read(toasterProvider)
                                  .show(
                                    context: context,
                                    title: 'Success',
                                    message: 'QR code deleted',
                                    type: 'success',
                                  )
                                  .run();
                            },
                          ),
                        );
                  },
                  child: QrListItem(code: code),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
          error: (Object error, _) => QrListError(error: error),
        ),
      ),
    );
  }
}
