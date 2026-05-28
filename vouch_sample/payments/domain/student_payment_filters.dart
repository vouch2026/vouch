import 'student_payment_item.dart';

class StudentPaymentFilters {
  StudentPaymentFilters._();

  static List<StudentPaymentItem> filterByTab({
    required List<StudentPaymentItem> items,
    required String tab,
  }) {
    if (tab == StudentPaymentTab.pending) {
      return items
          .where((item) => item.status == StudentPaymentStatus.pending)
          .toList();
    }

    if (tab == StudentPaymentTab.toPay) {
      return items
          .where((item) => item.status == StudentPaymentStatus.toPay)
          .toList();
    }

    if (tab == StudentPaymentTab.paid) {
      return items
          .where((item) => item.status == StudentPaymentStatus.paid)
          .toList();
    }

    if (tab == StudentPaymentTab.rejected) {
      return items
          .where((item) => item.status == StudentPaymentStatus.rejected)
          .toList();
    }

    if (tab == StudentPaymentTab.obligatory) {
      return items
          .where((item) =>
              item.obligation == 'OBLIGATORY' &&
              item.status != StudentPaymentStatus.paid)
          .toList();
    }

    if (tab == StudentPaymentTab.nonObligatory) {
      return items
          .where((item) =>
              item.obligation == 'NON-OBLIGATORY' &&
              item.status != StudentPaymentStatus.paid)
          .toList();
    }

    // Default: 'All' tab - only show unpaid items
    return items
        .where((item) => item.status != StudentPaymentStatus.paid)
        .toList();
  }

  static List<StudentPaymentItem> filterCombined({
    required List<StudentPaymentItem> items,
    required String obligation,
    required String status,
  }) {
    return items.where((item) {
      // 1. Obligation Filter
      bool matchesObligation = true;
      if (obligation == StudentPaymentTab.obligatory) {
        matchesObligation = item.obligation == 'OBLIGATORY';
      } else if (obligation == StudentPaymentTab.nonObligatory) {
        matchesObligation = item.obligation == 'NON-OBLIGATORY';
      }

      // 2. Status Filter
      bool matchesStatus = true;
      if (status == StudentPaymentTab.pending) {
        matchesStatus = item.status == StudentPaymentStatus.pending;
      } else if (status == StudentPaymentTab.toPay) {
        matchesStatus = item.status == StudentPaymentStatus.toPay;
      } else if (status == StudentPaymentTab.paid) {
        matchesStatus = item.status == StudentPaymentStatus.paid;
      } else if (status == StudentPaymentTab.rejected) {
        matchesStatus = item.status == StudentPaymentStatus.rejected;
      } else if (status == StudentPaymentTab.all) {
        // If status is "All", we follow the "Unpaid" logic by default
        // unless explicitly changed by user's status selection
        matchesStatus = item.status != StudentPaymentStatus.paid;
      }

      return matchesObligation && matchesStatus;
    }).toList();
  }

  static bool canSubmitProof(StudentPaymentItem item) {
    return item.status == StudentPaymentStatus.toPay ||
        item.status == StudentPaymentStatus.rejected;
  }
}
