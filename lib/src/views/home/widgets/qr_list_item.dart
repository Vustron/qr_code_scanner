import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/helpers.dart';
import 'package:qrcode_scanner/src/models.dart';
import 'package:qrcode_scanner/src/views.dart';
import 'package:share_plus/share_plus.dart';

class QrListItem extends HookConsumerWidget {
  const QrListItem({
    super.key,
    required this.code,
  });

  final QRCode code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.black87,
            isScrollControlled: true,
            builder: (BuildContext context) =>
                QrDetailsBottomSheet(qrCode: code),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    getQRContentIcon(code.rawValue),
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      code.rawValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    getRelativeTime(code.scannedAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          FluentIcons.share_24_regular,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Share.share(
                            code.rawValue,
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
                      IconButton(
                        icon: const Icon(
                          FluentIcons.edit_24_regular,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (BuildContext context) =>
                                UpdateQRBottomSheet(qrCode: code),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          FluentIcons.copy_24_regular,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: code.rawValue),
                          );
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
            ],
          ),
        ),
      ),
    );
  }
}
