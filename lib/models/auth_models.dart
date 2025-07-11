class User {
  final String id;
  final String email;
  final String token;

  User({required this.id, required this.email, required this.token});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    token: json['token'] as String,
  );
}

class AuthResponse {
  final bool success;
  final String message;
  final User? user;

  AuthResponse({required this.success, required this.message, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json['success'] as bool,
    message: json['message'] as String,
    user: json['data'] != null ? User.fromJson(json['data']) : null,
  );
}
