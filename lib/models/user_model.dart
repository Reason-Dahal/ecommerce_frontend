class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return UserModel(
      id: user['_id']?.toString() ?? '',
      name: user['username']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }
}
