import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/sme_wallet_model.dart';
import '../models/reward_config_model.dart';
import '../models/reward_transaction_model.dart';
import '../models/content_model.dart';

class RewardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SMEWalletModel? _smeWallet;
  RewardConfigModel? _rewardConfig;
  List<RewardTransactionModel> _transactions = [];

  SMEWalletModel? get smeWallet => _smeWallet;
  RewardConfigModel? get rewardConfig => _rewardConfig;
  List<RewardTransactionModel> get transactions => _transactions;

  // Initialize or load reward configuration
  Future<void> loadRewardConfig() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('reward_config')
          .doc('default')
          .get();
      
      if (doc.exists) {
        _rewardConfig = RewardConfigModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      } else {
        // Create default config if it doesn't exist
        _rewardConfig = RewardConfigModel(
          id: 'default',
          approvalReward: 100.0,
          usageRewardPerUser: 10.0,
          usageThresholdForReward: 100,
          createdAt: DateTime.now(),
        );
        
        await _firestore
            .collection('reward_config')
            .doc('default')
            .set(_rewardConfig!.toMap());
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading reward config: $e');
    }
  }

  // Load SME wallet
  Future<void> loadSMEWallet(String smeUid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('sme_wallets')
          .doc(smeUid)
          .get();
      
      if (doc.exists) {
        _smeWallet = SMEWalletModel.fromMap(
          doc.data() as Map<String, dynamic>,
          smeUid,
        );
      } else {
        // Create wallet if it doesn't exist
        _smeWallet = SMEWalletModel(
          id: smeUid,
          createdAt: DateTime.now(),
        );
        
        await _firestore
            .collection('sme_wallets')
            .doc(smeUid)
            .set(_smeWallet!.toMap());
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading SME wallet: $e');
    }
  }

  // Load transaction history for SME
  Future<void> loadTransactionHistory(String smeUid) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reward_transactions')
          .where('smeUid', isEqualTo: smeUid)
          .orderBy('createdAt', descending: true)
          .get();
      
      _transactions = snapshot.docs
          .map((doc) => RewardTransactionModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      notifyListeners();
    } catch (e) {
      print('Error loading transaction history: $e');
    }
  }

  // Give approval reward when content is approved by admin
  Future<bool> giveApprovalReward({
    required String smeUid,
    required ContentModel content,
    required String adminUid,
  }) async {
    try {
      if (_rewardConfig == null) {
        await loadRewardConfig();
      }
      
      if (content.rewardGiven) {
        print('Reward already given for this content');
        return false;
      }

      double rewardAmount = _rewardConfig!.approvalReward;

      // Add content-type specific reward if available
      if (_rewardConfig!.contentTypeRewards.containsKey(content.type)) {
        rewardAmount = _rewardConfig!.contentTypeRewards[content.type]!;
      }

      // Create reward transaction
      RewardTransactionModel transaction = RewardTransactionModel(
        id: '', // Firestore will generate
        smeName: smeUid,
        contentId: content.id,
        rewardType: 'approval',
        amount: rewardAmount,
        description: 'Reward for ${content.type} approval: ${content.title}',
        metadata: {
          'contentTitle': content.title,
          'contentType': content.type,
        },
        status: 'completed',
        createdAt: DateTime.now(),
        processedAt: DateTime.now(),
      );

      // Add transaction to Firestore
      DocumentReference transactionRef =
          await _firestore.collection('reward_transactions').add(transaction.toMap());

      // Update SME wallet
      await _firestore.collection('sme_wallets').doc(smeUid).update({
        'availableBalance': FieldValue.increment(rewardAmount),
        'totalEarnings': FieldValue.increment(rewardAmount),
        'lastUpdatedAt': Timestamp.now(),
      });

      // Mark reward as given in content
      await _firestore.collection('content').doc(content.id).update({
        'rewardGiven': true,
        'approvalRewardAmount': rewardAmount,
      });

      // Reload wallet
      await loadSMEWallet(smeUid);
      await loadTransactionHistory(smeUid);

      return true;
    } catch (e) {
      print('Error giving approval reward: $e');
      return false;
    }
  }

  // Track user completion/usage of content
  Future<void> trackContentUsage(String contentId) async {
    try {
      await _firestore.collection('content').doc(contentId).update({
        'userCompletionCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error tracking content usage: $e');
    }
  }

  // Check and give usage-based reward when threshold is reached
  Future<bool> checkAndGiveUsageReward({
    required String smeUid,
    required ContentModel content,
  }) async {
    try {
      if (_rewardConfig == null) {
        await loadRewardConfig();
      }

      if (content.usageRewardGiven) {
        return false; // Already given
      }

      if (content.userCompletionCount < _rewardConfig!.usageThresholdForReward) {
        return false; // Not yet threshold reached
      }

      // Calculate reward based on user count
      double totalUsageReward =
          _rewardConfig!.usageRewardPerUser * content.userCompletionCount;

      // Create usage reward transaction
      RewardTransactionModel transaction = RewardTransactionModel(
        id: '',
        smeName: smeUid,
        contentId: content.id,
        rewardType: 'usage_threshold',
        amount: totalUsageReward,
        description:
            'Usage reward for ${content.title} (${content.userCompletionCount} users)',
        metadata: {
          'contentTitle': content.title,
          'contentType': content.type,
          'userCount': content.userCompletionCount,
          'rewardPerUser': _rewardConfig!.usageRewardPerUser,
        },
        status: 'completed',
        createdAt: DateTime.now(),
        processedAt: DateTime.now(),
      );

      // Add transaction to Firestore
      await _firestore.collection('reward_transactions').add(transaction.toMap());

      // Update SME wallet
      await _firestore.collection('sme_wallets').doc(smeUid).update({
        'availableBalance': FieldValue.increment(totalUsageReward),
        'totalEarnings': FieldValue.increment(totalUsageReward),
        'lastUpdatedAt': Timestamp.now(),
      });

      // Mark usage reward as given in content
      await _firestore.collection('content').doc(content.id).update({
        'usageRewardGiven': true,
        'usageRewardAmount': totalUsageReward,
      });

      // Reload wallet and transactions
      await loadSMEWallet(smeUid);
      await loadTransactionHistory(smeUid);

      return true;
    } catch (e) {
      print('Error giving usage reward: $e');
      return false;
    }
  }

  // Update reward configuration (Admin only)
  Future<bool> updateRewardConfig({
    required String adminUid,
    double? newApprovalReward,
    Map<String, double>? newContentTypeRewards,
    double? newUsageRewardPerUser,
    int? newUsageThreshold,
  }) async {
    try {
      if (_rewardConfig == null) {
        await loadRewardConfig();
      }

      final updatedConfig = RewardConfigModel(
        id: _rewardConfig!.id,
        approvalReward: newApprovalReward ?? _rewardConfig!.approvalReward,
        contentTypeRewards:
            newContentTypeRewards ?? _rewardConfig!.contentTypeRewards,
        usageRewardPerUser:
            newUsageRewardPerUser ?? _rewardConfig!.usageRewardPerUser,
        usageThresholdForReward:
            newUsageThreshold ?? _rewardConfig!.usageThresholdForReward,
        isActive: true,
        createdAt: _rewardConfig!.createdAt,
        updatedAt: DateTime.now(),
        updatedBy: adminUid,
      );

      await _firestore
          .collection('reward_config')
          .doc('default')
          .update(updatedConfig.toMap());

      _rewardConfig = updatedConfig;
      notifyListeners();

      return true;
    } catch (e) {
      print('Error updating reward config: $e');
      return false;
    }
  }

  // Get wallet balance for SME
  double getAvailableBalance() {
    return _smeWallet?.availableBalance ?? 0.0;
  }

  // Get total earnings for SME
  double getTotalEarnings() {
    return _smeWallet?.totalEarnings ?? 0.0;
  }

  // Get transaction count
  int getTransactionCount() {
    return _transactions.length;
  }
}
