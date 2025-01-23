import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/controllers.dart';
import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/services.dart';

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
