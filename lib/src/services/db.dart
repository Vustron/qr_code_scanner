import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:io';

import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/models.dart';

class DBService {
  DBService(this.logger);

  final LoggerService logger;
  Database? db;
  bool isInit = false;

  TaskEither<String, Unit> initialize() {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        if (isInit) return unit;

        final Directory appDir = await getApplicationDocumentsDirectory();
        final String dbPath = path.join(appDir.path, 'qrcode.db');
        final Directory dbDir = Directory(path.dirname(dbPath));

        if (!dbDir.existsSync()) {
          await dbDir.create(recursive: true);
        }

        db = await openDatabase(
          dbPath,
          version: 1,
          singleInstance: true,
          readOnly: false,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS qr_codes (
                id TEXT PRIMARY KEY NOT NULL,
                raw_value TEXT NOT NULL,
                scanned_at TEXT NOT NULL
              )
            ''');
          },
        );

        isInit = true;
        logger.info('Database initialized at: $dbPath');
        return unit;
      },
      (Object error, StackTrace stack) {
        logger.error('Database initialization failed: $error');
        isInit = false;
        db = null;
        return 'Failed to initialize database: $error';
      },
    );
  }

  TaskEither<String, Unit> dispose() {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        await db?.close();
        db = null;
        isInit = false;
        logger.info('Database disposed successfully');
        return unit;
      },
      (Object error, StackTrace stack) {
        logger.error('Database disposal failed: $error');
        return 'Failed to close database: $error';
      },
    );
  }

  TaskEither<String, QRCode> getQRCode(String id) {
    return TaskEither<String, QRCode>.tryCatch(
      () async {
        final Option<Database> dbOption = database;

        final QRCode result = await dbOption.match(
          () => throw Exception('Database not initialized'),
          (Database database) async {
            final List<Map<String, dynamic>> maps = await database.query(
              'qr_codes',
              where: 'id = ?',
              whereArgs: <String>[id],
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
    );
  }

  TaskEither<String, List<QRCode>> getAllQRCodes() {
    return TaskEither<String, List<QRCode>>.tryCatch(
      () async {
        if (!isInit || db == null) {
          await initialize().run();
        }

        final Option<Database> dbOption = database;

        final List<QRCode> results = await dbOption.match(
          () => throw Exception('Database not initialized'),
          (Database database) async {
            final List<Map<String, dynamic>> maps = await database.query(
              'qr_codes',
              orderBy: 'scanned_at DESC',
            );
            return maps
                .map((Map<String, dynamic> map) => QRCode.fromJson(map))
                .toList();
          },
        );

        logger.info('Retrieved ${results.length} QR codes');
        return results;
      },
      (Object error, StackTrace stack) {
        logger.error('Failed to get all QR codes: $error');
        return 'Failed to get all QR codes: $error';
      },
    );
  }

  TaskEither<String, Unit> saveScannedQRCode(QRCode qrCode) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        if (!isInit || db == null) {
          await initialize().run();
        }

        final Option<Database> dbOption = database;

        await dbOption.match(
          () => throw Exception('Database not initialized'),
          (Database database) async {
            final List<Map<String, dynamic>> existing = await database.query(
              'qr_codes',
              where: 'raw_value = ?',
              whereArgs: <String>[qrCode.rawValue],
            );

            if (existing.isNotEmpty) {
              throw Exception('This QR code already exists');
            }

            final Map<String, dynamic> values = <String, dynamic>{
              'id': qrCode.id,
              'raw_value': qrCode.rawValue,
              'scanned_at': qrCode.scannedAt.toIso8601String(),
            };

            await database.insert(
              'qr_codes',
              values,
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
    );
  }

  TaskEither<String, Unit> updateQRCode(QRCode qrCode) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final Option<Database> dbOption = database;

        await dbOption.match(
          () => throw Exception('Database not initialized'),
          (Database database) async {
            final int rowsAffected = await database.update(
              'qr_codes',
              <String, Object?>{'raw_value': qrCode.rawValue},
              where: 'id = ?',
              whereArgs: <String>[qrCode.id],
            );
            if (rowsAffected == 0) throw Exception('QR code not found');
          },
        );

        logger.info('QR code updated successfully: ${qrCode.id}');
        return unit;
      },
      (Object error, StackTrace stack) {
        logger.error('Failed to update QR code: $error');
        return 'Failed to update QR code: $error';
      },
    );
  }

  TaskEither<String, Unit> deleteQRCode(String id) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final Option<Database> dbOption = database;

        await dbOption.match(
          () => throw Exception('Database not initialized'),
          (Database database) async {
            final int rowsAffected = await database.delete(
              'qr_codes',
              where: 'id = ?',
              whereArgs: <String>[id],
            );
            if (rowsAffected == 0) throw Exception('QR code not found');
          },
        );

        logger.info('QR code deleted successfully: $id');
        return unit;
      },
      (Object error, StackTrace stack) {
        logger.error('Failed to delete QR code: $error');
        return 'Failed to delete QR code: $error';
      },
    );
  }

  TaskEither<String, Unit> deleteAllQRCodes() {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final Option<Database> dbOption = database;

        await dbOption.match(
          () => throw Exception('Database not initialized'),
          (Database database) async {
            await database.delete('qr_codes');
          },
        );

        logger.info('All QR codes deleted successfully');
        return unit;
      },
      (Object error, StackTrace stack) {
        logger.error('Failed to delete all QR codes: $error');
        return 'Failed to delete all QR codes: $error';
      },
    );
  }

  Option<Database> get database => Option<Database>.fromNullable(db);
}
