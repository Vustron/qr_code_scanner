import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:qrcode_scanner/src/services.dart';

final Provider<ToasterService> toasterProvider = Provider<ToasterService>(
  (ProviderRef<ToasterService> ref) => ToasterService(),
);
