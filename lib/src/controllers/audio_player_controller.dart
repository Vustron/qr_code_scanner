import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/services.dart';

class AudioPlayerController {
  AudioPlayerController(this.service);

  final AudioPlayerService service;

  TaskEither<String, Unit> onScanSuccess() => TaskEither<String, Unit>.tryCatch(
        () async {
          await service.stopSound().run();
          await service.successfulScanningSound().run().then(
                (Either<String, Unit> either) => either.match(
                  (String error) =>
                      debugPrint('Error playing success sound: $error'),
                  (_) => null,
                ),
              );
          return unit;
        },
        (Object error, StackTrace stack) =>
            'AudioPlayerController: Failed to play success: $error',
      );

  TaskEither<String, Unit> onScanError() => TaskEither<String, Unit>.tryCatch(
        () async {
          await service.stopSound().run();
          await service.errorScanningSound().run().then(
                (Either<String, Unit> either) => either.match(
                  (String error) =>
                      debugPrint('Error playing error sound: $error'),
                  (_) => null,
                ),
              );
          return unit;
        },
        (Object error, StackTrace stack) =>
            'AudioPlayerController: Failed to play error: $error',
      );

  TaskEither<String, Unit> stop() => service.stopSound();
}
