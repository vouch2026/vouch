import '../domain/student_payment_item.dart';

class StudentPaymentSeedData {
  StudentPaymentSeedData._();

  static const StudentPaymentSummary summary = StudentPaymentSummary(
    studentId: '2023-0222',
    academicYear: 'A.Y. 2025-2026',
    totalPayable: 99999.00,
  );

  static const List<String> tabs = [
    StudentPaymentTab.all,
    StudentPaymentTab.toPay,
    StudentPaymentTab.pending,
    StudentPaymentTab.paid,
    StudentPaymentTab.rejected,
  ];

  static final List<StudentPaymentItem> paymentItems = [
    
  ];
}
