import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/models/cart_item.dart';
import 'package:quickbite_cafe/models/order.dart';
import 'package:quickbite_cafe/models/product.dart';

void main() {
  const product = Product(
    id: 7,
    name: 'Chocolate Cake',
    description: 'Rich chocolate sponge.',
    category: 'Desserts',
    price: 650,
    image: 'cake.jpg',
    rating: 4.9,
  );

  test('Product converts to and from a database map', () {
    final restored = Product.fromMap(product.toMap());

    expect(restored.id, product.id);
    expect(restored.name, product.name);
    expect(restored.price, product.price);
    expect(restored.rating, product.rating);
  });

  test('CartItem calculates its line total', () {
    const item = CartItem(productId: 7, quantity: 3, product: product);

    expect(item.lineTotal, 1950);
  });

  test('OrderModel formats a friendly QuickBite order number', () {
    final order = OrderModel(
      id: 25,
      customerName: 'Sample Customer',
      phone: '0771234567',
      address: 'Colombo',
      total: 2150,
      paymentMethod: 'Cash on Delivery',
      status: 'Preparing',
      createdAt: DateTime(2026, 8, 24),
    );

    expect(order.displayId, 'QB1025');
  });
}
