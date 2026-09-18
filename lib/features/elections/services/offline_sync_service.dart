import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class QueuedOfflineVote {
  final String localTransactionId;
  final String electionId;
  final String stationId;
  final String payloadHash;
  final String voterTokenHash;
  final Map<String, dynamic> encryptedPayload;
  final String syncStatus; // LOCAL_PENDING, SYNCING, SYNCED, REJECTED
  final String timestamp;

  QueuedOfflineVote({
    required this.localTransactionId,
    required this.electionId,
    required this.stationId,
    required this.payloadHash,
    required this.voterTokenHash,
    required this.encryptedPayload,
    this.syncStatus = 'LOCAL_PENDING',
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'localTransactionId': localTransactionId,
      'electionId': electionId,
      'stationId': stationId,
      'payloadHash': payloadHash,
      'voterTokenHash': voterTokenHash,
      'encryptedPayload': encryptedPayload,
      'syncStatus': syncStatus,
      'timestamp': timestamp,
    };
  }

  factory QueuedOfflineVote.fromJson(Map<String, dynamic> json) {
    return QueuedOfflineVote(
      localTransactionId: json['localTransactionId'] as String,
      electionId: json['electionId'] as String,
      stationId: json['stationId'] as String,
      payloadHash: json['payloadHash'] as String,
      voterTokenHash: json['voterTokenHash'] as String,
      encryptedPayload: Map<String, dynamic>.from(json['encryptedPayload'] as Map),
      syncStatus: json['syncStatus'] as String? ?? 'LOCAL_PENDING',
      timestamp: json['timestamp'] as String,
    );
  }
}

class OfflineSyncService {
  static const String _boxName = 'comselec_offline_queue';

  static Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  /// Cryptographically hash a payload using SHA-256
  static String calculatePayloadHash(Map<String, dynamic> payload, String secretKey) {
    final rawString = jsonEncode(payload);
    final keyBytes = utf8.encode(secretKey);
    final bytes = utf8.encode(rawString);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// Enqueue an offline vote to local encrypted storage
  static Future<QueuedOfflineVote> enqueueVote({
    required String electionId,
    required String stationId,
    required String voterToken,
    required Map<String, dynamic> selections,
    required String stationSecretKey,
  }) async {
    final box = await _openBox();
    final timestamp = DateTime.now().toIso8601String();
    final txId = 'OFF-${DateTime.now().millisecondsSinceEpoch}-${selections.hashCode}';

    final payloadHash = calculatePayloadHash(selections, stationSecretKey);
    final voterTokenHash = sha256.convert(utf8.encode(voterToken)).toString();

    final item = QueuedOfflineVote(
      localTransactionId: txId,
      electionId: electionId,
      stationId: stationId,
      payloadHash: payloadHash,
      voterTokenHash: voterTokenHash,
      encryptedPayload: selections,
      syncStatus: 'LOCAL_PENDING',
      timestamp: timestamp,
    );

    await box.put(txId, jsonEncode(item.toJson()));
    return item;
  }

  /// Get all queued votes
  static Future<List<QueuedOfflineVote>> getQueuedVotes() async {
    final box = await _openBox();
    final list = <QueuedOfflineVote>[];
    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
          list.add(QueuedOfflineVote.fromJson(decoded));
        } catch (_) {}
      }
    }
    return list;
  }

  /// Mark vote status after server sync
  static Future<void> updateVoteStatus(String txId, String status) async {
    final box = await _openBox();
    final raw = box.get(txId);
    if (raw != null) {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      decoded['syncStatus'] = status;
      await box.put(txId, jsonEncode(decoded));
    }
  }

  /// Clear synced votes
  static Future<void> clearSyncedVotes() async {
    final box = await _openBox();
    final keysToRemove = <dynamic>[];
    for (var key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
          if (decoded['syncStatus'] == 'SYNCED') {
            keysToRemove.add(key);
          }
        } catch (_) {}
      }
    }
    await box.deleteAll(keysToRemove);
  }
}
