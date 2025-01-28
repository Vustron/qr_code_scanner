import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/controllers.dart';
import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/services.dart';
import 'package:sqflite/sqflite.dart';

final Provider<DBController> dbControllerProvider =
    Provider<DBController>((ProviderRef<DBController> ref) {
  final DBService service = ref.watch(dbServiceProvider);
  final DBController controller = DBController(service);

  ref.onDispose(() {
    controller.dispose().run().then(
          (Either<String, Unit> either) => either.match(
            (String error) => ref.read(loggerProvider).error(error),
            (_) => ref.read(loggerProvider).info('Database disposed'),
          ),
        );
  });

  return controller;
});

final Provider<DBService> dbServiceProvider =
    Provider<DBService>((ProviderRef<DBService> ref) {
  final LoggerService logger = ref.read(loggerProvider);
  final DBService service = DBService(logger);

  ref.onDispose(() {
    service.dispose().run().then(
          (Either<String, Unit> either) => either.match(
            (String error) => logger.error(error).match(
                  (String logError) =>
                      logger.error('Failed to log error: $logError'),
                  (_) => unit,
                ),
            (_) => logger.info('Database disposed').match(
                  (String logError) =>
                      logger.error('Failed to log disposal: $logError'),
                  (_) => unit,
                ),
          ),
        );
  });

  return service;
});

final Provider<Database?> databaseProvider =
    Provider<Database?>((ProviderRef<Database?> ref) {
  final DBService dbService = ref.watch(dbServiceProvider);
  return dbService.database.toNullable();
});

final FutureProvider<Unit> dbInitProvider =
    FutureProvider<Unit>((FutureProviderRef<Unit> ref) async {
  final DBService dbService = ref.watch(dbServiceProvider);
  final Either<String, Unit> result = await dbService.initialize().run();
  return result.match(
    (String error) => throw Exception(error),
    (Unit unit) => unit,
  );
});
