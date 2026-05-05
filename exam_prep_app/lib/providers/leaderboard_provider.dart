import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/exam_result_model.dart';

class LeaderboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ExamResultModel> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  List<ExamResultModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get top N results
  Future<void> loadLeaderboard({int limit = 10, String? examType, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore.collection('exam_results').orderBy('score', descending: true);

      if (examType != null && examType.isNotEmpty) {
        query = query.where('examType', isEqualTo: examType);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.limit(limit).get();

      _leaderboard = snapshot.docs
          .map((doc) => ExamResultModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user's rank
  Future<int?> getUserRank(String userId, {String? examType, String? category}) async {
    try {
      Query query = _firestore.collection('exam_results').orderBy('score', descending: true);

      if (examType != null && examType.isNotEmpty) {
        query = query.where('examType', isEqualTo: examType);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        final result = ExamResultModel.fromMap(snapshot.docs[i].data() as Map<String, dynamic>, snapshot.docs[i].id);
        if (result.userId == userId) {
          return i + 1; // 1-based ranking
        }
      }

      return null; // User not found in results
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Get user's best score
  Future<ExamResultModel?> getUserBestScore(String userId, {String? examType, String? category}) async {
    try {
      Query query = _firestore.collection('exam_results')
          .where('userId', isEqualTo: userId)
          .orderBy('score', descending: true)
          .limit(1);

      if (examType != null && examType.isNotEmpty) {
        query = query.where('examType', isEqualTo: examType);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        return ExamResultModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
      }

      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Submit exam result
  Future<void> submitExamResult(ExamResultModel result) async {
    try {
      await _firestore.collection('exam_results').add(result.toMap());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  // Get highest score
  Future<ExamResultModel?> getHighestScore({String? examType, String? category}) async {
    try {
      Query query = _firestore.collection('exam_results').orderBy('score', descending: true).limit(1);

      if (examType != null && examType.isNotEmpty) {
        query = query.where('examType', isEqualTo: examType);
      }

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        return ExamResultModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
      }

      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
}