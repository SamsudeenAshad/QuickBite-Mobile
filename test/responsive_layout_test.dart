import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/models/order.dart';
import 'package:quickbite_cafe/screens/order_confirmation_screen.dart';
import 'package:quickbite_cafe/screens/promotions_screen.dart';
import 'package:quickbite_cafe/theme/app_theme.dart';
import 'package:quickbite_cafe/utils/app_constants.dart';

void main() {
  testWidgets('promotions remain readable on a small phone with large text', (
    WidgetTester tester,
  ) async {
    _setTestScreen(tester, const Size(375, 667));

    await tester.pumpWidget(
      _TestApp(textScale: 1.6, home: const PromotionsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Promotions'), findsOneWidget);
    expect(find.text(AppConstants.promotionCode), findsOneWidget);
  });

  testWidgets('promotions support phone landscape layout', (
    WidgetTester tester,
  ) async {
    _setTestScreen(tester, const Size(667, 375));

    await tester.pumpWidget(
      const _TestApp(textScale: 1.3, home: PromotionsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('A little extra to enjoy'), findsOneWidget);
  });

  testWidgets('order confirmation supports a narrow screen and large text', (
    WidgetTester tester,
  ) async {
    _setTestScreen(tester, const Size(320, 568));
    final OrderModel order = OrderModel(
      id: 25,
      customerName: 'Sample Customer',
      phone: '0771234567',
      address: 'Colombo',
      total: 2450,
      paymentMethod: AppConstants.digitalWallet,
      status: AppConstants.orderStatusPreparing,
      createdAt: DateTime(2026, 8, 24),
    );

    await tester.pumpWidget(
      _TestApp(
        textScale: 1.8,
        home: OrderConfirmationScreen(order: order, onBackHome: _doNothing),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order Placed Successfully'), findsOneWidget);
    expect(find.text('QB1025'), findsOneWidget);
    expect(find.text('20–30 minutes'), findsOneWidget);
  });
}

void _setTestScreen(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

void _doNothing() {}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.textScale, required this.home});

  final double textScale;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: home,
    );
  }
}
