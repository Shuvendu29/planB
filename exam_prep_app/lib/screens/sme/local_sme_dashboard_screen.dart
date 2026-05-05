import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/local_auth_provider.dart';
import '../../providers/local_reward_provider.dart';
import '../../data/local_storage.dart';
import '../../widgets/common_widgets.dart';

/// SME Dashboard - Local version for testing
class LocalSMEDashboardScreen extends StatefulWidget {
  const LocalSMEDashboardScreen({super.key});

  @override
  State<LocalSMEDashboardScreen> createState() => _LocalSMEDashboardScreenState();
}

class _LocalSMEDashboardScreenState extends State<LocalSMEDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final authProvider = Provider.of<LocalAuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final smeUid = authProvider.currentUser!['uid'] ?? 'sme1';
      Provider.of<LocalRewardProvider>(context, listen: false).loadSMEWallet(smeUid);
      Provider.of<LocalRewardProvider>(context, listen: false).loadRewardConfig();
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
      backgroundColor: const Color(0xFFFAF5FF),
      body: Row(
        children: [
          // Sidebar
          _SMESidebar(currentIndex: _tabController.index, onTap: (index) => _tabController.animateTo(index)),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _SMETopBar(),
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(gradient: AppColors.smeGradient, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text('SME Portal', style: AppTextStyles.headline3),
              ],
            ),
          ),
          const Divider(height: 1),
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
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Log Out', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await Provider.of<LocalAuthProvider>(context, listen: false).signOut();
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
            Text(label, style: TextStyle(color: isSelected ? AppColors.smePrimary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
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
          Consumer<LocalAuthProvider>(
            builder: (context, authProvider, _) {
              return CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.smePrimary.withOpacity(0.1),
                child: Text((authProvider.currentUser?['name'] ?? 'S')[0].toString().toUpperCase(), style: const TextStyle(color: AppColors.smePrimary, fontWeight: FontWeight.bold)),
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
          Consumer<LocalRewardProvider>(
            builder: (context, rewardProvider, _) {
              final wallet = rewardProvider.smeWallet;
              return Row(
                children: [
                  Expanded(child: StatCard(title: 'Total Earnings', value: '₹${(wallet?['totalEarnings'] ?? 0).toStringAsFixed(0)}', icon: Icons.account_balance_wallet, color: AppColors.smePrimary)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: StatCard(title: 'Available', value: '₹${(wallet?['availableBalance'] ?? 0).toStringAsFixed(0)}', icon: Icons.account_balance, color: AppColors.secondary)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: StatCard(title: 'Withdrawn', value: '₹${(wallet?['totalWithdrawn'] ?? 0).toStringAsFixed(0)}', icon: Icons.payments, color: AppColors.accent)),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(child: StatCard(title: 'This Month', value: '+₹2,500', icon: Icons.trending_up, color: AppColors.success)),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Recent Transactions'),
          Consumer<LocalRewardProvider>(
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
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      ),
                      title: Text(tx['description'] ?? '', style: AppTextStyles.subtitle2),
                      subtitle: Text(tx['createdAt']?.toString().substring(0, 10) ?? '', style: AppTextStyles.caption),
                      trailing: Text('+₹${(tx['amount'] ?? 0).toStringAsFixed(0)}', style: AppTextStyles.subtitle1.copyWith(color: AppColors.success)),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== CONTENT TAB ====================

class _ContentTab extends StatelessWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LocalAuthProvider>(context, listen: false);
    final smeUid = authProvider.currentUser?['uid'] ?? 'sme1';
    final content = localStorage.getContent(uploadedBy: smeUid);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Content', style: AppTextStyles.headline1),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Upload New'), style: AppButtons.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (content.isEmpty)
            const EmptyState(icon: Icons.folder_open, title: 'No content uploaded yet')
          else
            ...content.map((c) => _ContentCard(content: c)),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Map<String, dynamic> content;

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
                decoration: BoxDecoration(color: AppColors.smePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(_getTypeIcon(content['type'] ?? ''), color: AppColors.smePrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content['title'] ?? '', style: AppTextStyles.subtitle1),
                    Text(content['type'] ?? '', style: AppTextStyles.caption),
                  ],
                ),
              ),
              _buildStatusBadge(content['status'] ?? ''),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(label: 'Views', value: '${content['userCompletionCount'] ?? 0}'),
              _InfoItem(label: 'Earned', value: '₹${(content['approvalRewardAmount'] ?? 0).toStringAsFixed(0)}'),
              _InfoItem(label: 'Uploaded', value: content['uploadedAt']?.toString().substring(0, 10) ?? ''),
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
      case 'mock_test': return Icons.quiz;
      case 'entrance_exam': return Icons.school;
      case 'study_notes': return Icons.menu_book;
      case 'current_affairs': return Icons.newspaper;
      default: return Icons.article;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: AppTextStyles.subtitle1), Text(label, style: AppTextStyles.caption)]);
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
          const Text('My Earnings', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),
          Consumer<LocalRewardProvider>(
            builder: (context, rewardProvider, _) {
              final wallet = rewardProvider.smeWallet;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(gradient: AppColors.smeGradient, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Earned', style: TextStyle(color: Colors.white70)),
                        Text('₹${(wallet?['totalEarnings'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WalletStat(label: 'Available', value: '₹${(wallet?['availableBalance'] ?? 0).toStringAsFixed(0)}'),
                        _WalletStat(label: 'Pending', value: '₹2,000'),
                        _WalletStat(label: 'Withdrawn', value: '₹${(wallet?['totalWithdrawn'] ?? 0).toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Transaction History'),
          Consumer<LocalRewardProvider>(
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
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      ),
                      title: Text(tx['description'] ?? '', style: AppTextStyles.subtitle2),
                      subtitle: Text(tx['createdAt']?.toString().substring(0, 10) ?? '', style: AppTextStyles.caption),
                      trailing: Text('+₹${(tx['amount'] ?? 0).toStringAsFixed(0)}', style: AppTextStyles.subtitle1.copyWith(color: AppColors.success)),
                    );
                  },
                ),
              );
            },
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
    return Column(children: [Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppCards.standard,
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(gradient: AppColors.smeGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SME User', style: AppTextStyles.headline2),
                      Consumer<LocalAuthProvider>(builder: (context, authProvider, _) => Text(authProvider.currentUser?['email'] ?? '', style: AppTextStyles.body2)),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.smePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Verified SME', style: TextStyle(color: AppColors.smePrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileMenuItem(icon: Icons.logout, title: 'Log Out', isDestructive: true, onTap: () async {
            await Provider.of<LocalAuthProvider>(context, listen: false).signOut();
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