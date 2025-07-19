// lib/models/user.dart

class User {
  final int    id;
  final String email;
  final String password;
  final bool   isAdmin;

  User({
    required this.id,
    required this.email,
    required this.password,
    this.isAdmin = false,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
    id:       map['id']       as int,
    email:    map['email']    as String,
    password: map['password'] as String,
    isAdmin:  (map['isAdmin'] as int) == 1, // SQLite INT(0/1)
  );

  Map<String, dynamic> toMap() => {
    'id':       id,
    'email':    email,
    'password': password,
    'isAdmin':  isAdmin ? 1 : 0,
  };

  // Kolaylık için kopyalama metodu
  User copyWith({bool? isAdmin}) {
    return User(
      id:       id,
      email:    email,
      password: password,
      isAdmin:  isAdmin ?? this.isAdmin,
    );
  }
}
