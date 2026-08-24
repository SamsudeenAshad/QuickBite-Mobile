import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;
  AppUser? _currentUser;
  bool _isInitializing = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isInitializing => _isInitializing;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    try {
      _currentUser = await _repository.restoreSession();
    } catch (_) {
      _errorMessage = 'We could not restore your session.';
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    return _submit(() async {
      final AppUser? user = await _repository.signIn(
        email: email,
        password: password,
      );
      if (user == null) {
        _errorMessage = 'Incorrect email or password.';
        return false;
      }
      _currentUser = user;
      return true;
    });
  }

  Future<bool> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    return _submit(() async {
      try {
        _currentUser = await _repository.signUp(
          name: name,
          phone: phone,
          email: email,
          password: password,
        );
        return true;
      } on DatabaseException catch (error) {
        if (error.isUniqueConstraintError()) {
          _errorMessage = 'An account already uses this email.';
          return false;
        }
        rethrow;
      }
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _submit(Future<bool> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await action();
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
