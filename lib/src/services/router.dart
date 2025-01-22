import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

class CustomRouterService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Either<String, PageTransitionType> _getPageTransitionType(
      String transitionType) {
    try {
      final PageTransitionType type = switch (transitionType) {
        'theme' => PageTransitionType.theme,
        'fade' => PageTransitionType.fade,
        'rightToLeft' => PageTransitionType.rightToLeft,
        'leftToRight' => PageTransitionType.leftToRight,
        'topToBottom' => PageTransitionType.topToBottom,
        'bottomToTop' => PageTransitionType.bottomToTop,
        'scale' => PageTransitionType.scale,
        'rotate' => PageTransitionType.rotate,
        'size' => PageTransitionType.size,
        'rightToLeftWithFade' => PageTransitionType.rightToLeftWithFade,
        'leftToRightWithFade' => PageTransitionType.leftToRightWithFade,
        'leftToRightJoined' => PageTransitionType.leftToRightJoined,
        'rightToLeftJoined' => PageTransitionType.rightToLeftJoined,
        'topToBottomJoined' => PageTransitionType.topToBottomJoined,
        'bottomToTopJoined' => PageTransitionType.bottomToTopJoined,
        'leftToRightPop' => PageTransitionType.leftToRightPop,
        'rightToLeftPop' => PageTransitionType.rightToLeftPop,
        'topToBottomPop' => PageTransitionType.topToBottomPop,
        'bottomToTopPop' => PageTransitionType.bottomToTopPop,
        _ => throw ArgumentError('Invalid PageTransitionType: $transitionType'),
      };
      return Either<String, PageTransitionType>.right(type);
    } catch (e) {
      return Either<String, PageTransitionType>.left(
          'Invalid transition type: $transitionType');
    }
  }

  static TaskEither<String, Unit> navigateTo(String routeName,
      {Object? arguments}) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final NavigatorState? navigator = navigatorKey.currentState;
        if (navigator == null) {
          throw Exception('Navigator is not available');
        }
        await navigator.pushNamed(routeName, arguments: arguments);
        return unit;
      },
      (Object error, StackTrace stack) => 'Navigation failed: $error',
    );
  }

  TaskEither<String, Unit> navigateToWithTransition(
    Widget page,
    String transitionType, {
    Alignment? alignment,
    bool replace = false,
  }) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final Either<String, PageTransitionType> transitionTypeResult =
            _getPageTransitionType(transitionType);
        return transitionTypeResult.match(
          (String error) => throw Exception(error),
          (PageTransitionType type) async {
            final NavigatorState? navigator = navigatorKey.currentState;
            if (navigator == null) {
              throw Exception('Navigator is not available');
            }

            final PageTransition<dynamic> route = PageTransition<dynamic>(
              type: type,
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 300),
              child: page,
              alignment: alignment,
            );

            if (replace) {
              await navigator.pushReplacement(route);
            } else {
              await navigator.push(route);
            }
            return unit;
          },
        );
      },
      (Object error, StackTrace stack) => 'Navigation failed: $error',
    );
  }

  static TaskEither<String, Unit> pop<T>([T? result]) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final NavigatorState? navigator = navigatorKey.currentState;
        if (navigator == null) {
          throw Exception('Navigator is not available');
        }
        navigator.pop(result);
        return unit;
      },
      (Object error, StackTrace stack) => 'Pop failed: $error',
    );
  }

  static TaskEither<String, Unit> popUntil(String routeName) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final NavigatorState? navigator = navigatorKey.currentState;
        if (navigator == null) {
          throw Exception('Navigator is not available');
        }
        navigator.popUntil(ModalRoute.withName(routeName));
        return unit;
      },
      (Object error, StackTrace stack) => 'PopUntil failed: $error',
    );
  }

  static TaskEither<String, Unit> pushNamedAndRemoveUntil(String routeName) {
    return TaskEither<String, Unit>.tryCatch(
      () async {
        final NavigatorState? navigator = navigatorKey.currentState;
        if (navigator == null) {
          throw Exception('Navigator is not available');
        }
        navigator.pushNamedAndRemoveUntil(
          routeName,
          (Route<dynamic> route) => false,
        );
        return unit;
      },
      (Object error, StackTrace stack) =>
          'PushNamedAndRemoveUntil failed: $error',
    );
  }
}
