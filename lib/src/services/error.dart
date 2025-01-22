import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/models.dart';
import 'package:qrcode_scanner/src/services.dart';

class ErrorService {
  ErrorService(this.ref);

  final Ref ref;

  TaskEither<String, Unit> initializeError(ErrorModel error) {
    final LoggerService log = ref.read(loggerProvider);
    log.error('Error occurred', error.message, error.stackTrace);

    return TaskEither<String, Unit>.tryCatch(
      () async {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black,
        ));
        return unit;
      },
      (Object error, StackTrace stackTrace) =>
          'Failed to initialize error view: $error',
    );
  }

  TaskEither<String, Unit> handleTryAgain() {
    final LoggerService log = ref.read(loggerProvider);
    log.info('Attempting to restart application');

    return TaskEither<String, Unit>.tryCatch(
      () async {
        await SystemNavigator.pop();
        await SystemChannels.platform
            .invokeMethod('SystemNavigator.restartApp');
        return unit;
      },
      (Object error, StackTrace stackTrace) {
        log.error('Restart failed', error.toString());
        return 'Failed to restart app: $error';
      },
    );
  }
}
