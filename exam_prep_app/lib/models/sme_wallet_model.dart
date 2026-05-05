import 'package:cloud_firestore/cloud_firestore.dart';

class SMEWalletModel {
  final String id; // SME uid
  final double totalEarnings; // Total amount earned
  final double availableBalance; // Current wallet balance
  final double totalWithdrawn; // Total amount withdrawn
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;

  SMEWalletModel({
    required this.id,
    this.totalEarnings = 0.0,
    this.availableBalance = 0.0,
    this.totalWithdrawn = 0.0,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  factory SMEWalletModel.fromMap(Map<String, dynamic> data, String id) {
    return SMEWalletModel(
      id: id,
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
      availableBalance: (data['availableBalance'] ?? 0.0).toDouble(),
      totalWithdrawn: (data['totalWithdrawn'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: data['lastUpdatedAt'] != null ? (data['lastUpdatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalEarnings': totalEarnings,
      'availableBalance': availableBalance,
      'totalWithdrawn': totalWithdrawn,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': lastUpdatedAt != null ? Timestamp.fromDate(lastUpdatedAt!) : null,
    };
  }
}
