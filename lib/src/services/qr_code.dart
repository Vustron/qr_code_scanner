import 'package:sqflite/sqflite.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/models.dart';

class QRCodeService {
  QRCodeService(this.logger, this.db);

  final LoggerService logger;
  final Database? db;

  Option<Database> get database => Option<Database>.fromNullable(db);

  TaskEither<String, Unit> checkDatabase() => TaskEither<String, Unit>.tryCatch(
        () async {
          if (db == null || !db!.isOpen) {
            throw Exception('Database not initialized');
          }
          return unit;
        },
        (Object error, _) => 'Database not initialized: $error',
      );

  TaskEither<String, QRCode> getQRCode(String id) {
    return checkDatabase().flatMap(
      (_) => TaskEither<String, QRCode>.tryCatch(
        () async {
          final QRCode result = await database.match(
            () => throw Exception('Database not initialized'),
            (Database database) async {
              final List<Map<String, Object?>> maps = await database.query(
                'qr_codes',
                where: 'id = ?',
                whereArgs: <Object?>[id],
              );
              if (maps.isEmpty) throw Exception('QR code not found');
              return QRCode.fromJson(maps.first);
            },
          );

          logger.info('QR code retrieved successfully: $id');
          return result;
        },
        (Object error, StackTrace stack) {
          logger.error('Failed to get QR code: $error');
          return 'Failed to get QR code: $error';
        },
      ),
    );
  }

  TaskEither<String, List<QRCode>> getAllQRCodes() {
    return checkDatabase().flatMap(
      (_) => TaskEither<String, List<QRCode>>.tryCatch(
        () async {
          final List<QRCode> results = await database.match(
            () => throw Exception('Database not initialized'),
            (Database database) async {
              final List<Map<String, Object?>> maps = await database.query(
                'qr_codes',
                orderBy: 'scanned_at DESC',
              );
              return maps.map((Map<String, Object?> map) {
                return QRCode.fromJson(<String, Object>{
                  'id': map['id']?.toString() ?? '',
                  'label': map['label']?.toString() ??
                      map['raw_value']?.toString() ??
                      '',
                  'raw_value': map['raw_value']?.toString() ?? '',
                  'scanned_at': map['scanned_at']?.toString() ??
                      DateTime.now().toIso8601String(),
                  'updated_at': map['updated_at']?.toString() ??
                      map['scanned_at']?.toString() ??
                      DateTime.now().toIso8601String(),
                });
              }).toList();
            },
          );

          logger.info('Retrieved ${results.length} QR codes');
          return results;
        },
        (Object error, StackTrace stack) {
          logger.error('Failed to get all QR codes: $error');
          return 'Failed to get all QR codes: $error';
        },
      ),
    );
  }

  TaskEither<String, Unit> saveScannedQRCode(QRCode qrCode) {
    return checkDatabase().flatMap(
      (_) => TaskEither<String, Unit>.tryCatch(
        () async {
          await database.match(
            () => throw Exception('Database not initialized'),
            (Database database) async {
              final List<Map<String, Object?>> existing = await database.query(
                'qr_codes',
                where: 'raw_value = ?',
                whereArgs: <Object?>[qrCode.rawValue],
              );

              if (existing.isNotEmpty) {
                throw Exception('This QR code already exists');
              }

              await database.insert(
                'qr_codes',
                <String, Object?>{
                  'id': qrCode.id,
                  'label': qrCode.label,
                  'raw_value': qrCode.rawValue,
                  'scanned_at': qrCode.scannedAt.toIso8601String(),
                  'updated_at': qrCode.updatedAt.toIso8601String(),
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            },
          );

          logger.info('QR code saved successfully: ${qrCode.rawValue}');
          return unit;
        },
        (Object error, StackTrace stack) {
          logger.error('Failed to save QR code: $error');
          return 'Failed to save QR code: $error';
        },
      ),
    );
  }

  TaskEither<String, Unit> updateQRCode(QRCode qrCode) {
    return checkDatabase().flatMap(
      (_) => TaskEither<String, Unit>.tryCatch(
        () async {
          await database.match(
            () => throw Exception('Database not initialized'),
            (Database database) async {
              final int rowsAffected = await database.update(
                'qr_codes',
                <String, Object?>{
                  'label': qrCode.label,
                  'raw_value': qrCode.rawValue,
                  'updated_at': qrCode.updatedAt.toIso8601String(),
                },
                where: 'id = ?',
                whereArgs: <Object?>[qrCode.id],
              );
              if (rowsAffected == 0) throw Exception('QR code not found');
            },
          );

          logger.info(
              'QR code updated successfully: ${qrCode.id} with value: ${qrCode.rawValue}');
          return unit;
        },
        (Object error, StackTrace stack) {
          logger.error('Failed to update QR code: $error');
          return 'Failed to update QR code: $error';
        },
      ),
    );
  }

  TaskEither<String, Unit> deleteQRCode(String id) {
    return checkDatabase().flatMap(
      (_) => TaskEither<String, Unit>.tryCatch(
        () async {
          await database.match(
            () => throw Exception('Database not initialized'),
            (Database database) async {
              final List<Map<String, Object?>> existing = await database.query(
                'qr_codes',
                where: 'id = ?',
                whereArgs: <Object?>[id],
              );

              if (existing.isEmpty) {
                throw Exception('No QR code found to delete');
              }

              final int rowsAffected = await database.delete(
                'qr_codes',
                where: 'id = ?',
                whereArgs: <Object?>[id],
              );
              if (rowsAffected == 0) {
                throw Exception('Failed to delete QR code');
              }
            },
          );

          logger.info('QR code deleted successfully: $id');
          return unit;
        },
        (Object error, StackTrace stack) {
          logger.error('Failed to delete QR code: $error');
          return 'Failed to delete QR code: $error';
        },
      ),
    );
  }

  TaskEither<String, Unit> deleteAllQRCodes() {
    return checkDatabase().flatMap(
      (_) => TaskEither<String, Unit>.tryCatch(
        () async {
          await database.match(
            () => throw Exception('Database not initialized'),
            (Database database) async {
              final List<Map<String, Object?>> existing =
                  await database.query('qr_codes');

              if (existing.isEmpty) {
                throw Exception('No QR codes found to delete');
              }

              final int rowsAffected = await database.delete('qr_codes');
              if (rowsAffected == 0) {
                throw Exception('No QR codes were deleted');
              }
            },
          );

          logger.info('All QR codes deleted successfully');
          return unit;
        },
        (Object error, StackTrace stack) {
          logger.error('Failed to delete all QR codes: $error');
          return 'Failed to delete all QR codes: $error';
        },
      ),
    );
  }
}
