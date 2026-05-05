import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reward_provider.dart';
import '../../models/content_model.dart';
import '../../widgets/common_widgets.dart';

/// Admin Dashboard - Web-optimized interface for system management
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    Provider.of<RewardProvider>(context, listen: false).loadRewardConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2), // Admin background
      body: Row(
        children: [
          // Sidebar
          _AdminSidebar(selectedIndex: _selectedNavIndex, onTap: (index) => setState(() => _selectedNavIndex = index)),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _AdminTopBar(),

                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedNavIndex) {
      case 0:
        return const _OverviewTab();
      case 1:
        return const _ContentManagementTab();
      case 2:
        return const _SMEManagementTab();
      case 3:
        return const _RewardConfigTab();
      case 4:
        return const _AnalyticsTab();
      default:
        return const _OverviewTab();
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
          // Logo
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.adminGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text('Admin Panel', style: AppTextStyles.headline3),
              ],
            ),
          ),

          const Divider(height: 1),

          // Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _SidebarItem(icon: Icons.dashboard, label: 'Overview', isSelected: selectedIndex == 0, onTap: () => onTap(0), color: AppColors.adminPrimary),
                _SidebarItem(icon: Icons.folder_copy, label: 'Content', isSelected: selectedIndex == 1, onTap: () => onTap(1), color: AppColors.adminPrimary),
                _SidebarItem(icon: Icons.people, label: 'SMEs', isSelected: selectedIndex == 2, onTap: () => onTap(2), color: AppColors.adminPrimary),
                _SidebarItem(icon: Icons.card_giftcard, label: 'Rewards', isSelected: selectedIndex == 3, onTap: () => onTap(3), color: AppColors.adminPrimary),
                _SidebarItem(icon: Icons.analytics, label: 'Analytics', isSelected: selectedIndex == 4, onTap: () => onTap(4), color: AppColors.adminPrimary),
              ],
            ),
          ),

          // Settings & Logout
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings, color: AppColors.textSecondary),
                  title: const Text('Settings', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                  onTap: () async {
                    await Provider.of<AuthProvider>(context, listen: false).signOut();
                    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
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
  final Color color;

  const _SidebarItem({required this.icon, required this.label, required this.isSelected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (label == 'Content') ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(10)),
                child: const Text('12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
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
          Text('Welcome, Admin', style: AppTextStyles.headline3),
          const Spacer(),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.adminPrimary.withOpacity(0.1),
            child: const Icon(Icons.admin_panel_settings, color: AppColors.adminPrimary, size: 20),
          ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),

          // Stats Row
          Row(
            children: [
              Expanded(child: StatCard(title: 'Total Users', value: '12,450', icon: Icons.people, color: AppColors.primary, subtitle: '+124 this week')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: StatCard(title: 'Active SMEs', value: '156', icon: Icons.school, color: AppColors.smePrimary, subtitle: '+12 this month')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: StatCard(title: 'Total Content', value: '890', icon: Icons.folder, color: AppColors.secondary, subtitle: '+45 this week')),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: StatCard(title: 'Revenue', value: '₹45,200', icon: Icons.attach_money, color: AppColors.accent, subtitle: '+₹5,200 this month')),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Content Approval Queue
          const SectionHeader(title: 'Content Approval Queue (12 pending)', actionText: 'Review All'),
          _ContentApprovalList(),

          const SizedBox(height: AppSpacing.lg),

          // Bottom Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Performing Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppCards.standard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Performing Content', style: AppTextStyles.headline3),
                      const SizedBox(height: AppSpacing.md),
                      _TopContentItem(rank: 1, title: 'JEE Mock 2025', completions: 1234),
                      _TopContentItem(rank: 2, title: 'NEET UG 2025', completions: 987),
                      _TopContentItem(rank: 3, title: 'UPSC Prelims', completions: 654),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // SME Leaderboard
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppCards.standard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Earning SMEs', style: AppTextStyles.headline3),
                      const SizedBox(height: AppSpacing.md),
                      _SMERankingItem(rank: 1, name: 'Rahul Sharma', earnings: '₹12,450'),
                      _SMERankingItem(rank: 2, name: 'Priya Mehta', earnings: '₹10,200'),
                      _SMERankingItem(rank: 3, name: 'Amit Kumar', earnings: '₹8,900'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Recent Activity
          const SectionHeader(title: 'Recent System Activity'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Column(
              children: [
                _ActivityItem(icon: Icons.person_add, text: 'User john@email.com purchased 100 points', time: '2 min ago'),
                _ActivityItem(icon: Icons.upload_file, text: 'SME Rahul S. submitted new content', time: '15 min ago'),
                _ActivityItem(icon: Icons.warning, text: '3 content items flagged for review', time: '1 hour ago'),
                _ActivityItem(icon: Icons.check_circle, text: 'Admin approved 5 content items', time: '2 hours ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentApprovalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('content').where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(icon: Icons.check_circle, title: 'No pending content');
        }
        return Container(
          decoration: AppCards.standard,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length > 5 ? 5 : snapshot.data!.docs.length,
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
                  child: const Icon(Icons.pending_actions, color: AppColors.warning, size: 20),
                ),
                title: Text(content.title, style: AppTextStyles.subtitle2),
                subtitle: Text('Type: ${content.type} • Submitted: ${content.uploadedAt.toString().substring(0, 10)}', style: AppTextStyles.caption),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: AppColors.success),
                      onPressed: () => _approveContent(context, doc.id, content),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: AppColors.error),
                      onPressed: () => _rejectContent(context, doc.id),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _approveContent(BuildContext context, String docId, ContentModel content) async {
    await FirebaseFirestore.instance.collection('content').doc(docId).update({
      'status': 'approved',
      'approvedAt': Timestamp.now(),
      'approvedBy': Provider.of<AuthProvider>(context, listen: false).currentUser?.uid,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content approved!'), backgroundColor: AppColors.success));
    }
  }

  void _rejectContent(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('content').doc(docId).update({'status': 'rejected'});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content rejected'), backgroundColor: AppColors.error));
    }
  }
}

class _TopContentItem extends StatelessWidget {
  final int rank;
  final String title;
  final int completions;

  const _TopContentItem({required this.rank, required this.title, required this.completions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.accent : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? const Icon(Icons.emoji_events, color: Colors.white, size: 14)
                  : Text('$rank', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(title, style: AppTextStyles.subtitle2)),
          Text('$completions completions', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _SMERankingItem extends StatelessWidget {
  final int rank;
  final String name;
  final String earnings;

  const _SMERankingItem({required this.rank, required this.name, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.smePrimary : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(name, style: AppTextStyles.subtitle2)),
          Text(earnings, style: AppTextStyles.subtitle1.copyWith(color: AppColors.smePrimary)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;

  const _ActivityItem({required this.icon, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.body2)),
          Text(time, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ==================== CONTENT MANAGEMENT TAB ====================

class _ContentManagementTab extends StatelessWidget {
  const _ContentManagementTab();

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
              const Text('Content Management', style: AppTextStyles.headline1),
              Row(
                children: [
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.search, size: 18), label: const Text('Search')),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, size: 18), label: const Text('Filter')),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 18), label: const Text('Export')),
                ],
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
                _FilterChip(label: 'Pending'),
                _FilterChip(label: 'Approved'),
                _FilterChip(label: 'Rejected'),
                _FilterChip(label: 'Flagged'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Content Table
          _ContentTable(),

          const SizedBox(height: AppSpacing.lg),

          // Bulk Actions
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Row(
              children: [
                const Text('Bulk Actions:', style: AppTextStyles.subtitle2),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton(onPressed: () {}, style: AppButtons.success, child: const Text('Approve Selected')),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(onPressed: () {}, style: AppButtons.danger, child: const Text('Reject Selected')),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(onPressed: () {}, style: AppButtons.outline, child: const Text('Delete Selected')),
              ],
            ),
          ),
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
        selectedColor: AppColors.adminPrimary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.adminPrimary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.adminPrimary : Colors.transparent),
        ),
      ),
    );
  }
}

class _ContentTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('content').orderBy('uploadedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoader();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(icon: Icons.folder_open, title: 'No content found');
        }
        return Container(
          decoration: AppCards.standard,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
            columns: const [
              DataColumn(label: Text('Select')),
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('SME')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.docs.map((doc) {
              final content = ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              return DataRow(
                cells: [
                  DataCell(Checkbox(value: false, onChanged: (_) {})),
                  DataCell(Text(content.title, style: AppTextStyles.body2)),
                  DataCell(Text(content.type, style: AppTextStyles.body2)),
                  DataCell(Text(content.uploadedBy.substring(0, 8), style: AppTextStyles.caption)),
                  DataCell(_buildStatusBadge(content.status)),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete, size: 18, color: AppColors.error), onPressed: () {}),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        );
      },
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
}

// ==================== SME MANAGEMENT TAB ====================

class _SMEManagementTab extends StatelessWidget {
  const _SMEManagementTab();

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
              const Text('SME Management', style: AppTextStyles.headline1),
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add New SME'), style: AppButtons.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'Active'),
                _FilterChip(label: 'Pending KYC'),
                _FilterChip(label: 'Suspended'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // SME List
          _SMETable(),
        ],
      ),
    );
  }
}

class _SMETable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'sme').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoader();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(icon: Icons.people, title: 'No SMEs found');
        }
        return Container(
          decoration: AppCards.standard,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Content')),
              DataColumn(label: Text('Earnings')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: snapshot.data!.docs.map((doc) {
              final data = doc.data();
              return DataRow(
                cells: [
                  DataCell(Text(data['name'] ?? 'SME', style: AppTextStyles.body2)),
                  DataCell(Text(data['email'] ?? '', style: AppTextStyles.caption)),
                  DataCell(Text('${data['contentCount'] ?? 0}', style: AppTextStyles.body2)),
                  DataCell(Text('₹${data['earnings'] ?? 0}', style: AppTextStyles.body2)),
                  DataCell(StatusBadge.approved()),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.block, size: 18, color: AppColors.warning), onPressed: () {}),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ==================== REWARD CONFIG TAB ====================

class _RewardConfigTab extends StatelessWidget {
  const _RewardConfigTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reward Configuration', style: AppTextStyles.headline1),
          const SizedBox(height: AppSpacing.lg),

          // Global Settings
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rewards Enabled', style: AppTextStyles.subtitle1),
                    Text('Last Updated: Jan 15, 2025 by Admin', style: AppTextStyles.caption),
                  ],
                ),
                Switch(value: true, onChanged: (_) {}, activeColor: AppColors.success),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Approval Rewards
          const SectionHeader(title: 'Approval Rewards (per content type)'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Consumer<RewardProvider>(
              builder: (context, rewardProvider, _) {
                final config = rewardProvider.rewardConfig;
                return Column(
                  children: [
                    _RewardConfigRow(label: 'Mock Test', amount: config?.contentTypeRewards['mock_test']?.toInt() ?? 500, onChanged: (v) {}),
                    _RewardConfigRow(label: 'Entrance Exam', amount: config?.contentTypeRewards['entrance_exam']?.toInt() ?? 1000, onChanged: (v) {}),
                    _RewardConfigRow(label: 'Study Notes', amount: config?.contentTypeRewards['study_notes']?.toInt() ?? 100, onChanged: (v) {}),
                    _RewardConfigRow(label: 'Current Affairs', amount: config?.contentTypeRewards['current_affairs']?.toInt() ?? 50, onChanged: (v) {}),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Usage-Based Rewards
          const SectionHeader(title: 'Usage-Based Rewards'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reward per user completion', style: AppTextStyles.body1),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                      child: const Text('₹10', style: AppTextStyles.subtitle1),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Minimum users for reward', style: AppTextStyles.body1),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                      child: const Text('100', style: AppTextStyles.subtitle1),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.info, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Text('Example: If 200 users complete your content → You earn: ₹10 × 200 = ₹2,000', style: AppTextStyles.body2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Summary
          const SectionHeader(title: 'Reward Distribution Summary (This Month)'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Distributed', style: AppTextStyles.subtitle1),
                    Text('₹45,200', style: AppTextStyles.headline3),
                  ],
                ),
                const Divider(height: AppSpacing.lg),
                _SummaryRow(label: 'Approval Rewards', amount: '₹25,000 (55%)'),
                _SummaryRow(label: 'Usage Rewards', amount: '₹15,200 (34%)'),
                _SummaryRow(label: 'Bonuses', amount: '₹5,000 (11%)'),
                const Divider(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Top SME', style: AppTextStyles.caption),
                    Text('Rahul S. - ₹2,500', style: AppTextStyles.subtitle2),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Actions
          Row(
            children: [
              OutlinedButton(onPressed: () {}, style: AppButtons.outline, child: const Text('Reset to Defaults')),
              const Spacer(),
              ElevatedButton(onPressed: () {}, style: AppButtons.primary, child: const Text('Save Configuration')),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardConfigRow extends StatelessWidget {
  final String label;
  final int amount;
  final Function(int) onChanged;

  const _RewardConfigRow({required this.label, required this.amount, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body1),
          Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                child: Text('₹$amount', style: AppTextStyles.subtitle1),
              ),
              const SizedBox(width: AppSpacing.sm),
              Switch(value: true, onChanged: (_) {}, activeColor: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;

  const _SummaryRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body2),
          Text(amount, style: AppTextStyles.subtitle2),
        ],
      ),
    );
  }
}

// ==================== ANALYTICS TAB ====================

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

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
              const Text('Analytics & Reports', style: AppTextStyles.headline1),
              Row(
                children: [
                  DropdownButton<String>(
                    value: '30d',
                    items: const [
                      DropdownMenuItem(value: '7d', child: Text('Last 7 days')),
                      DropdownMenuItem(value: '30d', child: Text('Last 30 days')),
                      DropdownMenuItem(value: '90d', child: Text('Last 90 days')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 18), label: const Text('Export')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // User Activity Chart
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppCards.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User Activity (Last 30 days)', style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(30, (i) {
                      return Container(
                        width: 20,
                        height: 50 + (i % 5) * 30.0,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Daily Active Users', value: '1,234 avg'),
                    _StatItem(label: 'Total Exam Attempts', value: '45,678'),
                    _StatItem(label: 'Average Score', value: '72%'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Bottom Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Exams
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppCards.standard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Exams', style: AppTextStyles.headline3),
                      const SizedBox(height: AppSpacing.md),
                      _ExamStatItem(name: 'JEE Main', percentage: 45),
                      _ExamStatItem(name: 'NEET UG', percentage: 30),
                      _ExamStatItem(name: 'UPSC', percentage: 15),
                      _ExamStatItem(name: 'State Exams', percentage: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Demographics
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: AppCards.standard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('User Demographics', style: AppTextStyles.headline3),
                      const SizedBox(height: AppSpacing.md),
                      _DemoItem(age: '18-25', percentage: 45),
                      _DemoItem(age: '26-35', percentage: 35),
                      _DemoItem(age: '36+', percentage: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Revenue Analytics
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppCards.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Revenue Analytics', style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            const Text('Point Purchases', style: AppTextStyles.caption),
                            Text('₹35,000', style: AppTextStyles.headline3),
                            Text('70%', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            const Text('Premium Subs', style: AppTextStyles.caption),
                            Text('₹15,000', style: AppTextStyles.headline3),
                            Text('30%', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Revenue', style: AppTextStyles.subtitle1),
                    Text('₹50,000', style: AppTextStyles.headline2),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headline3),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _ExamStatItem extends StatelessWidget {
  final String name;
  final int percentage;

  const _ExamStatItem({required this.name, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(name, style: AppTextStyles.body2)),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('$percentage%', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _DemoItem extends StatelessWidget {
  final String age;
  final int percentage;

  const _DemoItem({required this.age, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(age, style: AppTextStyles.body2)),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.smePrimary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('$percentage%', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// Firebase import
import 'package:cloud_firestore/cloud_firestore.dart';