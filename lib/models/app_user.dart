class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  final int id;
  final String name;
  final String phone;
  final String email;

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
    );
  }
}
