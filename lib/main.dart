import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/views.dart';

void main() {
  Chain.capture(() {
    final ProviderContainer container = ProviderContainer();
    final LoggerService log = container.read(loggerProvider);

    TaskEither<String, Unit> initializeApp() =>
        TaskEither<String, Unit>.tryCatch(
          () async {
            log.info('Initializing app...');
            WidgetsFlutterBinding.ensureInitialized();

            log.debug('Configuring system UI...');
            await SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.immersiveSticky);
            await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);

            log.debug('Initializing database...');
            await container.read(dbControllerProvider).initialize().run().then(
                  (Either<String, Unit> either) => either.match(
                    (String error) => throw Exception(error),
                    (_) => log.info('Database initialized successfully'),
                  ),
                );

            FlutterError.onError = (FlutterErrorDetails details) {
              log.error(
                  'Flutter error caught', details.exception, details.stack);
              FlutterError.presentError(details);

              Option<BuildContext>.fromNullable(
                      CustomRouterService.navigatorKey.currentContext)
                  .map((BuildContext context) {
                final Trace trace =
                    Trace.from(details.stack ?? StackTrace.current);
                Navigator.of(context).push(
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => ErrorView(
                      error: details.exception.toString(),
                      stackTrace: trace.terse,
                    ),
                  ),
                );
              });
            };

            log.info('Starting app...');
            runApp(ProviderScope(child: App()));
            return unit;
          },
          (Object error, StackTrace stack) =>
              'Failed to initialize app: $error',
        );

    initializeApp().run().then((Either<String, Unit> either) => either.match(
          (String error) {
            log.error('Failed to initialize app', error);
            Option<BuildContext>.fromNullable(
                    CustomRouterService.navigatorKey.currentContext)
                .map((BuildContext context) {
              const Trace Function([int level]) trace = Trace.current;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => ErrorView(
                    error: error,
                    stackTrace: trace().terse,
                  ),
                ),
              );
            });
          },
          (_) => null,
        ));
  }, onError: (Object error, Chain stackTrace) {
    final ProviderContainer container = ProviderContainer();
    final LoggerService log = container.read(loggerProvider);
    log.error('Uncaught error', error, stackTrace);

    Option<BuildContext>.fromNullable(
            CustomRouterService.navigatorKey.currentContext)
        .map((BuildContext context) {
      final Trace trace = Trace.from(stackTrace);
      Navigator.of(context).push(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ErrorView(
            error: error.toString(),
            stackTrace: trace.terse,
          ),
        ),
      );
    });
  });
}
