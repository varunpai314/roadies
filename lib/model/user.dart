class User {
  final int? id;
  final String username;
  final String password;
  final String phoneNumber;
  final String bio;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.phoneNumber,
    required this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
      'bio': bio,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      phoneNumber: json['phoneNumber'],
      bio: json['bio'],
    );
  }
}
