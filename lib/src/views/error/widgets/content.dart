import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fpdart/fpdart.dart';

import 'package:qrcode_scanner/src/constants.dart';
import 'package:qrcode_scanner/src/models.dart';

class ErrorViewContent extends StatelessWidget with GlobalStyles {
  ErrorViewContent({
    super.key,
    required this.errorModel,
    required this.onTryAgain,
  });

  final ErrorModel errorModel;
  final TaskEither<String, Unit> Function() onTryAgain;

  Option<String> getStackTrace() =>
      Option<StackTrace>.fromNullable(errorModel.stackTrace).map(
        (_) => errorModel.formatStackTrace(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF1A1A1A),
                    Color(0xFF0A0A0A),
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Lottie.asset(
                      lottieFailedMail,
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 5.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Oops! Something went wrong',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              color: Colors.red[300],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            FluentIcons.warning_24_filled,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorModel.message,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[300],
                                      height: 1.5,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    if (kDebugMode) ...<Widget>[
                      getStackTrace().match(
                        () => const SizedBox.shrink(),
                        (String stackTrace) => Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              stackTrace,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontFamily: 'Consolas',
                                    color: Colors.grey[400],
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: () => onTryAgain().run().then(
                            (Either<String, Unit> either) => either.match(
                              (String error) =>
                                  debugPrint('Error retrying: $error'),
                              (_) => null,
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            FluentIcons.arrow_sync_24_filled,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Try again',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
