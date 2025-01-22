import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/constants.dart';

class AudioPlayerService {
  AudioPlayerService() {
    audioPlayer = AudioPlayer();
    initAudio();
  }

  late final AudioPlayer audioPlayer;

  Future<void> initAudio() async {
    await audioPlayer.setVolume(1.0);
  }

  TaskEither<String, Unit> startScanningSound() {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        debugPrint('Starting scanning sound: $scanning');
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.setVolume(1.0);

        final AssetSource source = AssetSource(scanning);
        debugPrint('Playing from source: ${source.path}');

        await audioPlayer.play(source);
        debugPrint('Scanning sound started');
        return unit;
      },
      (Object error, StackTrace stack) {
        debugPrint('Error playing scanning sound: $error\n$stack');
        return 'Failed to play scanning sound: $error';
      },
    );
  }

  TaskEither<String, Unit> successfulScanningSound() {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        debugPrint('Playing success sound');
        await audioPlayer.stop();
        await audioPlayer.setReleaseMode(ReleaseMode.release);
        await audioPlayer.setVolume(1.0);
        await audioPlayer.play(AssetSource(success));
        return unit;
      },
      (Object error, StackTrace stack) {
        debugPrint('Error playing success sound: $error\n$stack');
        return 'Failed to play success sound: $error';
      },
    );
  }

  TaskEither<String, Unit> errorScanningSound() {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        await audioPlayer.stop();
        await audioPlayer.setReleaseMode(ReleaseMode.release);
        await audioPlayer.play(AssetSource(error));
        return unit;
      },
      (Object error, StackTrace stack) => 'Failed to play error sound: $error',
    );
  }

  TaskEither<String, Unit> stopSound() {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        await audioPlayer.stop();
        return unit;
      },
      (Object error, StackTrace stack) => 'Failed to stop sound: $error',
    );
  }

  void dispose() {
    debugPrint('Disposing AudioPlayer');
    audioPlayer.dispose();
  }
}
