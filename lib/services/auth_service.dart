// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';


import '../models/auth_models.dart';


class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Login failed: ${res.statusCode}');
    }
  }

  Future<AuthResponse> register(String email, String password) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/register');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Register failed: ${res.statusCode}');
    }
  }
}
