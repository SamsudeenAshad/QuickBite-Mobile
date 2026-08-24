class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'customer',
  });

  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      role: map['role'] as String? ?? 'customer',
    );
  }
}
