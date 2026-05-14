enum UserStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  suspended('suspended'),
  archived('archived');

  final String value;
  const UserStatus(this.value);

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.pending,
    );
  }
}
