import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/local_auth_provider.dart';
import '../../data/local_storage.dart';
import '../../widgets/common_widgets.dart';

/// Admin Dashboard - Local version for testing
class LocalAdminDashboardScreen extends StatefulWidget {
  const LocalAdminDashboardScreen({super.key});

  @override
  State<LocalAdminDashboardScreen> createState() => _LocalAdminDashboardScreenState();
}

class _LocalAdminDashboardScreenState extends State<LocalAdminDashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      body: Row(
        children: [
          _AdminSidebar(selectedIndex: _selectedNavIndex, onTap: (index) => setState(() => _selectedNavIndex = index)),
          Expanded(
            child: Column(
              children: [
                _AdminTopBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedNavIndex) {
      case 0: return const _OverviewTab();
      case 1: return const _ContentTab();
      case 2: return const _SMEsTab();
      case 3: return const _RewardsTab();
      default: return const _OverviewTab();
    }
  }
}

class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _AdminSidebar({required this.selectedIndex, required this.onTap});

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
                  decoration: BoxDecoration(gradient: AppColors.adminGradient, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text('Admin Panel', style: AppTextStyles.headline3),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _SidebarItem(icon: Icons.dashboard, label: 'Overview', isSelected: selectedIndex == 0, onTap: () => onTap(0)),
                _SidebarItem(icon: Icons.folder_copy, label: 'Content', isSelected: selectedIndex == 1, onTap: () => onTap(1)),
                _SidebarItem(icon: Icons.people, label: 'SMEs', isSelected: selectedIndex == 2, onTap: () => onTap(2)),
                _SidebarItem(icon: Icons.card_giftcard, label: 'Rewards', isSelected: selectedIndex == 3, onTap: () => onTap(3)),
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
          color: isSelected ? AppColors.adminPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.adminPrimary.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.adminPrimary : AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: TextStyle(color: isSelected ? AppColors.adminPrimary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
            if (label == 'Content') ...[const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(10)), child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))],
          ],
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surface,
      child: Row(
        children: [
          const Text('Welcome, Admin', style: AppTextStyles.headline3),
          const Spacer(),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(radius: 18, backgroundColor: AppColors.adminPrimary.withOpacity(0.1), child: const Icon(Icons.admin_panel_settings, color: AppColors.adminPrimary, size: 20)),
        ],
      ),
    );
  }
}

// ==================== OVERVIEW TAB ====================

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final pendingContent = localStorage.getContent(status: 'pending');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Expanded(child: StatCard(title: 'Total Users', value: '12,450', icon: Icons.people, color: AppColors.primary, subtitle: '+124 this week')),
              const SizedBox(width: AppSpacing.md),
              const Expanded(child: StatCard(title: 'Active SMEs', value: '156', icon: Icons.school, color: AppColors.smePrimary, subtitle: '+12 this month')),
              const SizedBox(width: AppSpacing.md),
              const Expanded(child: StatCard(title: 'Total Content', value: '890', icon: Icons.folder, color: AppColors.secondary, subtitle: '+45 this week')),
              const SizedBox(width: AppSpacing.md),
              const Expanded(child: StatCard(title: 'Revenue', value: '₹45,200', icon: Icons.attach_money, color: AppColors.accent, subtitle: '+₹5,200 this month')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'Content Approval Queue (${pendingContent.length} pending)', actionText: 'Review All'),
          if (pendingContent.isEmpty)
            const EmptyState(icon: Icons.check_circle, title: 'No pending content')
          else
            ...pendingContent.map((c) => _PendingContentItem(content: c)).toList(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppCards.standard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Earning SMEs', style: AppTextStyles.headline3),
                      const SizedBox(height: AppSpacing.md),
                      _SMERankingItem(rank: 1, name: 'SME Teacher', earnings: '₹2,060'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppCards.standard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Activity', style: AppTextStyles.headline3),
                      const SizedBox(height: AppSpacing.md),
                      _ActivityItem(icon: Icons.upload_file, text: 'SME submitted new content', time: '2 hours ago'),
                      _ActivityItem(icon: Icons.check_circle, text: 'Content approved', time: '5 hours ago'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingContentItem extends StatelessWidget {
  final Map<String, dynamic> content;

  const _PendingContentItem({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppCards.standard,
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.pending_actions, color: AppColors.warning, size: 20)),
        title: Text(content['title'] ?? '', style: AppTextStyles.subtitle2),
        subtitle: Text('Type: ${content['type']}', style: AppTextStyles.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.check_circle, color: AppColors.success), onPressed: () => _approveContent(context)),
            IconButton(icon: const Icon(Icons.cancel, color: AppColors.error), onPressed: () => _rejectContent(context)),
          ],
        ),
      ),
    );
  }

  void _approveContent(BuildContext context) {
    localStorage.updateContent(content['id'], {'status': 'approved', 'approvedAt': DateTime.now().toIso8601String()});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content approved!'), backgroundColor: AppColors.success));
  }

  void _rejectContent(BuildContext context) {
    localStorage.updateContent(content['id'], {'status': 'rejected'});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content rejected'), backgroundColor: AppColors.error));
  }
}

