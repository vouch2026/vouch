import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_profile_model.dart';
import '../models/instructor_profile_model.dart';
import '../../auth/models/user_model.dart';

final studentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    {
      'user': const UserModel(id: 's1', email: 'juan.delacruz@dorsu.edu.ph', fullName: 'Juan Dela Cruz', role: 'student'),
      'profile': const StudentProfileModel(userId: 's1', studentNumber: '2022-00123', campusName: 'Main Campus', facultyName: 'FCET', programName: 'BSIT', yearLevel: 3, status: 'active'),
    },
    {
      'user': const UserModel(id: 's2', email: 'maria.clara@dorsu.edu.ph', fullName: 'Maria Clara', role: 'student'),
      'profile': const StudentProfileModel(userId: 's2', studentNumber: '2022-00456', campusName: 'Main Campus', facultyName: 'FTE', programName: 'BEED', yearLevel: 2, status: 'pending'),
    },
  ];
});

final instructorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    {
      'user': const UserModel(id: 'i1', email: 'dr.doe@dorsu.edu.ph', fullName: 'Dr. John Doe', role: 'adviser'),
      'profile': const InstructorProfileModel(userId: 'i1', instructorId: 'INS-001', campusName: 'Main Campus', facultyName: 'FCET', position: 'dean', status: 'active'),
    },
    {
      'user': const UserModel(id: 'i2', email: 'prof.smith@dorsu.edu.ph', fullName: 'Prof. Jane Smith', role: 'adviser'),
      'profile': const InstructorProfileModel(userId: 'i2', instructorId: 'INS-002', campusName: 'Banaybanay', facultyName: 'FCET', position: 'program_head', assignedProgramName: 'BSIT', status: 'active'),
    },
  ];
});
