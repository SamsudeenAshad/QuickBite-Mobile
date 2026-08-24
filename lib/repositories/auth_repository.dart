import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../services/database_service.dart';

class AuthRepository {
  AuthRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<AppUser?> restoreSession() async {
    final Database db = await _databaseService.database;
    await _ensureAdmin(db);
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT users.id, users.name, users.phone, users.email, users.role
      FROM auth_session
      INNER JOIN users ON users.id = auth_session.userId
      WHERE auth_session.id = 1
      LIMIT 1
    ''');
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final Database db = await _databaseService.database;
    await _ensureAdmin(db);
    final String normalizedEmail = email.trim().toLowerCase();

    return db.transaction<AppUser>((Transaction transaction) async {
      final int userId = await transaction.insert('users', <String, Object?>{
        'name': name.trim(),
        'phone': phone.trim(),
        'email': normalizedEmail,
        'passwordHash': _hashPassword(normalizedEmail, password),
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _saveSession(transaction, userId);
      return AppUser(
        id: userId,
        name: name.trim(),
        phone: phone.trim(),
        email: normalizedEmail,
      );
    });
  }

  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final Database db = await _databaseService.database;
    final String normalizedEmail = email.trim().toLowerCase();
    final List<Map<String, Object?>> rows = await db.query(
      'users',
      columns: <String>['id', 'name', 'phone', 'email', 'role'],
      where: 'email = ? AND passwordHash = ?',
      whereArgs: <Object?>[
        normalizedEmail,
        _hashPassword(normalizedEmail, password),
      ],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final AppUser user = AppUser.fromMap(rows.first);
    await _saveSession(db, user.id);
    return user;
  }

  Future<void> logout() async {
    final Database db = await _databaseService.database;
    await db.delete('auth_session');
  }

  Future<void> _saveSession(DatabaseExecutor db, int userId) async {
    await db.insert('auth_session', <String, Object?>{
      'id': 1,
      'userId': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String _hashPassword(String email, String password) {
    return sha256.convert(utf8.encode('$email:$password')).toString();
  }

  Future<void> _ensureAdmin(Database db) async {
    await db.insert('users', <String, Object?>{
      'name': 'Villi’s Cafe Administrator',
      'phone': '000000000',
      'email': 'admin',
      'passwordHash': _hashPassword('admin', 'admin123'),
      'role': 'admin',
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
