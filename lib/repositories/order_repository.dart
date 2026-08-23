import 'package:sqflite/sqflite.dart';

import '../models/order.dart';
import '../services/database_service.dart';
import '../utils/app_constants.dart';

class OrderRepository {
  OrderRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<OrderModel>> getOrders() async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.query(
      'orders',
      orderBy: 'createdAt DESC, id DESC',
    );
    return rows.map(OrderModel.fromMap).toList(growable: false);
  }

  Future<OrderModel?> getOrderById(int id) async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    return rows.isEmpty ? null : OrderModel.fromMap(rows.first);
  }

  /// Saves the order and clears the cart in one transaction. If either action
  /// fails, SQLite rolls both actions back.
  Future<OrderModel> placeOrder(OrderModel order) async {
    final Database db = await _databaseService.database;
    return db.transaction((Transaction transaction) async {
      final List<Map<String, Object?>> cartRows = await transaction.rawQuery('''
        SELECT cart.quantity AS quantity, product.price AS price
        FROM cart_items AS cart
        INNER JOIN products AS product ON product.id = cart.productId
      ''');

      if (cartRows.isEmpty) {
        throw StateError(
          'Your cart is empty. Add an item before checking out.',
        );
      }

      final double subtotal = cartRows.fold<double>(0, (
        double sum,
        Map<String, Object?> row,
      ) {
        final int quantity = (row['quantity'] as num).toInt();
        final double price = (row['price'] as num).toDouble();
        return sum + (price * quantity);
      });
      final OrderModel pricedOrder = order.copyWith(
        total: subtotal + AppConstants.deliveryCharge,
      );
      final int id = await transaction.insert(
        'orders',
        pricedOrder.toMap(includeId: false),
      );
      await transaction.delete('cart_items');
      return pricedOrder.copyWith(id: id);
    });
  }

  Future<void> updateOrderStatus(int id, String status) async {
    final Database db = await _databaseService.database;
    await db.update(
      'orders',
      <String, Object?>{'status': status},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> getLoyaltyPoints() async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> result = await db.rawQuery(
      '''
        SELECT COALESCE(SUM(total), 0) AS qualifyingTotal
        FROM orders
        WHERE status != ?
      ''',
      <Object?>[AppConstants.orderStatusCancelled],
    );
    final double qualifyingTotal =
        (result.first['qualifyingTotal'] as num?)?.toDouble() ?? 0;
    return qualifyingTotal ~/ AppConstants.loyaltyPointSpend;
  }
}
