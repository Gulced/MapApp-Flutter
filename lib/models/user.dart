class User {
  final int? id;
  final String email;
  final String password;
  final bool isAdmin;
  User({this.id, required this.email, required this.password, this.isAdmin = false});
  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'password': password,
    'isAdmin': isAdmin?1:0,
  };
  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'], email: m['email'], password: m['password'],
    isAdmin: m['isAdmin']==1,
  );
}
