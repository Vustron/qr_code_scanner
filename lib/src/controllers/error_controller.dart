import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/models.dart';

class ErrorController {
  ErrorController(this.ref, this.repository);

  final Ref ref;
  final ErrorService repository;

  TaskEither<String, Unit> initError(ErrorModel error) =>
      TaskEither<String, Unit>.tryCatch(
        () async {
          await repository.initializeError(error).run();
          return unit;
        },
        (Object error, StackTrace stack) =>
            'Failed to initialize error: $error',
      );

  TaskEither<String, Unit> handleTryAgain() =>
      TaskEither<String, Unit>.tryCatch(
        () async {
          await repository.handleTryAgain().run();
          return unit;
        },
        (Object error, StackTrace stack) =>
            'Failed to handle try again: $error',
      );
}
