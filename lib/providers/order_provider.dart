import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../repositories/order_repository.dart';
import '../utils/app_constants.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderRepository);

  final OrderRepository _orderRepository;

  List<OrderModel> _orders = <OrderModel>[];
  bool _isLoading = false;
  bool _isPlacingOrder = false;
  int _loyaltyPoints = 0;
  String? _errorMessage;
  OrderModel? _lastPlacedOrder;

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  int get loyaltyPoints => _loyaltyPoints;
  String? get errorMessage => _errorMessage;
  OrderModel? get lastPlacedOrder => _lastPlacedOrder;

  Future<void> loadOrders() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<OrderModel> loadedOrders = await _orderRepository.getOrders();
      final int loadedPoints = await _orderRepository.getLoyaltyPoints();
      _orders = loadedOrders;
      _loyaltyPoints = loadedPoints;
    } catch (error) {
      _errorMessage = 'Could not load your orders. Please try again.';
      debugPrint('OrderProvider.loadOrders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    if (_isPlacingOrder) {
      throw StateError('An order is already being placed.');
    }

    _isPlacingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final OrderModel order = OrderModel(
        customerName: customerName.trim(),
        phone: phone.trim(),
        address: address.trim(),
        // The repository calculates the authoritative amount from SQLite.
        total: 0,
        paymentMethod: paymentMethod,
        status: AppConstants.orderStatusPreparing,
        createdAt: DateTime.now(),
      );
      final OrderModel savedOrder = await _orderRepository.placeOrder(order);
      _orders = <OrderModel>[savedOrder, ..._orders];
      _lastPlacedOrder = savedOrder;
      _loyaltyPoints = await _orderRepository.getLoyaltyPoints();
      return savedOrder;
    } catch (error) {
      _errorMessage = error is StateError
          ? error.message.toString()
          : 'Could not place your order. Please try again.';
      debugPrint('OrderProvider.placeOrder: $error');
      rethrow;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(OrderModel order, String status) async {
    final int? id = order.id;
    if (id == null) {
      throw StateError('This order has not been saved yet.');
    }

    try {
      await _orderRepository.updateOrderStatus(id, status);
      await loadOrders();
    } catch (error) {
      _errorMessage = 'Could not update the order status.';
      debugPrint('OrderProvider.updateOrderStatus: $error');
      notifyListeners();
      rethrow;
    }
  }
}
