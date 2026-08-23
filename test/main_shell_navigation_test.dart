import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quickbite_cafe/models/order.dart';
import 'package:quickbite_cafe/providers/cart_provider.dart';
import 'package:quickbite_cafe/providers/navigation_provider.dart';
import 'package:quickbite_cafe/providers/order_provider.dart';
import 'package:quickbite_cafe/providers/product_provider.dart';
import 'package:quickbite_cafe/repositories/cart_repository.dart';
import 'package:quickbite_cafe/repositories/order_repository.dart';
import 'package:quickbite_cafe/repositories/product_repository.dart';
import 'package:quickbite_cafe/screens/main_shell.dart';
import 'package:quickbite_cafe/services/database_service.dart';
import 'package:quickbite_cafe/theme/app_theme.dart';

void main() {
  testWidgets('all five bottom navigation destinations are available', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);

    final DatabaseService unusedDatabase = DatabaseService(
      databaseName: 'unused_main_shell_test.db',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: <ChangeNotifierProvider<ChangeNotifier>>[
          ChangeNotifierProvider<NavigationProvider>(
            create: (_) => NavigationProvider(),
          ),
          ChangeNotifierProvider<ProductProvider>(
            create: (_) => ProductProvider(ProductRepository(unusedDatabase)),
          ),
          ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider(CartRepository(unusedDatabase)),
          ),
          ChangeNotifierProvider<OrderProvider>(
            create: (_) => OrderProvider(_EmptyOrderRepository()),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const MainShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('QuickBite Café'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Our menu'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is waiting'), findsOneWidget);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('No orders yet'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Samsudeen Ashad'), findsOneWidget);
  });
}

class _EmptyOrderRepository extends OrderRepository {
  _EmptyOrderRepository()
    : super(DatabaseService(databaseName: 'unused_orders_test.db'));

  @override
  Future<List<OrderModel>> getOrders() async => <OrderModel>[];

  @override
  Future<int> getLoyaltyPoints() async => 0;
}
