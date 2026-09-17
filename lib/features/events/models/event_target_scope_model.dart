class EventTargetScopeModel {
  final String? id;
  final String eventId;
  final String targetType; // 'Institutional', 'Faculty', 'Program'
  final String targetId;   // campus_id, faculty_id, program_id
  final bool isMandatory;
  final DateTime? createdAt;

  const EventTargetScopeModel({
    this.id,
    required this.eventId,
    required this.targetType,
    required this.targetId,
    this.isMandatory = true,
    this.createdAt,
  });

  factory EventTargetScopeModel.fromJson(Map<String, dynamic> json) {
    return EventTargetScopeModel(
      id: json['id'] as String?,
      eventId: json['event_id'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'event_id': eventId,
      'target_type': targetType,
      'target_id': targetId,
      'is_mandatory': isMandatory,
    };
  }
}
