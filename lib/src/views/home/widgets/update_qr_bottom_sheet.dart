import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qrcode_scanner/src/helpers.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/models.dart';

class UpdateQRBottomSheet extends HookConsumerWidget {
  const UpdateQRBottomSheet({
    super.key,
    required this.qrCode,
  });

  final QRCode qrCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller =
        useTextEditingController(text: qrCode.rawValue);
    final ValueNotifier<bool> isLoading = useState(false);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Edit QR Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            enabled: !isLoading.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter new value',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              prefixIcon: Icon(
                getQRContentIcon(controller.text),
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton.icon(
                onPressed:
                    isLoading.value ? null : () => Navigator.pop(context),
                icon: const Icon(
                  FluentIcons.dismiss_24_regular,
                  size: 18,
                  color: Colors.white70,
                ),
                label: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (controller.text.isEmpty) {
                          ref
                              .read(toasterProvider)
                              .show(
                                context: context,
                                title: 'Error',
                                message: 'QR Code value cannot be empty',
                                type: 'error',
                              )
                              .run();
                          return;
                        }

                        isLoading.value = true;

                        final QRCode updatedQRCode = qrCode.copyWith(
                          rawValue: controller.text,
                        );

                        await ref
                            .read(dbControllerProvider)
                            .updateQRCode(updatedQRCode)
                            .run()
                            .then((Either<String, Unit> either) => either.match(
                                  (String error) {
                                    isLoading.value = false;
                                    ref
                                        .read(toasterProvider)
                                        .show(
                                          context: context,
                                          title: 'Error',
                                          message: error,
                                          type: 'error',
                                        )
                                        .run();
                                  },
                                  (_) {
                                    ref
                                        .read(
                                            qrHistoryNotifierProvider.notifier)
                                        .refresh();
                                    Navigator.pop(context);
                                    ref
                                        .read(toasterProvider)
                                        .show(
                                          context: context,
                                          title: 'Success',
                                          message:
                                              'QR Code updated successfully',
                                          type: 'success',
                                        )
                                        .run();
                                  },
                                ));
                      },
                icon: isLoading.value
                    ? Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(right: 8),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      )
                    : const Icon(
                        FluentIcons.save_24_regular,
                        size: 18,
                        color: Colors.white,
                      ),
                label: Text(
                  isLoading.value ? 'Updating...' : 'Update',
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 65),
        ],
      ),
    );
  }
}
