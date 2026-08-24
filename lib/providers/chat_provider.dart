import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._repository);

  final ChatRepository _repository;
  List<ChatMessage> _messages = <ChatMessage>[];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> loadForCustomer(int userId) => _load(userId: userId);
  Future<void> loadForAdmin() => _load();

  Future<void> _load({int? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _messages = await _repository.getMessages(userId: userId);
    } catch (error) {
      _errorMessage = 'Could not load café messages.';
      debugPrint('ChatProvider.load: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendCustomerMessage(int userId, String message) async {
    await _send(userId, 'customer', message);
    await loadForCustomer(userId);
  }

  Future<void> sendAdminReply(int userId, String message) async {
    await _send(userId, 'admin', message);
    await loadForAdmin();
  }

  Future<void> _send(int userId, String role, String message) async {
    if (_isSending || message.trim().isEmpty) return;
    _isSending = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.send(
        userId: userId,
        senderRole: role,
        message: message,
      );
    } catch (error) {
      _errorMessage = 'Message could not be sent.';
      debugPrint('ChatProvider.send: $error');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
