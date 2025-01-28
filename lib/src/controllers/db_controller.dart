import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/services.dart';

class DBController {
  DBController(this.db);

  final DBService db;

  TaskEither<String, Unit> initialize() => db.initialize();

  TaskEither<String, Unit> dispose() => db.dispose();
}
