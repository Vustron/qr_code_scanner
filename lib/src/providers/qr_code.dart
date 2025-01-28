import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:qrcode_scanner/src/models/qrcode.dart';
import 'package:qrcode_scanner/src/controllers.dart';
import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/models.dart';
import 'package:sqflite_common/sqlite_api.dart';

final Provider<QRCodeController> qrCodeControllerProvider =
    Provider<QRCodeController>((ProviderRef<QRCodeController> ref) {
  ref.watch(dbInitProvider);

  final QRCodeService service = ref.watch(qrCodeServiceProvider);
  return QRCodeController(service, ref);
});

final Provider<QRCodeService> qrCodeServiceProvider =
    Provider<QRCodeService>((ProviderRef<QRCodeService> ref) {
  final AsyncValue<Unit> dbInit = ref.watch(dbInitProvider);

  return dbInit.when(
    loading: () => throw Exception('Database initializing...'),
    error: (Object error, _) => throw Exception('Database init failed: $error'),
    data: (_) {
      final LoggerService logger = ref.watch(loggerProvider);
      final Database? db = ref.watch(databaseProvider);

      if (db == null) {
        throw Exception('Database not initialized');
      }

      return QRCodeService(logger, db);
    },
  );
});

final FutureProviderFamily<QRCode, String> qrCodeProvider =
    FutureProvider.family<QRCode, String>(
        (FutureProviderRef<QRCode> ref, String id) async {
  final QRCodeService service = ref.watch(qrCodeServiceProvider);
  final Either<String, QRCode> result = await service.getQRCode(id).run();
  return result.match(
    (String error) => throw Exception(error),
    (QRCode qrCode) => qrCode,
  );
});

final StateNotifierProvider<QRCodeNotifier, AsyncValue<List<QRCode>>>
    qrHistoryNotifierProvider =
    StateNotifierProvider<QRCodeNotifier, AsyncValue<List<QRCode>>>(
        (StateNotifierProviderRef<QRCodeNotifier, AsyncValue<List<QRCode>>>
            ref) {
  return QRCodeNotifier(ref);
});

class QRCodeNotifier extends StateNotifier<AsyncValue<List<QRCode>>> {
  QRCodeNotifier(this.ref) : super(const AsyncValue<List<QRCode>>.loading()) {
    loadQRCodes();
  }

  final Ref ref;

  Future<void> loadQRCodes() async {
    state = const AsyncValue<List<QRCode>>.loading();
    final QRCodeService service = ref.read(qrCodeServiceProvider);
    final Either<String, List<QRCode>> result =
        await service.getAllQRCodes().run();

    if (!mounted) return;

    state = result.match(
      (String error) =>
          AsyncValue<List<QRCode>>.error(error, StackTrace.current),
      (List<QRCode> qrCodes) => AsyncValue<List<QRCode>>.data(qrCodes),
    );
  }

  Future<void> refresh() async {
    await loadQRCodes();
  }
}

class QRHistoryNotifier extends StateNotifier<int> {
  QRHistoryNotifier() : super(0);

  void refresh() => state++;
}
