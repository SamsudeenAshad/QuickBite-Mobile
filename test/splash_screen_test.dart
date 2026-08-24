import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/screens/splash_screen.dart';

void main() {
  testWidgets('splash shows the brand and finishes after its duration', (
    tester,
  ) async {
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          duration: const Duration(milliseconds: 50),
          onFinished: () => finished = true,
        ),
      ),
    );

    expect(find.text('Villi’s Cafe'), findsOneWidget);
    expect(finished, isFalse);

    await tester.pump(const Duration(milliseconds: 51));
    expect(finished, isTrue);
  });
}
