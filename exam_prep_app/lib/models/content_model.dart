import 'package:cloud_firestore/cloud_firestore.dart';

class ContentModel {
  final String id;
  final String type; // 'exam', 'mock_test', 'current_affairs', 'study_notes'
  final String title;
  final String description;
  final List<String> fileUrls; // From Firebase Storage
  final String uploadedBy; // SME uid
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime uploadedAt;
  final DateTime? approvedAt;
  final String? approvedBy; // Admin uid who approved
  
  // Reward tracking fields
  final bool rewardGiven; // Whether reward has been disbursed for approval
  final double? approvalRewardAmount; // Amount given for approval
  final int userCompletionCount; // Number of users who completed/accessed this
  final bool usageRewardGiven; // Whether usage threshold reward has been given
  final double? usageRewardAmount; // Amount given for usage threshold

  ContentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.fileUrls,
    required this.uploadedBy,
    this.status = 'pending',
    required this.uploadedAt,
    this.approvedAt,
    this.approvedBy,
    this.rewardGiven = false,
    this.approvalRewardAmount,
    this.userCompletionCount = 0,
    this.usageRewardGiven = false,
    this.usageRewardAmount,
  });

  factory ContentModel.fromMap(Map<String, dynamic> data, String id) {
    return ContentModel(
      id: id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      uploadedBy: data['uploadedBy'] ?? '',
      status: data['status'] ?? 'pending',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null ? (data['approvedAt'] as Timestamp).toDate() : null,
      approvedBy: data['approvedBy'],
      rewardGiven: data['rewardGiven'] ?? false,
      approvalRewardAmount: data['approvalRewardAmount']?.toDouble(),
      userCompletionCount: data['userCompletionCount'] ?? 0,
      usageRewardGiven: data['usageRewardGiven'] ?? false,
      usageRewardAmount: data['usageRewardAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'fileUrls': fileUrls,
      'uploadedBy': uploadedBy,
      'status': status,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
      'rewardGiven': rewardGiven,
      'approvalRewardAmount': approvalRewardAmount,
      'userCompletionCount': userCompletionCount,
      'usageRewardGiven': usageRewardGiven,
      'usageRewardAmount': usageRewardAmount,
    };
  }
}