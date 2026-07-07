class RoleMapper {
  RoleMapper._();

  static String mapDbRoleToAppFormat(String dbRole) {
    final role = dbRole.trim().toLowerCase();
    switch (role) {
      case 'super admin':
        return 'super_admin';
      case 'students':
      case 'student':
        return 'student';
      case 'comselec chair':
      case 'comselec chairman':
        return 'comselec_chairman';
      case 'comselec officer':
      case 'comselec commissioner':
        return 'comselec_commissioner';
      case 'faculty governor':
      case 'program governor':
      case 'governor':
        return 'governor';
      case 'vice governor':
        return 'vice_governor';
      case 'president':
        return 'president';
      case 'vice president':
        return 'vice_president';
      case 'faculty treasurer':
      case 'program treasurer':
      case 'treasurer':
        return 'treasurer';
      case 'faculty secretary':
      case 'program secretary':
      case 'secretary':
        return 'secretary';
      case 'faculty dean':
        return 'dean';
      case 'program head':
        return 'program_head';
      case 'adviser':
        return 'adviser';
      case 'voters':
      case 'voter':
        return 'voter';
      case 'personnel':
        return 'personnel';
      default:
        return role.replaceAll(' ', '_');
    }
  }
}
