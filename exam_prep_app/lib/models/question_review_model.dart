import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionReviewModel {
  final String id;
  final String userId;
  final String examId;
  final String questionId;
  final String difficulty; // 'easy', 'moderate', 'tough', 'hard'
  final String? comment;
  final DateTime reviewedAt;
  final bool adminReviewed;
  final String? adminFeedback;

  QuestionReviewModel({
    required this.id,
    required this.userId,
    required this.examId,
    required this.questionId,
    required this.difficulty,
    this.comment,
    required this.reviewedAt,
    this.adminReviewed = false,
    this.adminFeedback,
  });

  factory QuestionReviewModel.fromMap(Map<String, dynamic> data, String id) {
    return QuestionReviewModel(
      id: id,
      userId: data['userId'] ?? '',
      examId: data['examId'] ?? '',
      questionId: data['questionId'] ?? '',
      difficulty: data['difficulty'] ?? 'moderate',
      comment: data['comment'],
      reviewedAt: (data['reviewedAt'] as Timestamp).toDate(),
      adminReviewed: data['adminReviewed'] ?? false,
      adminFeedback: data['adminFeedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'examId': examId,
      'questionId': questionId,
      'difficulty': difficulty,
      'comment': comment,
      'reviewedAt': Timestamp.fromDate(reviewedAt),
      'adminReviewed': adminReviewed,
      'adminFeedback': adminFeedback,
    };
  }
}