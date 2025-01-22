import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/views.dart';

TaskEither<String, Unit> globalErrorHandler(FlutterErrorDetails details) {
  return TaskEither<String, Unit>.tryCatch(
    () async {
      FlutterError.presentError(details);

      final NavigatorState? navigator =
          CustomRouterService.navigatorKey.currentState;
      if (navigator == null) {
        throw Exception('Navigator is not available');
      }

      await navigator.pushAndRemoveUntil(
        PageTransition<void>(
          type: PageTransitionType.rightToLeftWithFade,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
          child: ErrorView(error: details.exceptionAsString()),
        ),
        (_) => false,
      );

      return unit;
    },
    (Object error, StackTrace stack) => 'Failed to handle error: $error',
  );
}
