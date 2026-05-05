import 'package:flutter/material.dart';
import '../data/local_storage.dart';

/// Local reward provider for SME testing without Firebase
class LocalRewardProvider with ChangeNotifier {
  final LocalStorage _storage = localStorage;
  
  Map<String, dynamic>? _smeWallet;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic>? _rewardConfig;
  bool _isLoading = false;

  Map<String, dynamic>? get smeWallet => _smeWallet;
  List<Map<String, dynamic>> get transactions => _transactions;
  Map<String, dynamic>? get rewardConfig => _rewardConfig;
  bool get isLoading => _isLoading;

  /// Load SME wallet
  Future<void> loadSMEWallet(String smeUid) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    
    _smeWallet = _storage.getSMEWallet(smeUid);
    _transactions = _storage.getRewardTransactions(smeUid);

    _isLoading = false;
    notifyListeners();
  }

  /// Load reward configuration
  Future<void> loadRewardConfig() async {
    _rewardConfig = {
      'approvalReward': 100.0,
      'contentTypeRewards': {
        'mock_test': 500.0,
        'entrance_exam': 1000.0,
        'study_notes': 100.0,
        'current_affairs': 50.0,
      },
      'usageRewardPerUser': 10.0,
      'usageThresholdForReward': 100,
      'isActive': true,
    };
    notifyListeners();
  }

  /// Give approval reward (called when admin approves content)
  Future<bool> giveApprovalReward({
    required String smeUid,
    required Map<String, dynamic> content,
  }) async {
    if (content['rewardGiven'] == true) return false;

    final amount = (_rewardConfig?['contentTypeRewards']?[content['type']] ?? 100).toDouble();

    // Create transaction
    final tx = {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'smeUid': smeUid,
      'contentId': content['id'],
      'rewardType': 'approval',
      'amount': amount,
      'description': 'Reward for ${content['type']} approval: ${content['title']}',
      'status': 'completed',
      'createdAt': DateTime.now().toIso8601String(),
    };

    _storage.addRewardTransaction(tx);
    _transactions.insert(0, tx);

    // Update wallet
    final wallet = _storage.getSMEWallet(smeUid);
    if (wallet != null) {
      final newTotal = (wallet['totalEarnings'] ?? 0) + amount;
      final newAvailable = (wallet['availableBalance'] ?? 0) + amount;
      _storage.updateSMEWallet(smeUid, {
        'totalEarnings': newTotal,
        'availableBalance': newAvailable,
        'lastUpdatedAt': DateTime.now().toIso8601String(),
      });
      _smeWallet = _storage.getSMEWallet(smeUid);
    }

    // Mark content as rewarded
    _storage.updateContent(content['id'], {
      'rewardGiven': true,
      'approvalRewardAmount': amount,
    });

    notifyListeners();
    return true;
  }

  /// Track content usage
  Future<void> trackContentUsage(String contentId) async {
    final content = _storage.getContent().firstWhere(
      (c) => c['id'] == contentId,
      orElse: () => {},
    );
    
    if (content.isEmpty) return;

    final newCount = (content['userCompletionCount'] ?? 0) + 1;
    _storage.updateContent(contentId, {'userCompletionCount': newCount});

    // Check if threshold reached
    final threshold = _rewardConfig?['usageThresholdForReward'] ?? 100;
    if (newCount == threshold) {
      await _giveUsageReward(content);
    }

    notifyListeners();
  }

  Future<void> _giveUsageReward(Map<String, dynamic> content) async {
    final perUser = (_rewardConfig?['usageRewardPerUser'] ?? 10).toDouble();
    final threshold = _rewardConfig?['usageThresholdForReward'] ?? 100;
    final amount = perUser * threshold;

    final tx = {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'smeUid': content['uploadedBy'],
      'contentId': content['id'],
      'rewardType': 'usage_threshold',
      'amount': amount,
      'description': 'Usage reward ($threshold users): ${content['title']}',
      'status': 'completed',
      'createdAt': DateTime.now().toIso8601String(),
    };

    _storage.addRewardTransaction(tx);

    // Update wallet
    final wallet = _storage.getSMEWallet(content['uploadedBy']);
    if (wallet != null) {
      _storage.updateSMEWallet(content['uploadedBy'], {
        'totalEarnings': (wallet['totalEarnings'] ?? 0) + amount,
        'availableBalance': (wallet['availableBalance'] ?? 0) + amount,
      });
      _smeWallet = _storage.getSMEWallet(content['uploadedBy']);
    }

    // Mark content
    _storage.updateContent(content['id'], {
      'usageRewardGiven': true,
      'usageRewardAmount': amount,
    });
  }

  /// Get total earnings
  double get totalEarnings => (_smeWallet?['totalEarnings'] ?? 0).toDouble();

  /// Get available balance
  double get availableBalance => (_smeWallet?['availableBalance'] ?? 0).toDouble();

  /// Get total withdrawn
  double get totalWithdrawn => (_smeWallet?['totalWithdrawn'] ?? 0).toDouble();
}