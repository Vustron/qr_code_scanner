import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/helpers.dart';
import 'package:qrcode_scanner/src/views.dart';

class ResultContent extends HookConsumerWidget {
  const ResultContent({
    super.key,
    required this.result,
  });

  final String result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> isSaved = useState(false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  getQRContentIcon(result),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ActionButton(
                icon: isSaved.value
                    ? FluentIcons.checkmark_24_filled
                    : FluentIcons.save_24_regular,
                label: isSaved.value ? 'Saved' : 'Save',
                onPressed: () {
                  if (isSaved.value) return;
                  HapticFeedback.lightImpact();
                  ref
                      .read(dbControllerProvider)
                      .saveQRCode(result)
                      .run()
                      .then<Either<String, Unit>>(
                          (Either<String, Unit> either) => either.match(
                                (String error) async {
                                  await ref
                                      .read(toasterProvider)
                                      .show(
                                        context: context,
                                        title: 'Error',
                                        message: error,
                                        type: 'error',
                                      )
                                      .run();
                                  return either;
                                },
                                (_) async {
                                  isSaved.value = true;
                                  ref
                                      .read(qrHistoryNotifierProvider.notifier)
                                      .refresh();
                                  await ref
                                      .read(toasterProvider)
                                      .show(
                                        context: context,
                                        title: 'Success',
                                        message: 'QR Code saved',
                                        type: 'success',
                                      )
                                      .run();
                                  return either;
                                },
                              ));
                },
              ),
              const SizedBox(width: 5),
              ActionButton(
                icon: FluentIcons.share_24_regular,
                label: 'Share',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Share.share(
                    result,
                    subject: 'Shared QR Code Content',
                  ).then((_) {
                    if (!context.mounted) return;
                    ref
                        .read(toasterProvider)
                        .show(
                          context: context,
                          title: 'Success',
                          message: 'Content shared successfully',
                          type: 'success',
                        )
                        .run();
                  }).catchError((dynamic error) {
                    if (!context.mounted) return;
                    ref
                        .read(toasterProvider)
                        .show(
                          context: context,
                          title: 'Error',
                          message: 'Failed to share content',
                          type: 'error',
                        )
                        .run();
                  });
                },
              ),
              const SizedBox(width: 5),
              ActionButton(
                icon: FluentIcons.copy_24_regular,
                label: 'Copy',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: result));
                  ref
                      .read(toasterProvider)
                      .show(
                        context: context,
                        title: 'Success',
                        message: 'Copied to clipboard',
                        type: 'success',
                      )
                      .run();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
