import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qrcode_scanner/src/services.dart';

final Provider<AudioPlayerService> audioPlayerProvider =
    Provider<AudioPlayerService>((ProviderRef<AudioPlayerService> ref) {
  final AudioPlayerService service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});
