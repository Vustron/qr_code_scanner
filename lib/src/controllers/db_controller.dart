import 'package:fpdart/fpdart.dart';
import 'package:nanoid/nanoid.dart';

import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/models.dart';

class DBController {
  DBController(this.db);

  final DBService db;

  TaskEither<String, Unit> initialize() => db.initialize();

  TaskEither<String, QRCode> getQRCode(String id) => db.getQRCode(id);

  TaskEither<String, List<QRCode>> getAllQRCodes() => db.getAllQRCodes();

  TaskEither<String, Unit> saveQRCode(String rawValue) {
    final QRCode qrCode = QRCode(
      id: nanoid(),
      rawValue: rawValue,
      scannedAt: DateTime.now(),
    );
    return db.saveScannedQRCode(qrCode);
  }

  TaskEither<String, Unit> updateQRCode(QRCode qrCode) =>
      db.updateQRCode(qrCode);

  TaskEither<String, Unit> deleteQRCode(String id) => db.deleteQRCode(id);

  TaskEither<String, Unit> deleteAllQRCodes() => db.deleteAllQRCodes();

  TaskEither<String, Unit> dispose() => db.dispose();
}
