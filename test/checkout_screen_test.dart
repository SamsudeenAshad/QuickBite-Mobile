import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quickbite_cafe/providers/cart_provider.dart';
import 'package:quickbite_cafe/providers/order_provider.dart';
import 'package:quickbite_cafe/repositories/cart_repository.dart';
import 'package:quickbite_cafe/repositories/order_repository.dart';
import 'package:quickbite_cafe/screens/checkout_screen.dart';
import 'package:quickbite_cafe/services/database_service.dart';

void main() {
  testWidgets('checkout prevents an empty cart from being submitted', (
    tester,
  ) async {
    final database = DatabaseService(databaseName: 'unused_checkout_test.db');
    final cart = CartProvider(CartRepository(database));
    final orders = OrderProvider(OrderRepository(database));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider<OrderProvider>.value(value: orders),
        ],
        child: MaterialApp(home: CheckoutScreen(onBackHome: () {})),
      ),
    );

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Place Order'), findsNothing);
  });
}
