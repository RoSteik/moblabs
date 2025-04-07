class User {
  final String name;
  final String email;
  final String password;

  User({required this.name, required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

  static User fromJson(Map<String, dynamic> json) => User(
    name: json['name'].toString(),
    email: json['email'].toString(),
    password: json['password'].toString(),
  );
}