class _SMERankingItem extends StatelessWidget {
  final int rank;
  final String name;
  final String earnings;

  const _SMERankingItem({required this.rank, required this.name, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Row(children: [Container(width: 24, height: 24, decoration: BoxDecoration(color: rank <= 3 ? AppColors.smePrimary : AppColors.surfaceVariant, shape: BoxShape.circle), child: Center(child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(name, style: AppTextStyles.subtitle2)), Text(earnings, style: AppTextStyles.subtitle1.copyWith(color: AppColors.smePrimary))]));
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;

  const _ActivityItem({required this.icon, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Row(children: [Icon(icon, size: 18, color: AppColors.textSecondary), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(text, style: AppTextStyles.body2)), Text(time, style: AppTextStyles.caption)]));
  }
}

// ==================== CONTENT TAB ====================

class _ContentTab extends StatelessWidget {
  const _ContentTab();

  @override
  Widget build(BuildContext context) {
    final content = localStorage.getContent();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Content Management', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),
          if (content.isEmpty)
            const EmptyState(icon: Icons.folder_open, title: 'No content found')
          else
            ...content.map((c) => _ContentListItem(content: c)),
        ],
      ),
    );
  }
}

class _ContentListItem extends StatelessWidget {
  final Map<String, dynamic> content;

  const _ContentListItem({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppCards.standard,
      child: ListTile(
        title: Text(content['title'] ?? '', style: AppTextStyles.subtitle2),
        subtitle: Text('Type: ${content['type']}', style: AppTextStyles.caption),
        trailing: _buildStatusBadge(content['status'] ?? ''),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'approved': return StatusBadge.approved();
      case 'pending': return StatusBadge.pending();
      case 'rejected': return StatusBadge.rejected();
      default: return const SizedBox();
    }
  }
}

// ==================== SMEs TAB ====================

class _SMEsTab extends StatelessWidget {
  const _SMEsTab();

  @override
  Widget build(BuildContext context) {
    final smes = localStorage.users.values.where((u) => u['role'] == 'sme').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SME Management', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),
          if (smes.isEmpty)
            const EmptyState(icon: Icons.people, title: 'No SMEs found')
          else
            ...smes.map((sme) => _SMEItem(sme: sme)),
        ],
      ),
    );
  }
}

class _SMEItem extends StatelessWidget {
  final Map<String, dynamic> sme;

  const _SMEItem({required this.sme});

  @override
  Widget build(BuildContext context) {
    final wallet = localStorage.getSMEWallet(sme['uid']);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppCards.standard,
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: AppColors.smePrimary.withOpacity(0.1), child: Text(sme['name']?[0].toString().toUpperCase() ?? 'S', style: const TextStyle(color: AppColors.smePrimary, fontWeight: FontWeight.bold))),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sme['name'] ?? '', style: AppTextStyles.subtitle1), Text(sme['email'] ?? '', style: AppTextStyles.caption)])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${(wallet?['totalEarnings'] ?? 0).toStringAsFixed(0)}', style: AppTextStyles.subtitle1.copyWith(color: AppColors.smePrimary)), const Text('earnings', style: AppTextStyles.caption)]),
        ],
      ),
    );
  }
}

// ==================== REWARDS TAB ====================

class _RewardsTab extends StatelessWidget {
  const _RewardsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reward Configuration', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Rewards Enabled', style: AppTextStyles.subtitle1), Switch(value: true, onChanged: (_) {}, activeColor: AppColors.success)]),
                const Divider(),
                _RewardRow(label: 'Mock Test', amount: '₹500'),
                _RewardRow(label: 'Entrance Exam', amount: '₹1,000'),
                _RewardRow(label: 'Study Notes', amount: '₹100'),
                _RewardRow(label: 'Current Affairs', amount: '₹50'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Usage-Based Rewards', style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.md),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Reward per user'), Text('₹10', style: AppTextStyles.subtitle1)]),
                const SizedBox(height: AppSpacing.sm),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Minimum users'), Text('100', style: AppTextStyles.subtitle1)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String label;
  final String amount;

  const _RewardRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.body1), Text(amount, style: AppTextStyles.subtitle1)]));
  }
}