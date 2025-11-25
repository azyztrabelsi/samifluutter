class LocalUser {
  final int id;
  final String name;
  final String email;

  LocalUser({required this.id, required this.name, required this.email});

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}