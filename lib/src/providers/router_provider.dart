import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:qrcode_scanner/src/services.dart';

final Provider<CustomRouterService> routerProvider =
    Provider<CustomRouterService>(
  (ProviderRef<CustomRouterService> ref) => CustomRouterService(),
);
