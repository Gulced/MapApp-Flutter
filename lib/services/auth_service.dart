// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/auth_models.dart';

class AuthService {
  /// Kullanıcı girişi yapar. Başarılıysa AuthResponse içinde
  /// gelen User objesinde isAdmin bilgisi de olacaktır.
  Future<AuthResponse> login(String email, String password) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(res.body);
      return AuthResponse.fromJson(body);
    } else {
      throw Exception('Login failed: ${res.statusCode} ${res.reasonPhrase}');
    }
  }

  /// Yeni kullanıcı kaydı yapar. Başarılıysa AuthResponse döner.
  Future<AuthResponse> register(String email, String password) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(res.body);
      return AuthResponse.fromJson(body);
    } else {
      throw Exception('Register failed: ${res.statusCode} ${res.reasonPhrase}');
    }
  }
}
