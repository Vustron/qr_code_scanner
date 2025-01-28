import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:io';

import 'package:qrcode_scanner/src/services.dart';

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
          version: 2,
          singleInstance: true,
          readOnly: false,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS qr_codes (
                id TEXT PRIMARY KEY NOT NULL,
                label TEXT NOT NULL,
                raw_value TEXT NOT NULL,
                scanned_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            if (oldVersion < 2) {
              await db.execute('ALTER TABLE qr_codes ADD COLUMN label TEXT');
              await db
                  .execute('ALTER TABLE qr_codes ADD COLUMN updated_at TEXT');
              await db.execute('UPDATE qr_codes SET label = raw_value');
              await db.execute('UPDATE qr_codes SET updated_at = scanned_at');
            }
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

  Option<Database> get database => Option<Database>.fromNullable(db);
}
