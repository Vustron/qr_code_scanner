import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/constants.dart';
import 'package:qrcode_scanner/src/views.dart';

class SplashView extends HookConsumerWidget {
  const SplashView({super.key});

  TaskEither<String, Unit> initUI() => TaskEither<String, Unit>.tryCatch(
        () async {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            systemNavigationBarColor: Colors.black,
          ));
          return unit;
        },
        (Object error, StackTrace stack) => 'Failed to initialize UI: $error',
      );

  TaskEither<String, Unit> navigateToHome(BuildContext context) =>
      TaskEither<String, Unit>.tryCatch(
        () async {
          await Future<dynamic>.delayed(const Duration(milliseconds: 2000));
          if (context.mounted) {
            await Navigator.pushReplacementNamed(context, Routes.home);
          }
          return unit;
        },
        (Object error, StackTrace stack) => 'Failed to navigate: $error',
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      initUI()
          .andThen(() => navigateToHome(context))
          .run()
          .then((Either<String, Unit> either) => either.match(
                (String error) => debugPrint(error),
                (_) => null,
              ));
      return null;
    }, const <Object?>[]);

    return const Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedLogo(),
        ],
      ),
    );
  }
}
