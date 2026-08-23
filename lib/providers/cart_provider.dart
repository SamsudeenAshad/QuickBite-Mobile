import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../repositories/cart_repository.dart';
import '../utils/app_constants.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._cartRepository);

  final CartRepository _cartRepository;

  List<CartItem> _items = <CartItem>[];
  bool _isLoading = false;
  int _activeUpdates = 0;
  String? _errorMessage;

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isUpdating => _activeUpdates > 0;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  int get itemCount =>
      _items.fold<int>(0, (int sum, CartItem item) => sum + item.quantity);
  double get subtotal => _items.fold<double>(
    0,
    (double sum, CartItem item) => sum + item.lineTotal,
  );
  double get deliveryCharge => _items.isEmpty ? 0 : AppConstants.deliveryCharge;
  double get total => subtotal + deliveryCharge;

  Future<void> loadCart() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _cartRepository.getCartItems();
    } catch (error) {
      _errorMessage = 'Could not load your cart. Please try again.';
      debugPrint('CartProvider.loadCart: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product, {int quantity = 1}) async {
    await _runCartUpdate(
      () => _cartRepository.addProduct(product.id, quantity: quantity),
    );
  }

  Future<void> addToCart(Product product, {int quantity = 1}) {
    return addProduct(product, quantity: quantity);
  }

  Future<void> incrementQuantity(CartItem item) async {
    final int? cartItemId = item.id;
    if (cartItemId == null) {
      throw StateError('This cart item has not been saved yet.');
    }
    await _runCartUpdate(() => _cartRepository.adjustQuantity(cartItemId, 1));
  }

  Future<void> decrementQuantity(CartItem item) async {
    final int? cartItemId = item.id;
    if (cartItemId == null) {
      throw StateError('This cart item has not been saved yet.');
    }
    await _runCartUpdate(() => _cartRepository.adjustQuantity(cartItemId, -1));
  }

  Future<void> updateQuantity(CartItem item, int quantity) async {
    final int? cartItemId = item.id;
    if (cartItemId == null) {
      throw StateError('This cart item has not been saved yet.');
    }
    await _runCartUpdate(
      () => _cartRepository.updateQuantity(cartItemId, quantity),
    );
  }

  Future<void> removeItem(CartItem item) async {
    final int? cartItemId = item.id;
    if (cartItemId == null) {
      throw StateError('This cart item has not been saved yet.');
    }
    await _runCartUpdate(() => _cartRepository.removeItem(cartItemId));
  }

  Future<void> removeFromCart(CartItem item) => removeItem(item);

  Future<void> clearCart() async {
    await _runCartUpdate(_cartRepository.clearCart);
  }

  Future<void> _runCartUpdate(Future<void> Function() operation) async {
    _activeUpdates += 1;
    _errorMessage = null;
    notifyListeners();

    try {
      try {
        await operation();
      } catch (error) {
        _errorMessage = 'Could not update your cart. Please try again.';
        debugPrint('CartProvider update: $error');
        rethrow;
      }

      // A failed refresh must not turn a committed add/increment into a
      // retryable mutation, otherwise the same change could be applied twice.
      try {
        _items = await _cartRepository.getCartItems();
      } catch (error) {
        _errorMessage =
            'Your cart was updated, but it could not be refreshed. '
            'Reload the cart to see the latest items.';
        debugPrint('CartProvider refresh after update: $error');
      }
    } finally {
      _activeUpdates -= 1;
      notifyListeners();
    }
  }
}
