import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

enum ToastType { success, error, warning, info }

class ToasterService {
  Either<String, ToastificationType> _getToastificationType(String type) {
    try {
      final ToastificationType toastType = switch (type.toLowerCase()) {
        'success' => ToastificationType.success,
        'error' => ToastificationType.error,
        'warning' => ToastificationType.warning,
        'info' => ToastificationType.info,
        _ => ToastificationType.success,
      };
      return Either<String, ToastificationType>.right(toastType);
    } catch (e) {
      return Either<String, ToastificationType>.left(
          'Invalid toast type: $type');
    }
  }

  TaskEither<String, Unit> show({
    required BuildContext context,
    required String title,
    required String message,
    String type = 'success',
  }) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final Either<String, ToastificationType> toastTypeResult =
            _getToastificationType(type);

        return toastTypeResult.match(
          (String error) => throw Exception(error),
          (ToastificationType toastType) {
            toastification.dismissAll();

            final Map<ToastificationType, MaterialColor> typeColors =
                <ToastificationType, MaterialColor>{
              ToastificationType.success: Colors.green,
              ToastificationType.error: Colors.red,
              ToastificationType.warning: Colors.orange,
              ToastificationType.info: Colors.blue,
            };

            toastification.show(
              context: context,
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              description: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
              type: toastType,
              style: ToastificationStyle.minimal,
              autoCloseDuration: const Duration(seconds: 3),
              alignment: const Alignment(0, -0.95),
              primaryColor: typeColors[toastType] ?? Colors.blue,
              borderRadius: BorderRadius.circular(12),
              icon: Icon(_getIcon(toastType)),
              closeButtonShowType: CloseButtonShowType.onHover,
              closeOnClick: true,
              dragToClose: true,
            );
            return unit;
          },
        );
      },
      (Object error, StackTrace stack) => 'Failed to show toast: $error',
    );
  }

  IconData _getIcon(ToastificationType type) {
    return switch (type) {
      ToastificationType.success => Icons.check_circle_outline,
      ToastificationType.error => Icons.error_outline,
      ToastificationType.warning => Icons.warning_amber,
      ToastificationType.info => Icons.info_outline,
    };
  }
}
