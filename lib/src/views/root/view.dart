import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:qrcode_scanner/src/constants.dart';
import 'package:qrcode_scanner/src/services.dart';
import 'package:qrcode_scanner/src/helpers.dart';
import 'package:qrcode_scanner/src/config.dart';

class App extends ConsumerWidget with GlobalStyles {
  App({super.key}) {
    FlutterError.onError = globalErrorHandler;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) => MaterialApp(
        navigatorKey: CustomRouterService.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Vustron QR Scanner',
        themeMode: ThemeMode.light,
        theme: rootThemeData(),
        initialRoute: Routes.splash,
        routes: Routes.getRoutes(ref),
        builder: (BuildContext context, Widget? widget) {
          if (widget == null) {
            return const SizedBox.shrink();
          }
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, _) => widget,
            ),
          );
        },
      ),
    );
  }
}
