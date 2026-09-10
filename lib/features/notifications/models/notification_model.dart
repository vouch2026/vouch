import 'dart:convert';

class NotificationModel {
  final String id;
  final String? senderId;
  final String title;
  final String content;
  final String notificationType; // 'personal', 'program', 'faculty', 'campus', 'global'
  
  final String? targetUserId;
  final String? targetProgramId;
  final String? targetFacultyId;
  final String? targetCampusId;

  final String category; // 'announcement', 'event', 'sanction', 'election', 'finance', 'general'
  final String? actionRoute;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    this.senderId,
    required this.title,
    required this.content,
    required this.notificationType,
    this.targetUserId,
    this.targetProgramId,
    this.targetFacultyId,
    this.targetCampusId,
    required this.category,
    this.actionRoute,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? senderId,
    String? title,
    String? content,
    String? notificationType,
    String? targetUserId,
    String? targetProgramId,
    String? targetFacultyId,
    String? targetCampusId,
    String? category,
    String? actionRoute,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      title: title ?? this.title,
      content: content ?? this.content,
      notificationType: notificationType ?? this.notificationType,
      targetUserId: targetUserId ?? this.targetUserId,
      targetProgramId: targetProgramId ?? this.targetProgramId,
      targetFacultyId: targetFacultyId ?? this.targetFacultyId,
      targetCampusId: targetCampusId ?? this.targetCampusId,
      category: category ?? this.category,
      actionRoute: actionRoute ?? this.actionRoute,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static Map<String, dynamic> _parseMetadata(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      try {
        return Map<String, dynamic>.from(raw);
      } catch (_) {
        return {};
      }
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return {};
  }

  static DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    try {
      return DateTime.parse(dateVal.toString()).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Determine isRead by checking if user_notification_reads relation exists
    final reads = json['user_notification_reads'] as List?;
    final hasReadReceipt = reads != null && reads.isNotEmpty;
    final isReadVal = json['is_read'] is bool ? json['is_read'] as bool : hasReadReceipt;

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString(),
      title: json['title']?.toString() ?? 'Notification',
      content: json['content']?.toString() ?? '',
      notificationType: json['notification_type']?.toString() ?? 'global',
      targetUserId: json['target_user_id']?.toString(),
      targetProgramId: json['target_program_id']?.toString(),
      targetFacultyId: json['target_faculty_id']?.toString(),
      targetCampusId: json['target_campus_id']?.toString(),
      category: json['category']?.toString() ?? 'general',
      actionRoute: json['action_route']?.toString(),
      metadata: _parseMetadata(json['metadata']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      isRead: isReadVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'title': title,
      'content': content,
      'notification_type': notificationType,
      'target_user_id': targetUserId,
      'target_program_id': targetProgramId,
      'target_faculty_id': targetFacultyId,
      'target_campus_id': targetCampusId,
      'category': category,
      'action_route': actionRoute,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
