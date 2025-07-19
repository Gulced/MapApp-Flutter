import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  // DBHelper.instance değil, DBHelper() çağırıyoruz
  final DBHelper _db = DBHelper();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _user;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  Future<void> register(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final existing = await _db.getUserByEmail(email);
      if (existing != null) {
        _errorMessage = 'Bu email zaten kayıtlı';
        _status = AuthStatus.error;
      } else {
        final id = await _db.createUser(
          User(email: email, password: password),
        );
        _user = User(id: id, email: email, password: password);
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      _errorMessage = 'Kayıt sırasında hata: $e';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final existing = await _db.getUserByEmail(email);
      if (existing == null || existing.password != password) {
        _errorMessage = 'Email veya şifre hatalı';
        _status = AuthStatus.error;
      } else {
        _user = existing;
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      _errorMessage = 'Giriş sırasında hata: $e';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  void logout() {
    _user = null;
    _status = AuthStatus.initial;
    notifyListeners();
  }
}
