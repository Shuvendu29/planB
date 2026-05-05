import 'package:cloud_firestore/cloud_firestore.dart';

class RewardTransactionModel {
  final String id;
  final String smeName; // SME uid
  final String contentId; // Content for which reward is given
  final String rewardType; // 'approval', 'content_creation', 'usage_threshold'
  final double amount;
  final String description; // e.g., "Reward for mock test approval"
  final Map<String, dynamic> metadata; // Additional data like content title, user count, etc.
  final String status; // 'pending', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? processedAt;

  RewardTransactionModel({
    required this.id,
    required this.smeName,
    required this.contentId,
    required this.rewardType,
    required this.amount,
    required this.description,
    this.metadata = const {},
    this.status = 'completed',
    required this.createdAt,
    this.processedAt,
  });

  factory RewardTransactionModel.fromMap(Map<String, dynamic> data, String id) {
    return RewardTransactionModel(
      id: id,
      smeName: data['smeUid'] ?? '',
      contentId: data['contentId'] ?? '',
      rewardType: data['rewardType'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      metadata: data['metadata'] ?? {},
      status: data['status'] ?? 'completed',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      processedAt: data['processedAt'] != null ? (data['processedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'smeUid': smeName,
      'contentId': contentId,
      'rewardType': rewardType,
      'amount': amount,
      'description': description,
      'metadata': metadata,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
    };
  }
}
