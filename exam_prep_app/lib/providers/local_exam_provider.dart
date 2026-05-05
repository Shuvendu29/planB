import 'package:flutter/material.dart';
import '../data/local_storage.dart';

/// Local entrance exam provider for testing without Firebase
class LocalEntranceExamProvider with ChangeNotifier {
  final LocalStorage _storage = localStorage;
  
  List<Map<String, dynamic>> _exams = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all approved exams
  Future<void> loadExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _exams = _storage.getExams(status: 'approved');
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get exam by ID
  Map<String, dynamic>? getExam(String id) {
    return _storage.getExam(id);
  }

  /// Get exam count
  int get examCount => _exams.length;
}

/// Local exam taking result
class ExamResult {
  final String examId;
  final String examTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTakenMinutes;
  final DateTime completedAt;
  final Map<String, int> answers;

  ExamResult({
    required this.examId,
    required this.examTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenMinutes,
    required this.completedAt,
    required this.answers,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
  bool get passed => percentage >= 35;
}