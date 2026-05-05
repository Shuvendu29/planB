import 'package:cloud_firestore/cloud_firestore.dart';

class ExamCategoryModel {
  final String id;
  final String name;
  final String description;
  final String examTypeId;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  ExamCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.examTypeId,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  factory ExamCategoryModel.fromMap(Map<String, dynamic> data, String id) {
    return ExamCategoryModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      examTypeId: data['examTypeId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'examTypeId': examTypeId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}