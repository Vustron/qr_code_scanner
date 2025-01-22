import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:qrcode_scanner/src/helpers.dart';

final Provider<List<BaseWrapper>> wrapperProvider =
    Provider<List<BaseWrapper>>((ProviderRef<List<BaseWrapper>> ref) {
  return <BaseWrapper>[
    ErrorWrapper(),
  ];
});
