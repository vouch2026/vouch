enum UserRole {
  superAdmin('super_admin'),
  comselecChairman('comselec_chairman'),
  comselecCoChairman('comselec_co_chairman'),
  comselecCommissioner('comselec_commissioner'),
  campusCommissioner('campus_commissioner'),
  facultyCommissioner('faculty_commissioner'),
  programCommissioner('program_commissioner'),
  electionObserver('election_observer'),
  adviser('adviser'),
  governor('governor'),
  viceGovernor('vice_governor'),
  president('president'),
  vicePresident('vice_president'),
  secretary('secretary'),
  treasurer('treasurer'),
  pio('pio'),
  staff('staff'),
  student('student'),
  voter('voter'),
  personnel('personnel');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}
