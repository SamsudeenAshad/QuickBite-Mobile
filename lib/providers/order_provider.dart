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
  String? _ordersErrorMessage;
  String? _loyaltyErrorMessage;
  String? _placementErrorMessage;
  OrderModel? _lastPlacedOrder;

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  int get loyaltyPoints => _loyaltyPoints;
  String? get ordersErrorMessage => _ordersErrorMessage;
  String? get loyaltyErrorMessage => _loyaltyErrorMessage;
  String? get placementErrorMessage => _placementErrorMessage;

  /// Kept as a convenient summary for callers that do not need to distinguish
  /// between order, loyalty, and checkout errors.
  String? get errorMessage =>
      _placementErrorMessage ?? _ordersErrorMessage ?? _loyaltyErrorMessage;
  OrderModel? get lastPlacedOrder => _lastPlacedOrder;

  Future<void> loadOrders() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _ordersErrorMessage = null;
    _loyaltyErrorMessage = null;
    notifyListeners();

    try {
      try {
        _orders = await _orderRepository.getOrders();
      } catch (error) {
        _ordersErrorMessage = 'Could not load your orders. Please try again.';
        debugPrint('OrderProvider.loadOrders: $error');
      }

      try {
        _loyaltyPoints = await _orderRepository.getLoyaltyPoints();
      } catch (error) {
        _loyaltyErrorMessage =
            'Could not refresh your loyalty points. Please try again.';
        debugPrint('OrderProvider.loadLoyaltyPoints: $error');
      }
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
    _placementErrorMessage = null;
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
      late final OrderModel savedOrder;
      try {
        savedOrder = await _orderRepository.placeOrder(order);
      } catch (error) {
        _placementErrorMessage = error is StateError
            ? error.message.toString()
            : 'Could not place your order. Please try again.';
        debugPrint('OrderProvider.placeOrder: $error');
        rethrow;
      }

      _orders = <OrderModel>[savedOrder, ..._orders];
      _lastPlacedOrder = savedOrder;
      _ordersErrorMessage = null;

      // The order is already committed at this point. Loyalty is refreshed as
      // a best-effort follow-up so a points read can never report the order as
      // failed or encourage the customer to submit it twice.
      try {
        _loyaltyPoints = await _orderRepository.getLoyaltyPoints();
        _loyaltyErrorMessage = null;
      } catch (error) {
        _loyaltyErrorMessage =
            'Your order was placed, but loyalty points could not be refreshed.';
        debugPrint('OrderProvider.refreshLoyaltyAfterOrder: $error');
      }
      return savedOrder;
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
      _ordersErrorMessage = null;
      await _orderRepository.updateOrderStatus(id, status);
      await loadOrders();
    } catch (error) {
      _ordersErrorMessage = 'Could not update the order status.';
      debugPrint('OrderProvider.updateOrderStatus: $error');
      notifyListeners();
      rethrow;
    }
  }
}
