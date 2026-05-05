import 'package:cloud_firestore/cloud_firestore.dart';

class ExamTypeModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  ExamTypeModel({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  factory ExamTypeModel.fromMap(Map<String, dynamic> data, String id) {
    return ExamTypeModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}