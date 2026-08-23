import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quickbite_cafe/providers/cart_provider.dart';
import 'package:quickbite_cafe/repositories/cart_repository.dart';
import 'package:quickbite_cafe/screens/cart_screen.dart';
import 'package:quickbite_cafe/services/database_service.dart';
import 'package:quickbite_cafe/utils/currency_formatter.dart';

void main() {
  test('currency formatter displays Sri Lankan rupee values', () {
    expect(formatCurrency(1250), 'Rs. 1250.00');
  });

  testWidgets('cart screen shows a helpful empty state', (tester) async {
    final cart = CartProvider(
      CartRepository(DatabaseService(databaseName: 'unused_test.db')),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<CartProvider>.value(
        value: cart,
        child: MaterialApp(home: CartScreen(onCheckout: () {})),
      ),
    );

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Proceed to Checkout'), findsNothing);
  });
}
