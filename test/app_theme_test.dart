import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/theme/app_theme.dart';

void main() {
  testWidgets('warm Material 3 theme renders app content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('QuickBite Café')),
      ),
    );

    expect(find.text('QuickBite Café'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('QuickBite Café'))).useMaterial3,
      isTrue,
    );
  });
}
