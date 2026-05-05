import 'package:cloud_firestore/cloud_firestore.dart';

class RewardConfigModel {
  final String id;
  final double approvalReward; // Amount given when content is approved
  final Map<String, double> contentTypeRewards; // Reward per content type
  // e.g., {'mock_test': 500, 'study_notes': 100, 'current_affairs': 50}
  final double usageRewardPerUser; // Amount per user completion
  final int usageThresholdForReward; // e.g., reward at 100+ users
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? updatedBy; // Admin uid who made the change

  RewardConfigModel({
    required this.id,
    this.approvalReward = 100.0,
    this.contentTypeRewards = const {
      'mock_test': 500.0,
      'entrance_exam': 1000.0,
      'study_notes': 100.0,
      'current_affairs': 50.0,
    },
    this.usageRewardPerUser = 10.0,
    this.usageThresholdForReward = 100,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.updatedBy,
  });

  factory RewardConfigModel.fromMap(Map<String, dynamic> data, String id) {
    return RewardConfigModel(
      id: id,
      approvalReward: (data['approvalReward'] ?? 100.0).toDouble(),
      contentTypeRewards: Map<String, double>.from(
        (data['contentTypeRewards'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ??
        {
          'mock_test': 500.0,
          'entrance_exam': 1000.0,
          'study_notes': 100.0,
          'current_affairs': 50.0,
        },
      ),
      usageRewardPerUser: (data['usageRewardPerUser'] ?? 10.0).toDouble(),
      usageThresholdForReward: data['usageThresholdForReward'] ?? 100,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'approvalReward': approvalReward,
      'contentTypeRewards': contentTypeRewards,
      'usageRewardPerUser': usageRewardPerUser,
      'usageThresholdForReward': usageThresholdForReward,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
    };
  }
}
