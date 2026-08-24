import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/models/app_user.dart';
import 'package:quickbite_cafe/screens/chat_screen.dart';
import 'package:quickbite_cafe/theme/app_theme.dart';
import 'package:quickbite_cafe/utils/app_constants.dart';

void main() {
  test('admin users and order workflow statuses are configured', () {
    const AppUser admin = AppUser(
      id: 1,
      name: 'Administrator',
      phone: '000000000',
      email: 'admin',
      role: 'admin',
    );

    expect(admin.isAdmin, isTrue);
    expect(
      AppConstants.adminOrderStatuses,
      containsAll(<String>['Confirmed', 'Rejected', 'Delivered']),
    );
  });

  testWidgets('café chat accepts a customer message and replies', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const ChatScreen()),
    );

    expect(find.text('Chat with café'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'What is the delivery time?',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    expect(find.text('What is the delivery time?'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    expect(find.textContaining('delivery charge'), findsOneWidget);
  });
}
