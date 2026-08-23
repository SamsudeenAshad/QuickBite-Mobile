import 'package:sqflite/sqflite.dart';

import '../models/cart_item.dart';
import '../services/database_service.dart';

class CartRepository {
  CartRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<CartItem>> getCartItems() async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT
        cart.id AS cartId,
        cart.productId AS productId,
        cart.quantity AS quantity,
        product.name AS productName,
        product.description AS productDescription,
        product.category AS productCategory,
        product.price AS productPrice,
        product.image AS productImage,
        product.rating AS productRating
      FROM cart_items AS cart
      INNER JOIN products AS product ON product.id = cart.productId
      ORDER BY cart.id ASC
    ''');
    return rows.map(CartItem.fromJoinedMap).toList(growable: false);
  }

  Future<void> addProduct(int productId, {int quantity = 1}) async {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be at least 1.');
    }

    final Database db = await _databaseService.database;
    await db.transaction((Transaction transaction) async {
      final List<Map<String, Object?>> existing = await transaction.query(
        'cart_items',
        columns: <String>['id', 'quantity'],
        where: 'productId = ?',
        whereArgs: <Object?>[productId],
        limit: 1,
      );

      if (existing.isEmpty) {
        await transaction.insert('cart_items', <String, Object?>{
          'productId': productId,
          'quantity': quantity,
        });
        return;
      }

      final int cartId = (existing.first['id'] as num).toInt();
      final int oldQuantity = (existing.first['quantity'] as num).toInt();
      await transaction.update(
        'cart_items',
        <String, Object?>{'quantity': oldQuantity + quantity},
        where: 'id = ?',
        whereArgs: <Object?>[cartId],
      );
    });
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    final Database db = await _databaseService.database;
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    await db.update(
      'cart_items',
      <String, Object?>{'quantity': quantity},
      where: 'id = ?',
      whereArgs: <Object?>[cartItemId],
    );
  }

  Future<void> removeItem(int cartItemId) async {
    final Database db = await _databaseService.database;
    await db.delete(
      'cart_items',
      where: 'id = ?',
      whereArgs: <Object?>[cartItemId],
    );
  }

  Future<void> removeProduct(int productId) async {
    final Database db = await _databaseService.database;
    await db.delete(
      'cart_items',
      where: 'productId = ?',
      whereArgs: <Object?>[productId],
    );
  }

  Future<void> clearCart() async {
    final Database db = await _databaseService.database;
    await db.delete('cart_items');
  }
}
