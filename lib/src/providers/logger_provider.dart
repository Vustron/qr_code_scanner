import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:qrcode_scanner/src/services.dart';

final Provider<LoggerService> loggerProvider = Provider<LoggerService>(
  (ProviderRef<LoggerService> ref) => LoggerService(),
);
