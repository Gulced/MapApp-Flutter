// lib/models/auth_models.dart

class User {
  final String id;
  final String email;
  final String token;
  final bool isAdmin;        // ← Yeni alan

  User({
    required this.id,
    required this.email,
    required this.token,
    this.isAdmin = false,     // default: false
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:      json['id']    as String,
    email:   json['email'] as String,
    token:   json['token'] as String,
    isAdmin: json['isAdmin'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id':      id,
    'email':   email,
    'token':   token,
    'isAdmin': isAdmin,
  };
}

class AuthResponse {
  final bool success;
  final String message;
  final User? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json['success'] as bool,
    message: json['message'] as String,
    user: json['data'] != null
        ? User.fromJson(json['data'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    if (user != null) 'data': user!.toJson(),
  };
}
