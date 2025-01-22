import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:qrcode_scanner/src/helpers.dart';

class ErrorWrapper extends BaseWrapper {
  ErrorWrapper();

  @override
  Widget wrap(Widget child) {
    return _ErrorWrapperWidget(child: child);
  }
}

class _ErrorWrapperWidget extends ConsumerWidget {
  const _ErrorWrapperWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}
