enum UserRole {
  superAdmin('super_admin'),
  comselecChairman('comselec_chairman'),
  comselecCommissioner('comselec_commissioner'),
  adviser('adviser'),
  governor('governor'),
  secretary('secretary'),
  treasurer('treasurer'),
  pio('pio'),
  staff('staff'),
  student('student');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}
