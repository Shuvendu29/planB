import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reward_provider.dart';
import '../../models/content_model.dart';
import '../../widgets/common_widgets.dart';

/// SME Dashboard - Web-optimized interface for content creators
class SMEDashboardScreen extends StatefulWidget {
  const SMEDashboardScreen({super.key});

  @override
  State<SMEDashboardScreen> createState() => _SMEDashboardScreenState();
}

class _SMEDashboardScreenState extends State<SMEDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final smeUid = authProvider.currentUser!.uid;
      Provider.of<RewardProvider>(context, listen: false).loadSMEWallet(smeUid);
      Provider.of<RewardProvider>(context, listen: false).loadRewardConfig();
      Provider.of<RewardProvider>(context, listen: false).loadTransactionHistory(smeUid);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF), // SME background
      body: Row(
        children: [
          // Sidebar
          _SMESidebar(currentIndex: _tabController.index, onTap: (index) => _tabController.animateTo(index)),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _SMETopBar(),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _DashboardTab(),
                      _ContentTab(),
                      _EarningsTab(),
                      _ProfileTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SMESidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _SMESidebar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.surface,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.smeGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text('SME Portal', style: AppTextStyles.headline3),
              ],
            ),
          ),

          const Divider(height: 1),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _SidebarItem(icon: Icons.dashboard, label: 'Dashboard', isSelected: currentIndex == 0, onTap: () => onTap(0)),
                _SidebarItem(icon: Icons.folder, label: 'My Content', isSelected: currentIndex == 1, onTap: () => onTap(1)),
                _SidebarItem(icon: Icons.account_balance_wallet, label: 'Earnings', isSelected: currentIndex == 2, onTap: () => onTap(2)),
                _SidebarItem(icon: Icons.person, label: 'Profile', isSelected: currentIndex == 3, onTap: () => onTap(3)),
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Log Out', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await Provider.of<AuthProvider>(context, listen: false).signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.smePrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.smePrimary.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.smePrimary : AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.smePrimary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SMETopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surface,
      child: Row(
        children: [
          const Spacer(),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: AppSpacing.sm),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.smePrimary.withOpacity(0.1),
                child: Text(
                  (authProvider.currentUser?.email ?? 'S')[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.smePrimary, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD TAB ====================

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),

          // Stats Row
          Consumer<RewardProvider>(
            builder: (context, rewardProvider, _) {
              final wallet = rewardProvider.smeWallet;
              return Row(
                children: [
                  Expanded(child: StatCard(title: 'Total Earnings', value: '₹${wallet?.totalEarnings.toStringAsFixed(0) ?? '0'}', icon: Icons.account_balance_wallet, color: AppColors.smePrimary)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: StatCard(title: 'Available', value: '₹${wallet?.availableBalance.toStringAsFixed(0) ?? '0'}', icon: Icons.account_balance, color: AppColors.secondary)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: StatCard(title: 'Withdrawn', value: '₹${wallet?.totalWithdrawn.toStringAsFixed(0) ?? '0'}', icon: Icons.payments, color: AppColors.accent)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: StatCard(title: 'This Month', value: '+₹2,500', icon: Icons.trending_up, color: AppColors.success)),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Earnings Chart Placeholder
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppCards.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Earnings Trend (Last 6 Months)', style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ChartBar(month: 'Oct', value: 0.3, color: AppColors.smePrimary),
                      _ChartBar(month: 'Nov', value: 0.5, color: AppColors.smePrimary),
                      _ChartBar(month: 'Dec', value: 0.4, color: AppColors.smePrimary),
                      _ChartBar(month: 'Jan', value: 0.7, color: AppColors.smePrimary),
                      _ChartBar(month: 'Feb', value: 0.6, color: AppColors.smePrimary),
                      _ChartBar(month: 'Mar', value: 0.8, color: AppColors.smePrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Recent Transactions
          const SectionHeader(title: 'Recent Transactions', actionText: 'View All'),
          Consumer<RewardProvider>(
            builder: (context, rewardProvider, _) {
              final transactions = rewardProvider.transactions;
              if (transactions.isEmpty) {
                return const EmptyState(icon: Icons.receipt_long, title: 'No transactions yet');
              }
              return Container(
                decoration: AppCards.standard,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length > 5 ? 5 : transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      ),
                      title: Text(tx.description, style: AppTextStyles.subtitle2),
                      subtitle: Text(tx.createdAt.toString().substring(0, 10), style: AppTextStyles.caption),
                      trailing: Text('+₹${tx.amount.toStringAsFixed(0)}', style: AppTextStyles.subtitle1.copyWith(color: AppColors.success)),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Pending Content
          const SectionHeader(title: 'Pending Content', actionText: 'Review'),
          _PendingContentList(),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String month;
  final double value;
  final Color color;

  const _ChartBar({required this.month, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 150 * value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(month, style: AppTextStyles.caption),
      ],
    );
  }
}

class _PendingContentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('content')
          .where('uploadedBy', isEqualTo: authProvider.currentUser?.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(icon: Icons.check_circle, title: 'No pending content');
        }
        return Container(
          decoration: AppCards.standard,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final content = ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hourglass_empty, color: AppColors.warning, size: 20),
                ),
                title: Text(content.title, style: AppTextStyles.subtitle2),
                subtitle: Text('Type: ${content.type}', style: AppTextStyles.caption),
                trailing: Text('Submitted ${content.uploadedAt.toString().substring(0, 10)}', style: AppTextStyles.caption),
              );
            },
          ),
        );
      },
    );
  }
}

