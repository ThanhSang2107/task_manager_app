class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
  });

  UserModel copyWith({
    String? username,
    String? email,
    String? password,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}