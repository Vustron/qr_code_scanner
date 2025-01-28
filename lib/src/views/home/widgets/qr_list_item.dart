import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/helpers.dart';
import 'package:qrcode_scanner/src/models.dart';
import 'package:qrcode_scanner/src/views.dart';

class QrListItem extends HookConsumerWidget {
  const QrListItem({
    super.key,
    required this.code,
  });

  final QRCode code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEdited = code.updatedAt.millisecondsSinceEpoch !=
        code.scannedAt.millisecondsSinceEpoch;
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
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                formatLabel(code.label),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Scanned ${getRelativeTime(code.scannedAt)}',
                      style: TextStyle(
                        color: Colors.green.shade200,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  if (isEdited) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Edited ${getRelativeTime(code.updatedAt)}',
                        style: TextStyle(
                          color: Colors.blue.shade200,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Share button
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

                      // Edit button
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

                      // Copy button
                      IconButton(
                        icon: const Icon(
                          FluentIcons.copy_24_regular,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code.rawValue));
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
