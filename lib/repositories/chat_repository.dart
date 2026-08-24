import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../services/database_service.dart';

class ChatRepository {
  ChatRepository(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<ChatMessage>> getMessages({int? userId}) async {
    final Database db = await _databaseService.database;
    final List<Map<String, Object?>> rows = await db.rawQuery('''
      SELECT chat_messages.*, users.name AS customerName
      FROM chat_messages
      INNER JOIN users ON users.id = chat_messages.userId
      ${userId == null ? '' : 'WHERE chat_messages.userId = ?'}
      ORDER BY chat_messages.createdAt ASC, chat_messages.id ASC
      ''', userId == null ? null : <Object?>[userId]);
    return rows.map(ChatMessage.fromMap).toList(growable: false);
  }

  Future<void> send({
    required int userId,
    required String senderRole,
    required String message,
  }) async {
    final Database db = await _databaseService.database;
    await db.insert('chat_messages', <String, Object?>{
      'userId': userId,
      'senderRole': senderRole,
      'message': message.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
