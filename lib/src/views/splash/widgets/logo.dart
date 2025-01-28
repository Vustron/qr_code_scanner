import 'package:flutter/material.dart';
import 'package:qrcode_scanner/src/constants.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Image.asset(logo),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          strokeWidth: 2,
        ),
      ],
    );
  }
}
