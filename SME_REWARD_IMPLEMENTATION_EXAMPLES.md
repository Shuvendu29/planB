# SME Reward System - Implementation Examples

This file contains practical code examples for integrating the reward system into your screens.

## Example 1: Admin Approval Screen Integration

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';
import '../models/content_model.dart';

class AdminContentApprovalScreen extends StatefulWidget {
  final ContentModel content;
  final String adminUid;

  const AdminContentApprovalScreen({
    required this.content,
    required this.adminUid,
  });

  @override
  State<AdminContentApprovalScreen> createState() => _AdminContentApprovalScreenState();
}

class _AdminContentApprovalScreenState extends State<AdminContentApprovalScreen> {
  bool _isProcessing = false;

  Future<void> _approveAndReward() async {
    setState(() => _isProcessing = true);

    try {
      final rewardProvider = Provider.of<RewardProvider>(context, listen: false);

      // Step 1: Approve content in Firestore
      // (Your existing approval logic)
      await approveContentInFirestore(
        contentId: widget.content.id,
        adminUid: widget.adminUid,
      );

      // Step 2: Give SME approval reward
      final rewardGiven = await rewardProvider.giveApprovalReward(
        smeUid: widget.content.uploadedBy,
        content: widget.content,
        adminUid: widget.adminUid,
      );

      if (rewardGiven) {
        final rewardAmount = widget.content.type == 'mock_test'
            ? 500.0
            : (widget.content.type == 'entrance_exam' ? 1000.0 : 100.0);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Content Approved! SME credited ₹$rewardAmount',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _rejectContent() async {
    setState(() => _isProcessing = true);

    try {
      // Reject without reward
      await rejectContentInFirestore(
        contentId: widget.content.id,
        adminUid: widget.adminUid,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Content Rejected'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context, false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Content'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Content preview
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.content.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Type: ${widget.content.type}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Uploaded by: ${widget.content.uploadedBy}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 16),
                  Text(widget.content.description),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          
          // Reward preview
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reward Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Approval Reward:'),
                      Consumer<RewardProvider>(
                        builder: (context, rewardProvider, _) {
                          final amount = rewardProvider.rewardConfig
                              ?.contentTypeRewards[widget.content.type] ??
                              100.0;
                          return Text(
                            '₹$amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SME will receive this amount immediately upon approval.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Additional usage-based rewards will be given when 100+ users complete this content.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing ? null : _rejectContent,
                  child: Text('Reject'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _approveAndReward,
                  icon: Icon(Icons.check),
                  label: Text('Approve & Reward'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper function to approve content in Firestore
Future<void> approveContentInFirestore({
  required String contentId,
  required String adminUid,
}) async {
  // TODO: Implement your content approval logic
  // This should update the content document with:
  // - status: 'approved'
  // - approvedAt: timestamp
  // - approvedBy: adminUid
}

// Helper function to reject content
Future<void> rejectContentInFirestore({
  required String contentId,
  required String adminUid,
}) async {
  // TODO: Implement your content rejection logic
}
```

## Example 2: SME Dashboard - Wallet & Earnings

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';

class SMEDashboardScreen extends StatefulWidget {
  final String smeUid;

  const SMEDashboardScreen({required this.smeUid});

  @override
  State<SMEDashboardScreen> createState() => _SMEDashboardScreenState();
}

class _SMEDashboardScreenState extends State<SMEDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    await rewardProvider.loadSMEWallet(widget.smeUid);
    await rewardProvider.loadTransactionHistory(widget.smeUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Earnings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wallet Summary Cards
            _buildWalletSummary(),
            SizedBox(height: 24),
            // Transaction History
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSummary() {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, _) {
        final wallet = rewardProvider.smeWallet;
        final availableBalance = rewardProvider.getAvailableBalance();
        final totalEarnings = rewardProvider.getTotalEarnings();

        if (wallet == null) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Primary Balance Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₹${availableBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Statistics Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Earned',
                      '₹${totalEarnings.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Withdrawn',
                      '₹${wallet.totalWithdrawn.toStringAsFixed(2)}',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withAlpha(25),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Consumer<RewardProvider>(
      builder: (context, rewardProvider, _) {
        final transactions = rewardProvider.transactions;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reward History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              if (transactions.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('No transactions yet'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    final icon = _getRewardIcon(txn.rewardType);
                    final color = _getRewardColor(txn.rewardType);

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: color.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(
                          txn.description,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _formatDate(txn.createdAt),
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          '+ ₹${txn.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getRewardIcon(String rewardType) {
    switch (rewardType) {
      case 'approval':
        return Icons.check_circle;
      case 'usage_threshold':
        return Icons.trending_up;
      case 'content_creation':
        return Icons.create;
      default:
        return Icons.info;
    }
  }

  Color _getRewardColor(String rewardType) {
    switch (rewardType) {
      case 'approval':
        return Colors.blue;
      case 'usage_threshold':
        return Colors.green;
      case 'content_creation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

## Example 3: Admin CMS - Reward Configuration

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';

class AdminRewardConfigScreen extends StatefulWidget {
  final String adminUid;

  const AdminRewardConfigScreen({required this.adminUid});

  @override
  State<AdminRewardConfigScreen> createState() => _AdminRewardConfigScreenState();
}

class _AdminRewardConfigScreenState extends State<AdminRewardConfigScreen> {
  late TextEditingController _approvalRewardController;
  late TextEditingController _mockTestRewardController;
  late TextEditingController _examRewardController;
  late TextEditingController _notesRewardController;
  late TextEditingController _affairsRewardController;
  late TextEditingController _usageRewardPerUserController;
  late TextEditingController _usageThresholdController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);
    final config = rewardProvider.rewardConfig;

    if (config != null) {
      _approvalRewardController = TextEditingController(
        text: config.approvalReward.toString(),
      );
      _mockTestRewardController = TextEditingController(
        text: config.contentTypeRewards['mock_test']?.toString() ?? '500',
      );
      _examRewardController = TextEditingController(
        text: config.contentTypeRewards['entrance_exam']?.toString() ?? '1000',
      );
      _notesRewardController = TextEditingController(
        text: config.contentTypeRewards['study_notes']?.toString() ?? '100',
      );
      _affairsRewardController = TextEditingController(
        text: config.contentTypeRewards['current_affairs']?.toString() ?? '50',
      );
      _usageRewardPerUserController = TextEditingController(
        text: config.usageRewardPerUser.toString(),
      );
      _usageThresholdController = TextEditingController(
        text: config.usageThresholdForReward.toString(),
      );
    } else {
      // Default values
      _approvalRewardController = TextEditingController(text: '100');
      _mockTestRewardController = TextEditingController(text: '500');
      _examRewardController = TextEditingController(text: '1000');
      _notesRewardController = TextEditingController(text: '100');
      _affairsRewardController = TextEditingController(text: '50');
      _usageRewardPerUserController = TextEditingController(text: '10');
      _usageThresholdController = TextEditingController(text: '100');
    }
  }

  Future<void> _saveConfiguration() async {
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);

    try {
      final success = await rewardProvider.updateRewardConfig(
        adminUid: widget.adminUid,
        newApprovalReward: double.parse(_approvalRewardController.text),
        newContentTypeRewards: {
          'mock_test': double.parse(_mockTestRewardController.text),
          'entrance_exam': double.parse(_examRewardController.text),
          'study_notes': double.parse(_notesRewardController.text),
          'current_affairs': double.parse(_affairsRewardController.text),
        },
        newUsageRewardPerUser: double.parse(_usageRewardPerUserController.text),
        newUsageThreshold: int.parse(_usageThresholdController.text),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reward configuration updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Invalid input. Please check your values.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reward Configuration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Base Reward Section
              _buildSectionHeader('Base Rewards'),
              _buildTextField(
                controller: _approvalRewardController,
                label: 'Approval Reward (₹)',
                hint: '100',
              ),
              SizedBox(height: 24),

              // Content Type Rewards Section
              _buildSectionHeader('Content Type Rewards (₹)'),
              _buildTextField(
                controller: _mockTestRewardController,
                label: 'Mock Test',
              ),
              _buildTextField(
                controller: _examRewardController,
                label: 'Entrance Exam',
              ),
              _buildTextField(
                controller: _notesRewardController,
                label: 'Study Notes',
              ),
              _buildTextField(
                controller: _affairsRewardController,
                label: 'Current Affairs',
              ),
              SizedBox(height: 24),

              // Usage Based Rewards Section
              _buildSectionHeader('Usage-Based Rewards'),
              _buildTextField(
                controller: _usageRewardPerUserController,
                label: 'Reward Per User (₹)',
                hint: '10',
              ),
              _buildTextField(
                controller: _usageThresholdController,
                label: 'Threshold (user count)',
                hint: '100',
              ),
              SizedBox(height: 8),
              Text(
                'SMEs will receive rewards when content is completed by this many users.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveConfiguration,
                  icon: Icon(Icons.save),
                  label: Text('Save Configuration'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Information Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How the Reward System Works',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 12),
                      _buildRewardExplanation(
                        '1. Approval Reward',
                        'Given when you approve content.',
                        Colors.blue,
                      ),
                      _buildRewardExplanation(
                        '2. Content Type Reward',
                        'Different amounts for different content types.',
                        Colors.green,
                      ),
                      _buildRewardExplanation(
                        '3. Usage Reward',
                        'When content is completed by the threshold number of users.',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixText: '₹ ',
        ),
      ),
    );
  }

  Widget _buildRewardExplanation(String title, String description, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: color,
            margin: EdgeInsets.only(right: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _approvalRewardController.dispose();
    _mockTestRewardController.dispose();
    _examRewardController.dispose();
    _notesRewardController.dispose();
    _affairsRewardController.dispose();
    _usageRewardPerUserController.dispose();
    _usageThresholdController.dispose();
    super.dispose();
  }
}
```

## Integration Checklist

- [ ] Add models to project
- [ ] Add RewardProvider to Provider list in `main.dart`
- [ ] Add approval reward call in admin content approval flow
- [ ] Add usage tracking call in content completion handler
- [ ] Create SME wallet/earnings dashboard
- [ ] Create admin reward configuration CMS
- [ ] Set up Firestore security rules
- [ ] Test complete approval → reward flow
- [ ] Test usage threshold → reward flow
- [ ] Add transaction history to SME profile

---

These examples provide the foundation for integrating the reward system into your app's existing screens.
