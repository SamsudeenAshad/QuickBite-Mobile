import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import '../services/database_service.dart';

class ProductRepository {
  ProductRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<Product>> getProducts() async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.query(
      'products',
      orderBy: 'category ASC, name ASC',
    );
    return rows.map(Product.fromMap).toList(growable: false);
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: <Object?>[category],
      orderBy: 'name ASC',
    );
    return rows.map(Product.fromMap).toList(growable: false);
  }

  Future<Product?> getProductById(int id) async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    return rows.isEmpty ? null : Product.fromMap(rows.first);
  }

  Future<int> addProduct(Product product) async {
    final Database db = await _databaseService.database;
    final Map<String, Object?> values = product.toMap()..remove('id');
    return db.insert('products', values);
  }

  Future<void> updateProduct(Product product) async {
    final Database db = await _databaseService.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: <Object?>[product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final Database db = await _databaseService.database;
    await db.delete('products', where: 'id = ?', whereArgs: <Object?>[id]);
  }
}
