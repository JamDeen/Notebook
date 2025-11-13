class AppUser {
  int? id;
  String username;
  String email;
  String password; // Débutant: stockage simple (en prod: hachage)

  AppUser({
    this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'password': password,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as int?,
        username: map['username'] as String,
        email: map['email'] as String,
        password: map['password'] as String,
      );
}
