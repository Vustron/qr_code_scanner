import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:qrcode_scanner/src/services/error.dart';
import 'package:qrcode_scanner/src/controllers.dart';

final Provider<ErrorService> errorServiceProvider =
    Provider<ErrorService>((ProviderRef<ErrorService> ref) {
  return ErrorService(ref);
});

final Provider<ErrorController> errorControllerProvider =
    Provider<ErrorController>((ProviderRef<ErrorController> ref) {
  final ErrorService repository = ref.watch(errorServiceProvider);
  return ErrorController(ref, repository);
});
