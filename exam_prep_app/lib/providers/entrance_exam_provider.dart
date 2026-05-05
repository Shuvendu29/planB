import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/entrance_exam_model.dart';
import '../models/question_review_model.dart';
import '../models/exam_type_model.dart';
import '../models/exam_category_model.dart';

class EntranceExamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<EntranceExamModel> _entranceExams = [];
  List<ExamTypeModel> _examTypes = [];
  List<ExamCategoryModel> _examCategories = [];
  bool _isLoading = false;
  String? _error;

  List<EntranceExamModel> get entranceExams => _entranceExams;
  List<ExamTypeModel> get examTypes => _examTypes;
  List<ExamCategoryModel> get examCategories => _examCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load approved entrance exams
  Future<void> loadEntranceExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('entrance_exams')
          .where('status', isEqualTo: 'approved')
          .get();

      _entranceExams = snapshot.docs
          .map((doc) => EntranceExamModel.fromMap(doc.data(), doc.id))
          .toList();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load exam types
  Future<void> loadExamTypes() async {
    try {
      final snapshot = await _firestore
          .collection('exam_types')
          .where('isActive', isEqualTo: true)
          .get();

      _examTypes = snapshot.docs
          .map((doc) => ExamTypeModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Load exam categories
  Future<void> loadExamCategories() async {
    try {
      final snapshot = await _firestore
          .collection('exam_categories')
          .where('isActive', isEqualTo: true)
          .get();

      _examCategories = snapshot.docs
          .map((doc) => ExamCategoryModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Get categories for a specific exam type
  List<ExamCategoryModel> getCategoriesForExamType(String examTypeId) {
    return _examCategories.where((category) => category.examTypeId == examTypeId).toList();
  }

  // Submit entrance exam for SME
  Future<void> submitEntranceExam(EntranceExamModel exam, String smeId) async {
    try {
      final examData = exam.toMap();
      examData['uploadedBy'] = smeId;
      examData['uploadedAt'] = Timestamp.now();
      examData['status'] = 'pending';

      await _firestore.collection('entrance_exams').add(examData);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  // Submit question review
  Future<void> submitQuestionReview(QuestionReviewModel review) async {
    try {
      await _firestore.collection('question_reviews').add(review.toMap());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  // Get reviews for an exam
  Future<List<QuestionReviewModel>> getExamReviews(String examId) async {
    try {
      final snapshot = await _firestore
          .collection('question_reviews')
          .where('examId', isEqualTo: examId)
          .get();

      return snapshot.docs
          .map((doc) => QuestionReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  // Admin: Add exam type
  Future<void> addExamType(ExamTypeModel examType, String adminId) async {
    try {
      final typeData = examType.toMap();
      typeData['createdBy'] = adminId;
      typeData['createdAt'] = Timestamp.now();

      await _firestore.collection('exam_types').add(typeData);
      await loadExamTypes(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  // Admin: Add exam category
  Future<void> addExamCategory(ExamCategoryModel category, String adminId) async {
    try {
      final categoryData = category.toMap();
      categoryData['createdBy'] = adminId;
      categoryData['createdAt'] = Timestamp.now();

      await _firestore.collection('exam_categories').add(categoryData);
      await loadExamCategories(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  // Admin: Approve entrance exam
  Future<void> approveEntranceExam(String examId, String adminId) async {
    try {
      await _firestore.collection('entrance_exams').doc(examId).update({
        'status': 'approved',
        'approvedAt': Timestamp.now(),
        'approvedBy': adminId,
      });
      await loadEntranceExams(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  // Admin: Reject entrance exam
  Future<void> rejectEntranceExam(String examId) async {
    try {
      await _firestore.collection('entrance_exams').doc(examId).update({
        'status': 'rejected',
      });
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      throw e;
    }
  }

  // Get pending entrance exams for admin
  Future<List<EntranceExamModel>> getPendingEntranceExams() async {
    try {
      final snapshot = await _firestore
          .collection('entrance_exams')
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => EntranceExamModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }
}