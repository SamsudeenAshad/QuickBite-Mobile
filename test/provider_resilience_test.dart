import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/data/sample_products.dart';
import 'package:quickbite_cafe/models/cart_item.dart';
import 'package:quickbite_cafe/models/order.dart';
import 'package:quickbite_cafe/providers/cart_provider.dart';
import 'package:quickbite_cafe/providers/order_provider.dart';
import 'package:quickbite_cafe/repositories/cart_repository.dart';
import 'package:quickbite_cafe/repositories/order_repository.dart';
import 'package:quickbite_cafe/services/database_service.dart';
import 'package:quickbite_cafe/utils/app_constants.dart';

void main() {
  group('OrderProvider resilience', () {
    test('keeps loaded order history when loyalty refresh fails', () async {
      final OrderModel savedOrder = _savedOrder();
      final repository = _OrderRepositoryStub(
        orders: <OrderModel>[savedOrder],
        failLoyaltyReads: true,
      );
      final provider = OrderProvider(repository);

      await provider.loadOrders();

      expect(provider.orders, <OrderModel>[savedOrder]);
      expect(provider.ordersErrorMessage, isNull);
      expect(provider.loyaltyErrorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('returns a committed order when loyalty refresh fails', () async {
      final repository = _OrderRepositoryStub(failLoyaltyReads: true);
      final provider = OrderProvider(repository);

      final OrderModel result = await provider.placeOrder(
        customerName: '  Samsudeen Ashad  ',
        phone: ' 0771234567 ',
        address: ' Colombo ',
        paymentMethod: AppConstants.cashOnDelivery,
      );

      expect(result.id, 7);
      expect(repository.placeOrderCalls, 1);
      expect(provider.lastPlacedOrder, result);
      expect(provider.placementErrorMessage, isNull);
      expect(provider.loyaltyErrorMessage, isNotNull);
      expect(provider.isPlacingOrder, isFalse);
    });
  });

  test(
    'does not retry a committed cart change when its refresh fails',
    () async {
      final repository = _CartRepositoryStub();
      final provider = CartProvider(repository);

      await expectLater(provider.addProduct(sampleProducts.first), completes);

      expect(repository.addProductCalls, 1);
      expect(provider.errorMessage, contains('cart was updated'));
      expect(provider.isUpdating, isFalse);
    },
  );
}

OrderModel _savedOrder() {
  return OrderModel(
    id: 7,
    customerName: 'Samsudeen Ashad',
    phone: '0771234567',
    address: 'Colombo',
    total: 1250,
    paymentMethod: AppConstants.cashOnDelivery,
    status: AppConstants.orderStatusPreparing,
    createdAt: DateTime(2026, 8, 24),
  );
}

class _OrderRepositoryStub extends OrderRepository {
  _OrderRepositoryStub({
    this.orders = const <OrderModel>[],
    this.failLoyaltyReads = false,
  }) : super(DatabaseService(databaseName: 'unused_order_resilience.db'));

  final List<OrderModel> orders;
  final bool failLoyaltyReads;
  int placeOrderCalls = 0;

  @override
  Future<List<OrderModel>> getOrders() async => orders;

  @override
  Future<int> getLoyaltyPoints() async {
    if (failLoyaltyReads) {
      throw StateError('Loyalty read failed');
    }
    return 0;
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    placeOrderCalls += 1;
    return order.copyWith(id: 7, total: 1250);
  }
}

class _CartRepositoryStub extends CartRepository {
  _CartRepositoryStub()
    : super(DatabaseService(databaseName: 'unused_cart_resilience.db'));

  int addProductCalls = 0;

  @override
  Future<void> addProduct(int productId, {int quantity = 1}) async {
    addProductCalls += 1;
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    throw StateError('Cart refresh failed');
  }
}
