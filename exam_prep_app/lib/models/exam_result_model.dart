import 'package:cloud_firestore/cloud_firestore.dart';

class ExamResultModel {
  final String id;
  final String userId;
  final String userName;
  final String examId;
  final String examTitle;
  final int score;
  final int totalQuestions;
  final int timeTakenMinutes;
  final DateTime completedAt;
  final String examType; // 'entrance_exam', 'mock_test', etc.
  final String category;

  ExamResultModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.examId,
    required this.examTitle,
    required this.score,
    required this.totalQuestions,
    required this.timeTakenMinutes,
    required this.completedAt,
    required this.examType,
    required this.category,
  });

  factory ExamResultModel.fromMap(Map<String, dynamic> data, String id) {
    return ExamResultModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      examId: data['examId'] ?? '',
      examTitle: data['examTitle'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      timeTakenMinutes: data['timeTakenMinutes'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      examType: data['examType'] ?? '',
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'examId': examId,
      'examTitle': examTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeTakenMinutes': timeTakenMinutes,
      'completedAt': Timestamp.fromDate(completedAt),
      'examType': examType,
      'category': category,
    };
  }

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
}