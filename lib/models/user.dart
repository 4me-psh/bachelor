class User {
  final int? id;
  final String? name;
  final String email;
  final String? password;

  User({this.id, this.name, required this.email,this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toLoginJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'username': name,
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toEditJson() {
    return {
      'username': name,
      'email': email,
      'password': password,
    };
  }
}
