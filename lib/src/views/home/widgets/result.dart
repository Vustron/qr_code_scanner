import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  const ResultView({
    required this.result,
    required this.onScanAgain,
    super.key,
  });

  final String result;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onScanAgain,
              child: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }
}
