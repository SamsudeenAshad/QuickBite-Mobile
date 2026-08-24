import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../data/sample_products.dart';
import '../utils/app_constants.dart';

class DatabaseService {
  DatabaseService({this.databaseName = AppConstants.databaseName});

  static final DatabaseService instance = DatabaseService();

  final String databaseName;
  Future<Database>? _databaseFuture;

  Future<Database> get database {
    _databaseFuture ??= _openDatabase();
    return _databaseFuture!;
  }

  Future<Database> _openDatabase() async {
    final String databasesDirectory = await getDatabasesPath();
    final String databasePath = path.join(databasesDirectory, databaseName);

    return openDatabase(
      databasePath,
      version: AppConstants.databaseVersion,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL CHECK(price >= 0),
        image TEXT NOT NULL,
        rating REAL NOT NULL CHECK(rating >= 0 AND rating <= 5)
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL UNIQUE,
        quantity INTEGER NOT NULL CHECK(quantity > 0),
        FOREIGN KEY(productId) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        total REAL NOT NULL CHECK(total >= 0),
        paymentMethod TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await _createAuthenticationTables(db);
    await _createChatTable(db);

    await db.execute(
      'CREATE INDEX idx_products_category ON products(category)',
    );
    await db.execute(
      'CREATE INDEX idx_orders_created_at ON orders(createdAt DESC)',
    );

    final Batch batch = db.batch();
    for (final product in sampleProducts) {
      batch.insert('products', product.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createAuthenticationTables(db);
    } else if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'customer'",
      );
    }
    if (oldVersion < 4) {
      await _createChatTable(db);
    }
  }

  Future<void> _createAuthenticationTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        passwordHash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'customer',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE auth_session (
        id INTEGER PRIMARY KEY CHECK(id = 1),
        userId INTEGER NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createChatTable(Database db) async {
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        senderRole TEXT NOT NULL,
        message TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_chat_user_created ON chat_messages(userId, createdAt)',
    );
  }

  Future<void> close() async {
    final Future<Database>? databaseFuture = _databaseFuture;
    if (databaseFuture == null) {
      return;
    }

    final Database db = await databaseFuture;
    await db.close();
    _databaseFuture = null;
  }
}
