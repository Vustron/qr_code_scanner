import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/v8.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/models.dart';

class QRCodeController {
  QRCodeController(this.service, this.ref);

  final QRCodeService service;
  final Ref ref;

  TaskEither<String, Unit> saveQRCode(String rawValue) {
    final QRCode qrCode = QRCode(
      id: const UuidV8().generate().replaceAll('-', '').substring(0, 12),
      label:
          '${DateTime.now().toIso8601String()}-${const UuidV8().generate().replaceAll('-', '').substring(0, 12)}',
      rawValue: rawValue,
      scannedAt: DateTime.now(),
    );
    return service.saveScannedQRCode(qrCode).map((_) {
      ref.read(qrHistoryNotifierProvider.notifier).refresh();
      return unit;
    });
  }

  TaskEither<String, Unit> updateQRCode(QRCode qrCode) {
    return service.updateQRCode(qrCode).map((_) {
      ref.read(qrHistoryNotifierProvider.notifier).refresh();
      return unit;
    });
  }

  TaskEither<String, Unit> deleteQRCode(String id) {
    return service.deleteQRCode(id).map((_) {
      ref.read(qrHistoryNotifierProvider.notifier).refresh();
      return unit;
    });
  }

  TaskEither<String, Unit> deleteAllQRCodes() {
    return service.deleteAllQRCodes().map((_) {
      ref.read(qrHistoryNotifierProvider.notifier).refresh();
      return unit;
    });
  }

  TaskEither<String, QRCode> getQRCode(String id) {
    return service.getQRCode(id);
  }

  TaskEither<String, List<QRCode>> getAllQRCodes() {
    return service.getAllQRCodes();
  }
}
