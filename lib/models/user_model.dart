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

  /// Parses the login/signup API response shape: { "user": {...}, "token": "..." }
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

  /// Used for caching the user locally (SharedPreferences). Flat shape —
  /// does NOT mirror the API's nested { user: {...} } structure.
  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': name,
    'email': email,
    'role': role,
    'token': token,
  };

  /// Reads back the flat shape produced by [toJson].
  factory UserModel.fromCache(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      name: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      token: json['token']?.toString(),
    );
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
}
