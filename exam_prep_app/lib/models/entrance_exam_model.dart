import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String type; // 'multiple_choice', 'descriptive'
  final int marks;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.type = 'multiple_choice',
    this.marks = 1,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> data, String id) {
    return QuestionModel(
      id: id,
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      explanation: data['explanation'] ?? '',
      type: data['type'] ?? 'multiple_choice',
      marks: data['marks'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'type': type,
      'marks': marks,
    };
  }
}

class EntranceExamModel {
  final String id;
  final String title;
  final String description;
  final String examTypeId;
  final String categoryId;
  final bool negativeMarking;
  final double marksPerQuestion;
  final int timeInMinutes;
  final List<QuestionModel> questions;
  final String uploadedBy;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime uploadedAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  EntranceExamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.examTypeId,
    required this.categoryId,
    required this.negativeMarking,
    required this.marksPerQuestion,
    required this.timeInMinutes,
    required this.questions,
    required this.uploadedBy,
    this.status = 'pending',
    required this.uploadedAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory EntranceExamModel.fromMap(Map<String, dynamic> data, String id) {
    return EntranceExamModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      examTypeId: data['examTypeId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      negativeMarking: data['negativeMarking'] ?? false,
      marksPerQuestion: (data['marksPerQuestion'] ?? 1.0).toDouble(),
      timeInMinutes: data['timeInMinutes'] ?? 60,
      questions: (data['questions'] as List<dynamic>?)
          ?.map((q) => QuestionModel.fromMap(q as Map<String, dynamic>, ''))
          .toList() ?? [],
      uploadedBy: data['uploadedBy'] ?? '',
      status: data['status'] ?? 'pending',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null ? (data['approvedAt'] as Timestamp).toDate() : null,
      approvedBy: data['approvedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'examTypeId': examTypeId,
      'categoryId': categoryId,
      'negativeMarking': negativeMarking,
      'marksPerQuestion': marksPerQuestion,
      'timeInMinutes': timeInMinutes,
      'questions': questions.map((q) => q.toMap()).toList(),
      'uploadedBy': uploadedBy,
      'status': status,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
    };
  }

  int get totalQuestions => questions.length;
  double get totalMarks => questions.length * marksPerQuestion;
}