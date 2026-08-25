import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quickbite_cafe/data/sample_promotions.dart';
import 'package:quickbite_cafe/models/order.dart';
import 'package:quickbite_cafe/providers/order_provider.dart';
import 'package:quickbite_cafe/repositories/order_repository.dart';
import 'package:quickbite_cafe/screens/orders_screen.dart';
import 'package:quickbite_cafe/screens/profile_screen.dart';
import 'package:quickbite_cafe/screens/promotions_screen.dart';
import 'package:quickbite_cafe/services/database_service.dart';
import 'package:quickbite_cafe/theme/app_theme.dart';
import 'package:quickbite_cafe/utils/app_constants.dart';

void main() {
  test('sample promotions include the featured Weekend Special', () {
    final promotionCodes = samplePromotions
        .map((promotion) => promotion.code)
        .toSet();

    expect(promotionCodes, hasLength(samplePromotions.length));
    expect(promotionCodes, contains(AppConstants.promotionCode));
    expect(
      samplePromotions
          .singleWhere(
            (promotion) => promotion.code == AppConstants.promotionCode,
          )
          .isFeatured,
      isTrue,
    );
  });

  testWidgets('promotions screen displays every available promo code', (
    tester,
  ) async {
    await _setLargeTestScreen(tester);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PromotionsScreen()),
    );

    expect(find.text('Promotions'), findsOneWidget);
    expect(find.text('FEATURED'), findsOneWidget);
    for (final promotion in samplePromotions) {
      expect(find.text(promotion.title), findsOneWidget);
      expect(find.text(promotion.code), findsOneWidget);
    }
  });

  testWidgets('profile displays loyalty points and opens order history', (
    tester,
  ) async {
    await _setLargeTestScreen(tester);
    final orders = OrderProvider(_FakeOrderRepository(loyaltyPoints: 42));
    await orders.loadOrders();
    var openedOrders = false;

    await tester.pumpWidget(
      ChangeNotifierProvider<OrderProvider>.value(
        value: orders,
        child: MaterialApp(
          theme: AppTheme.light,
          home: ProfileScreen(
            onOpenOrders: () {
              openedOrders = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('42'), findsOneWidget);
    expect(
      find.text(
        'Earn 1 point for every Rs. 100 spent on non-cancelled orders.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('My orders'));
    await tester.pump();

    expect(openedOrders, isTrue);
  });

  testWidgets('orders screen presents saved orders newest first', (
    tester,
  ) async {
    await _setLargeTestScreen(tester);
    final olderOrder = _order(
      id: 1,
      total: 1450,
      status: AppConstants.orderStatusCompleted,
      createdAt: DateTime(2026, 8, 20, 12, 30),
    );
    final newerOrder = _order(
      id: 2,
      total: 2450,
      status: AppConstants.orderStatusPreparing,
      createdAt: DateTime(2026, 8, 24, 18, 15),
    );
    final orders = OrderProvider(
      _FakeOrderRepository(orders: <OrderModel>[olderOrder, newerOrder]),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<OrderProvider>.value(
        value: orders,
        child: MaterialApp(theme: AppTheme.light, home: const OrdersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 orders'), findsOneWidget);
    expect(find.text('QB1001'), findsOneWidget);
    expect(find.text('QB1002'), findsOneWidget);
    expect(find.text('Rs. 2450.00'), findsOneWidget);
    expect(find.text(AppConstants.orderStatusPreparing), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('QB1002')).dy,
      lessThan(tester.getTopLeft(find.text('QB1001')).dy),
    );
  });
}

Future<void> _setLargeTestScreen(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 2000);
  addTearDown(tester.view.reset);
}

OrderModel _order({
  required int id,
  required double total,
  required String status,
  required DateTime createdAt,
}) {
  return OrderModel(
    id: id,
    customerName: 'Sample Customer',
    phone: '0771234567',
    address: 'Colombo',
    total: total,
    paymentMethod: AppConstants.cashOnDelivery,
    status: status,
    createdAt: createdAt,
  );
}

class _FakeOrderRepository extends OrderRepository {
  _FakeOrderRepository({
    this.orders = const <OrderModel>[],
    this.loyaltyPoints = 0,
  }) : super(DatabaseService(databaseName: 'unused_phase5_test.db'));

  final List<OrderModel> orders;
  final int loyaltyPoints;

  @override
  Future<List<OrderModel>> getOrders() async => orders;

  @override
  Future<int> getLoyaltyPoints() async => loyaltyPoints;
}
