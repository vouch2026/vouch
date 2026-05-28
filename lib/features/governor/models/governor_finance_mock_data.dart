class GovernorFinanceMockData {
  GovernorFinanceMockData._();

  static final List<Map<String, dynamic>> receivers = [
    {
      'id': 'rec_1',
      'name': 'Juan Dela Cruz',
      'position': 'Treasurer - ACES',
      'gcashNumber': '09123456789',
      'provider': 'GCash',
    },
    {
      'id': 'rec_2',
      'name': 'Maria Santos',
      'position': 'Secretary - ACES',
      'gcashNumber': '09876543210',
      'provider': 'Maya',
    },
  ];

  static final List<Map<String, dynamic>> createdFees = [
    {
      'id': 1,
      'title': 'Annual Membership Fee',
      'amount': 200.00,
      'isMandatory': true,
      'description': 'Due Date: October 30, 2026\n\nPlease pay to the official ACES treasurer.',
      'receiverName': 'Juan Dela Cruz',
      'receiverGcash': '09123456789',
    },
    {
      'id': 2,
      'title': 'Panaghigalaay 2025 T-Shirt',
      'amount': 350.00,
      'isMandatory': false,
      'description': 'Due Date: November 15, 2026\n\nOptional for all ACES members.',
      'receiverName': 'Juan Dela Cruz',
      'receiverGcash': '09123456789',
    },
  ];

  static final List<Map<String, dynamic>> submissions = [
    {
      'id': '101',
      'studentName': 'Emily Davis',
      'studentProgram': 'BSIT - 3rd Year',
      'feeTitle': 'Annual Membership Fee',
      'amount': '200.00',
      'paymentMethod': 'GCash',
      'timeAgo': '10m ago',
      'status': 'Pending',
      'proofFile': 'screenshot_20261025.jpg',
      'receiptUrl': 'https://via.placeholder.com/400x800?text=Receipt+Sample',
    },
    {
      'id': '102',
      'studentName': 'Robert Brown',
      'studentProgram': 'BSCS - 2nd Year',
      'feeTitle': 'Annual Membership Fee',
      'amount': '200.00',
      'paymentMethod': 'Maya',
      'timeAgo': '1h ago',
      'status': 'Approved',
      'proofFile': 'maya_payment_ref.png',
      'receiptUrl': 'https://via.placeholder.com/400x800?text=Receipt+Sample',
    },
    {
      'id': '103',
      'studentName': 'James Miller',
      'studentProgram': 'BSBA - 4th Year',
      'feeTitle': 'Panaghigalaay 2025 T-Shirt',
      'amount': '350.00',
      'paymentMethod': 'GCash',
      'timeAgo': '3h ago',
      'status': 'Rejected',
      'rejectionNote': 'Incorrect amount paid.',
      'proofFile': 'receipt_v1.jpg',
      'receiptUrl': 'https://via.placeholder.com/400x800?text=Receipt+Sample',
    },
  ];
}
