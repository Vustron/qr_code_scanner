import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/controllers.dart';
import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/constants.dart';
import 'package:qrcode_scanner/src/models.dart';
import 'package:qrcode_scanner/src/views.dart';

class ErrorView extends HookConsumerWidget with GlobalStyles {
  ErrorView({
    super.key,
    required this.error,
    this.stackTrace,
  });

  final String error;
  final StackTrace? stackTrace;

  Either<String, ErrorModel> _createErrorModel() =>
      Either<String, ErrorModel>.tryCatch(
        () => ErrorModel(
          message: error,
          stackTrace: Option<StackTrace>.fromNullable(stackTrace).toNullable(),
        ),
        (Object error, StackTrace stack) =>
            'Failed to create error model: $error',
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ErrorController controller = ref.watch(errorControllerProvider);

    useEffect(() {
      _createErrorModel().fold(
        (String error) => debugPrint(error),
        (ErrorModel errorModel) => controller.initError(errorModel).run().then(
              (Either<String, Unit> either) => either.match(
                (String error) =>
                    debugPrint('Failed to initialize error: $error'),
                (_) => null,
              ),
            ),
      );
      return null;
    }, const <Object?>[]);

    return _createErrorModel().match(
      (String error) => Center(child: Text('Failed to display error: $error')),
      (ErrorModel errorModel) => ErrorViewContent(
        errorModel: errorModel,
        onTryAgain: controller.handleTryAgain,
      ),
    );
  }
}
