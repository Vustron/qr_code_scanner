import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:qrcode_scanner/src/providers.dart';
import 'package:qrcode_scanner/src/helpers.dart';
import 'package:qrcode_scanner/src/views.dart';

class Routes {
  static const String splash = '/';
  static const String home = '/home';

  static Map<String, Widget Function(BuildContext)> getRoutes(WidgetRef ref) {
    final List<BaseWrapper> wrappers = ref.read(wrapperProvider);

    Widget wrapRoute(Widget child) {
      return LayoutWrapper(
        wrappers: wrappers,
        child: child,
      );
    }

    return <String, Widget Function(BuildContext p1)>{
      splash: (_) => wrapRoute(const SplashView()),
      home: (_) => wrapRoute(const HomeView()),
    };
  }
}
