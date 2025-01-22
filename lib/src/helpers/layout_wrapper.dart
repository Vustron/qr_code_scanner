import 'package:flutter/material.dart';

import 'package:qrcode_scanner/src/helpers.dart';

class LayoutWrapper extends StatelessWidget {
  const LayoutWrapper({
    super.key,
    required this.child,
    required this.wrappers,
  });

  final Widget child;
  final List<BaseWrapper> wrappers;

  @override
  Widget build(BuildContext context) {
    Widget wrappedChild = child;

    for (final BaseWrapper wrapper in wrappers.reversed) {
      wrappedChild = wrapper.wrap(wrappedChild);
    }

    return wrappedChild;
  }
}