// ==================== CONTENT TAB ====================

class _ContentTab extends StatelessWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Content', style: AppTextStyles.headline1),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _UploadContentScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Upload New'),
                style: AppButtons.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'Approved'),
                _FilterChip(label: 'Pending'),
                _FilterChip(label: 'Rejected'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Content List
          _SMEContentList(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.smePrimary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.smePrimary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.smePrimary : Colors.transparent),
        ),
      ),
    );
  }
}

class _SMEContentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('content')
          .where('uploadedBy', isEqualTo: authProvider.currentUser?.uid)
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoader();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(icon: Icons.folder_open, title: 'No content uploaded yet');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final content = ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            return _ContentCard(content: content);
          },
        );
      },
    );
  }
}

class _ContentCard extends StatelessWidget {
  final ContentModel content;

  const _ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppCards.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.smePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getTypeIcon(content.type), color: AppColors.smePrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content.title, style: AppTextStyles.subtitle1),
                    Text(content.type, style: AppTextStyles.caption),
                  ],
                ),
              ),
              _buildStatusBadge(content.status),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(label: 'Views', value: '${content.userCompletionCount}'),
              _InfoItem(label: 'Earned', value: '₹${content.approvalRewardAmount?.toStringAsFixed(0) ?? '0'}'),
              _InfoItem(label: 'Uploaded', value: content.uploadedAt.toString().substring(0, 10)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.visibility, size: 18), label: const Text('View'))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.analytics, size: 18), label: const Text('Analytics'))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 18), label: const Text('Edit'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'approved':
        return StatusBadge.approved();
      case 'pending':
        return StatusBadge.pending();
      case 'rejected':
        return StatusBadge.rejected();
      default:
        return const SizedBox();
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'mock_test':
        return Icons.quiz;
      case 'entrance_exam':
        return Icons.school;
      case 'study_notes':
        return Icons.menu_book;
      case 'current_affairs':
        return Icons.newspaper;
      default:
        return Icons.article;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.subtitle1),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ==================== EARNINGS TAB ====================

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Earnings', style: AppTextStyles.headline1),
              Row(
                children: [
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 18), label: const Text('Export')),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.payments, size: 18), label: const Text('Withdraw'), style: AppButtons.secondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Wallet Summary
          Consumer<RewardProvider>(
            builder: (context, rewardProvider, _) {
              final wallet = rewardProvider.smeWallet;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.smeGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Earned', style: TextStyle(color: Colors.white70)),
                        Text('₹${wallet?.totalEarnings.toStringAsFixed(2) ?? '0'}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WalletStat(label: 'Available', value: '₹${wallet?.availableBalance.toStringAsFixed(0) ?? '0'}'),
                        _WalletStat(label: 'Pending', value: '₹2,000'),
                        _WalletStat(label: 'Withdrawn', value: '₹${wallet?.totalWithdrawn.toStringAsFixed(0) ?? '0'}'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Transaction History
          const SectionHeader(title: 'Transaction History'),
          Consumer<RewardProvider>(
            builder: (context, rewardProvider, _) {
              final transactions = rewardProvider.transactions;
              if (transactions.isEmpty) {
                return const EmptyState(icon: Icons.receipt_long, title: 'No transactions yet');
              }
              return Container(
                decoration: AppCards.standard,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isWithdrawal = tx.rewardType == 'withdrawal';
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isWithdrawal ? AppColors.error : AppColors.success).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(isWithdrawal ? Icons.arrow_downward : Icons.check_circle, color: isWithdrawal ? AppColors.error : AppColors.success, size: 20),
                      ),
                      title: Text(tx.description, style: AppTextStyles.subtitle2),
                      subtitle: Text(tx.createdAt.toString().substring(0, 10), style: AppTextStyles.caption),
                      trailing: Text(
                        '${isWithdrawal ? '-' : '+'}₹${tx.amount.toStringAsFixed(0)}',
                        style: AppTextStyles.subtitle1.copyWith(color: isWithdrawal ? AppColors.error : AppColors.success),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Earnings by Type
          const SectionHeader(title: 'Earnings by Content Type'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Column(
              children: [
                _EarningBar(label: 'Mock Tests', amount: 8000, percentage: 0.52, color: AppColors.smePrimary),
                const SizedBox(height: AppSpacing.md),
                _EarningBar(label: 'Entrance Exams', amount: 5000, percentage: 0.33, color: AppColors.secondary),
                const SizedBox(height: AppSpacing.md),
                _EarningBar(label: 'Study Notes', amount: 1200, percentage: 0.08, color: AppColors.accent),
                const SizedBox(height: AppSpacing.md),
                _EarningBar(label: 'Current Affairs', amount: 1000, percentage: 0.07, color: Colors.pink),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  final String label;
  final String value;

  const _WalletStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _EarningBar extends StatelessWidget {
  final String label;
  final int amount;
  final double percentage;
  final Color color;

  const _EarningBar({required this.label, required this.amount, required this.percentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.subtitle2),
            Text('₹$amount (${(percentage * 100).toStringAsFixed(0)}%)', style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

// ==================== PROFILE TAB ====================

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),

          // Profile Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppCards.standard,
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.smeGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SME User', style: AppTextStyles.headline2),
                      const SizedBox(height: AppSpacing.xs),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return Text(authProvider.currentUser?.email ?? '', style: AppTextStyles.body2);
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.smePrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Verified SME', style: TextStyle(color: AppColors.smePrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Stats
          Row(
            children: [
              Expanded(child: StatCard(title: 'Total Content', value: '45', icon: Icons.folder, color: AppColors.smePrimary)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: StatCard(title: 'Approved', value: '40', icon: Icons.check_circle, color: AppColors.success)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: StatCard(title: 'Pending', value: '3', icon: Icons.hourglass_empty, color: AppColors.warning)),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Menu Items
          _ProfileMenuItem(icon: Icons.badge, title: 'KYC Information', onTap: () {}),
          _ProfileMenuItem(icon: Icons.bank, title: 'Bank Details', onTap: () {}),
          _ProfileMenuItem(icon: Icons.notifications, title: 'Notifications', onTap: () {}),
          _ProfileMenuItem(icon: Icons.help, title: 'Help & Support', onTap: () {}),
          _ProfileMenuItem(icon: Icons.logout, title: 'Log Out', isDestructive: true, onTap: () async {
            await Provider.of<AuthProvider>(context, listen: false).signOut();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({required this.icon, required this.title, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppCards.standard,
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary),
        title: Text(title, style: AppTextStyles.body1.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}

// ==================== UPLOAD SCREEN ====================

class _UploadContentScreen extends StatefulWidget {
  const _UploadContentScreen();

  @override
  State<_UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<_UploadContentScreen> {
  String _selectedType = 'mock_test';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Content'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Content Type', style: AppTextStyles.subtitle2),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _TypeChip(label: 'Mock Test', value: 'mock_test', isSelected: _selectedType == 'mock_test', onTap: () => setState(() => _selectedType = 'mock_test')),
                _TypeChip(label: 'Entrance Exam', value: 'entrance_exam', isSelected: _selectedType == 'entrance_exam', onTap: () => setState(() => _selectedType = 'entrance_exam')),
                _TypeChip(label: 'Study Notes', value: 'study_notes', isSelected: _selectedType == 'study_notes', onTap: () => setState(() => _selectedType = 'study_notes')),
                _TypeChip(label: 'Current Affairs', value: 'current_affairs', isSelected: _selectedType == 'current_affairs', onTap: () => setState(() => _selectedType = 'current_affairs')),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            TextField(controller: _titleController, decoration: AppInputs.textField(label: 'Title', prefixIcon: Icons.title)),
            const SizedBox(height: AppSpacing.md),
            TextField(controller: _descriptionController, maxLines: 5, decoration: AppInputs.textField(label: 'Description', prefixIcon: Icons.description)),

            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload, size: 48, color: AppColors.textHint),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Drag files here or click to browse', style: AppTextStyles.body2),
                  const Text('PDF, DOC, JPG up to 50MB', style: AppTextStyles.caption),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppCards.gradient(AppColors.smePrimary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💰 Reward Preview', style: AppTextStyles.subtitle1),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Upon approval, you\'ll earn:', style: AppTextStyles.body2),
                  const SizedBox(height: AppSpacing.xs),
                  Text('• Base reward: ₹100', style: AppTextStyles.caption),
                  Text('• Type bonus: ${_getTypeBonus()}', style: AppTextStyles.caption),
                  Text('• Total: ${_getTypeBonus().replaceAll('₹', '').replaceAll(' ', '')}', style: AppTextStyles.subtitle1.copyWith(color: AppColors.smePrimary)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: AppButtons.outline, child: const Text('Cancel'))),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: ElevatedButton(onPressed: _submitContent, style: AppButtons.primary, child: const Text('Submit for Review'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeBonus() {
    switch (_selectedType) {
      case 'mock_test':
        return '₹500 (Mock Test)';
      case 'entrance_exam':
        return '₹1000 (Entrance Exam)';
      case 'study_notes':
        return '₹100 (Study Notes)';
      case 'current_affairs':
        return '₹50 (Current Affairs)';
      default:
        return '₹0';
    }
  }

  void _submitContent() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    FirebaseFirestore.instance.collection('content').add({
      'type': _selectedType,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'fileUrls': [],
      'uploadedBy': authProvider.currentUser?.uid,
      'status': 'pending',
      'uploadedAt': Timestamp.now(),
      'rewardGiven': false,
      'userCompletionCount': 0,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content submitted for review!'), backgroundColor: AppColors.success));
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.value, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.smePrimary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.smePrimary : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

// Firebase import
import 'package:cloud_firestore/cloud_firestore.dart';