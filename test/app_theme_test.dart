import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/theme/app_theme.dart';

void main() {
  testWidgets('warm Material 3 theme renders app content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Text('Villi’s Cafe')),
      ),
    );

    expect(find.text('Villi’s Cafe'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Villi’s Cafe'))).useMaterial3,
      isTrue,
    );
  });

  testWidgets('dark Material 3 theme uses dark café surfaces', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Text('Dark QuickBite')),
      ),
    );

    final ThemeData theme = Theme.of(
      tester.element(find.text('Dark QuickBite')),
    );
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.surface.computeLuminance(), lessThan(0.1));
  });
}
