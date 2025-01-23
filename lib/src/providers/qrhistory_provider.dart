import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/models/qrcode.dart';
import 'package:qrcode_scanner/src/providers.dart';

final AutoDisposeFutureProvider<List<QRCode>> qrHistoryProvider =
    AutoDisposeFutureProvider<List<QRCode>>(
        (AutoDisposeFutureProviderRef<List<QRCode>> ref) async {
  ref.watch(qrHistoryNotifierProvider);

  final Either<String, List<QRCode>> result =
      await ref.read(dbControllerProvider).getAllQRCodes().run();
  return result.match(
    (String error) => throw Exception(error),
    (List<QRCode> codes) => codes,
  );
});

final StateNotifierProvider<QRHistoryNotifier, int> qrHistoryNotifierProvider =
    StateNotifierProvider<QRHistoryNotifier, int>(
  (StateNotifierProviderRef<QRHistoryNotifier, int> ref) => QRHistoryNotifier(),
);

class QRHistoryNotifier extends StateNotifier<int> {
  QRHistoryNotifier() : super(0);

  void refresh() => state++;
}
