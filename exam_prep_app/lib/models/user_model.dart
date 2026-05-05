class UserModel {
  final String uid;
  final String email;
  final String? name;
  final int points;
  final bool firstLogin;
  final bool firstTopup;
  final String role; // 'user', 'sme', 'admin'

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.points = 0,
    this.firstLogin = false,
    this.firstTopup = false,
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'],
      points: data['points'] ?? 0,
      firstLogin: data['firstLogin'] ?? false,
      firstTopup: data['firstTopup'] ?? false,
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'points': points,
      'firstLogin': firstLogin,
      'firstTopup': firstTopup,
      'role': role,
    };
  }
}