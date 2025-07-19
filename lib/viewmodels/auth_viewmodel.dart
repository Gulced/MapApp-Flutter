// lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/user.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthViewModel extends ChangeNotifier {
  final DBHelper _db = DBHelper();

  AuthStatus _status = AuthStatus.initial;
  String?    _errorMessage;
  User?      _user;

  AuthStatus get status       => _status;
  String?    get errorMessage => _errorMessage;
  User?      get user         => _user;

  /// Yeni kullanıcı kaydı. isAdmin varsayılan olarak false.
  Future<void> register(
      String email,
      String password, {
        bool isAdmin = false,
      }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final existing = await _db.getUserByEmail(email);
      if (existing != null) {
        _errorMessage = 'Bu email zaten kayıtlı';
        _status       = AuthStatus.error;
      } else {
        // DBHelper.createUser, User.toMap() içindeki isAdmin değerini de kullanır.
        final id = await _db.createUser(
          User(
            id:       0,
            email:    email,
            password: password,
            isAdmin:  isAdmin,
          ),
        );
        _user   = User(
          id:       id,
          email:    email,
          password: password,
          isAdmin:  isAdmin,
        );
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      _errorMessage = 'Kayıt sırasında hata: $e';
      _status       = AuthStatus.error;
    }

    notifyListeners();
  }

  /// Mevcut kullanıcı girişi. existing.isAdmin DB'den gelmiş doğru değeri tutar.
  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final existing = await _db.getUserByEmail(email);
      if (existing == null || existing.password != password) {
        _errorMessage = 'Email veya şifre hatalı';
        _status       = AuthStatus.error;
      } else {
        _user   = existing;
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      _errorMessage = 'Giriş sırasında hata: $e';
      _status       = AuthStatus.error;
    }

    notifyListeners();
  }

  /// Çıkış yap: kullanıcıyı temizle
  void logout() {
    _user   = null;
    _status = AuthStatus.initial;
    notifyListeners();
  }
}
