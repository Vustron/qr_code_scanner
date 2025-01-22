import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/services.dart';

final Provider<Dio> dioProvider = Provider<Dio>(
  (ProviderRef<Dio> ref) => Dio(),
);

final Provider<HttpApiService> httpApiProvider =
    Provider<HttpApiService>((ProviderRef<dynamic> ref) {
  final Dio dio = ref.watch(dioProvider);
  final LoggerService logger = ref.watch(loggerProvider);
  return HttpApiService(dio, logger);
});
