class OfflineVotingStationModel {
  final String id;
  final String electionId;
  final String deviceIdentifier;
  final String stationName;
  final String location;
  final String registeredBy;
  final String publicKey;
  final String status; // REGISTERED, ACTIVE, LOCKED, DECOMMISSIONED
  final DateTime registeredAt;
  final DateTime? lastSyncAt;
  final int localPendingCount;
  final int syncedCount;

  const OfflineVotingStationModel({
    required this.id,
    required this.electionId,
    required this.deviceIdentifier,
    required this.stationName,
    required this.location,
    required this.registeredBy,
    required this.publicKey,
    this.status = 'REGISTERED',
    required this.registeredAt,
    this.lastSyncAt,
    this.localPendingCount = 0,
    this.syncedCount = 0,
  });

  factory OfflineVotingStationModel.fromJson(Map<String, dynamic> json) {
    return OfflineVotingStationModel(
      id: json['id'] as String,
      electionId: json['election_id'] as String,
      deviceIdentifier: json['device_identifier'] as String,
      stationName: json['station_name'] as String,
      location: json['location'] as String,
      registeredBy: json['registered_by'] as String,
      publicKey: json['public_key'] as String? ?? '',
      status: json['status'] as String? ?? 'REGISTERED',
      registeredAt: json['registered_at'] != null
          ? DateTime.parse(json['registered_at'] as String)
          : DateTime.now(),
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      localPendingCount: json['local_pending_count'] as int? ?? 0,
      syncedCount: json['synced_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'device_identifier': deviceIdentifier,
      'station_name': stationName,
      'location': location,
      'registered_by': registeredBy,
      'public_key': publicKey,
      'status': status,
      'registered_at': registeredAt.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'local_pending_count': localPendingCount,
      'synced_count': syncedCount,
    };
  }
}
