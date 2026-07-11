class UserEntity {
  final String id;
  final String fullName;
  final String username;
  final String? phone;
  final String role;
  final bool hasPinSetup;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.username,
    this.phone,
    required this.role,
    this.hasPinSetup = false,
  });
}
