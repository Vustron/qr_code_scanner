import 'package:logger/logger.dart';
import 'package:fpdart/fpdart.dart';

class LoggerService {
  LoggerService() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: Level.debug,
    );
  }

  late final Logger _logger;

  Either<String, Unit> debug(String message,
          [dynamic error, StackTrace? stackTrace]) =>
      Either<String, Unit>.tryCatch(
        () {
          _logger.d(message, error: error, stackTrace: stackTrace);
          return unit;
        },
        (Object error, StackTrace stack) =>
            'Failed to log debug message: $error',
      );

  Either<String, Unit> info(String message,
          [dynamic error, StackTrace? stackTrace]) =>
      Either<String, Unit>.tryCatch(
        () {
          _logger.i(message, error: error, stackTrace: stackTrace);
          return unit;
        },
        (Object error, StackTrace stack) =>
            'Failed to log info message: $error',
      );

  Either<String, Unit> warning(String message,
          [dynamic error, StackTrace? stackTrace]) =>
      Either<String, Unit>.tryCatch(
        () {
          _logger.w(message, error: error, stackTrace: stackTrace);
          return unit;
        },
        (Object error, StackTrace stack) =>
            'Failed to log warning message: $error',
      );

  Either<String, Unit> error(String message,
          [dynamic error, StackTrace? stackTrace]) =>
      Either<String, Unit>.tryCatch(
        () {
          _logger.e(message, error: error, stackTrace: stackTrace);
          return unit;
        },
        (Object error, StackTrace stack) =>
            'Failed to log error message: $error',
      );

  Either<String, Unit> verbose(String message,
          [dynamic error, StackTrace? stackTrace]) =>
      Either<String, Unit>.tryCatch(
        () {
          _logger.v(message, error: error, stackTrace: stackTrace);
          return unit;
        },
        (Object error, StackTrace stack) =>
            'Failed to log verbose message: $error',
      );

  Either<String, Unit> wtf(String message,
          [dynamic error, StackTrace? stackTrace]) =>
      Either<String, Unit>.tryCatch(
        () {
          _logger.wtf(message, error: error, stackTrace: stackTrace);
          return unit;
        },
        (Object error, StackTrace stack) => 'Failed to log wtf message: $error',
      );
}
