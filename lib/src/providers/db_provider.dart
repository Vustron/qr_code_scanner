import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/services.dart';

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
