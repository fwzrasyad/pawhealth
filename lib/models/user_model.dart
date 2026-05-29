enum UserRole { owner, vet }

class User {
  final String userId;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String phoneNumber;
  final String? profileImageUrl;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phoneNumber,
    this.profileImageUrl,
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
      phoneNumber: json['phone_number'] as String? ?? '',
      profileImageUrl: json['profile_image_url'] as String?,
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
      'profile_image_url': profileImageUrl,
    };
  }

  User copyWith({
    String? userId,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
