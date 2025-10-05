class User {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String? substationId;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.substationId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role.toString(),
        'substationId': substationId,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        role: UserRole.values.firstWhere(
          (e) => e.toString() == json['role'],
          orElse: () => UserRole.substation,
        ),
        substationId: json['substationId'],
      );
}

enum UserRole {
  admin,
  controlRoom,
  substation,
}