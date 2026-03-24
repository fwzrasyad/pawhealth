enum UserRole { owner, vet }

class User {
  final String userId;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String phoneNumber;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['role'] as String).toLowerCase(),
        orElse: () => UserRole.owner,
      ),
      phoneNumber: json['phone_number'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'phone_number': phoneNumber,
    };
  }
}
