import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/entrance_exam_provider.dart';
import '../../models/entrance_exam_model.dart';
import '../../widgets/common_widgets.dart';
import '../home/leaderboard_screen.dart';
import '../home/exam_taking_screen.dart';

/// User Home Screen - Main entry point for regular users
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<UserProvider>(context, listen: false).loadUser(authProvider.currentUser!.uid);
      Provider.of<EntranceExamProvider>(context, listen: false).loadEntranceExams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          _ExamsTab(),
          _ResultsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', isSelected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0)),
                _NavItem(icon: Icons.school_rounded, label: 'Exams', isSelected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1)),
                _NavItem(icon: Icons.analytics_rounded, label: 'Results', isSelected: _selectedIndex == 2, onTap: () => setState(() => _selectedIndex = 2)),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', isSelected: _selectedIndex == 3, onTap: () => setState(() => _selectedIndex = 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textHint, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textHint,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME TAB ====================

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text('Exam Prep App', style: AppTextStyles.headline3),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {},
            ),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      (userProvider.user?.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Card
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return PointsCard(
                    points: userProvider.user?.points ?? 0,
                    onTopUp: () => _showTopUpDialog(context),
                  );
                },
              ),

              // Quick Actions
              const SectionHeader(title: 'Quick Actions'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    QuickActionButton(
                      icon: Icons.quiz_rounded,
                      label: 'Mock Tests',
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                    QuickActionButton(
                      icon: Icons.newspaper_rounded,
                      label: 'Current\nAffairs',
                      color: AppColors.secondary,
                      onTap: () {},
                    ),
                    QuickActionButton(
                      icon: Icons.menu_book_rounded,
                      label: 'Syllabus',
                      color: AppColors.accent,
                      onTap: () {},
                    ),
                    QuickActionButton(
                      icon: Icons.calendar_today_rounded,
                      label: 'Schedule',
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Recommended Exams
              const SectionHeader(title: 'Recommended Exams', actionText: 'See All'),
              _RecommendedExamsList(),

              const SizedBox(height: AppSpacing.lg),

              // Leaderboard Preview
              const SectionHeader(title: 'Today\'s Toppers', actionText: 'View All'),
              _LeaderboardPreview(),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }

  void _showTopUpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TopUpSheet(),
    );
  }
}

class _RecommendedExamsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EntranceExamProvider>(
      builder: (context, examProvider, _) {
        if (examProvider.isLoading) {
          return const SizedBox(height: 120, child: AppLoader());
        }

        final exams = examProvider.entranceExams.take(3).toList();
        if (exams.isEmpty) {
          return const SizedBox(
            height: 120,
            child: EmptyState(icon: Icons.school_outlined, title: 'No exams available'),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return _ExamCard(exam: exam);
            },
          ),
        );
      },
    );
  }
}

class _ExamCard extends StatelessWidget {
  final EntranceExamModel exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppCards.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(exam.title, style: AppTextStyles.subtitle1, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Spacer(),
          Text('${exam.questions.length} Questions • ${exam.timeInMinutes} min', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${exam.pointsRequired} Points', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamTakingScreen(exam: exam))),
                style: AppButtons.primary.copyWith(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Start', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppCards.standard,
      child: Column(
        children: [
          _LeaderboardItem(rank: 1, name: 'Rahul Sharma', points: 1250, avatarColor: AppColors.accent),
          const Divider(height: 1),
          _LeaderboardItem(rank: 2, name: 'Priya Mehta', points: 1180, avatarColor: AppColors.textHint),
          const Divider(height: 1),
          _LeaderboardItem(rank: 3, name: 'Amit Kumar', points: 1100, avatarColor: Colors.brown),
        ],
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final Color avatarColor;

  const _LeaderboardItem({required this.rank, required this.name, required this.points, required this.avatarColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.accent : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? const Icon(Icons.emoji_events, color: Colors.white, size: 16)
                  : Text('$rank', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(radius: 16, backgroundColor: avatarColor.withOpacity(0.2), child: Text(name[0], style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 12))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(name, style: AppTextStyles.subtitle2)),
          Text('$points pts', style: AppTextStyles.subtitle1.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

// ==================== EXAMS TAB ====================

class _ExamsTab extends StatelessWidget {
  const _ExamsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          title: const Text('Browse Exams', style: AppTextStyles.headline3),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                decoration: AppInputs.searchField(hint: 'Search exams...'),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _FilterChip(label: 'All', isSelected: true),
                _FilterChip(label: 'JEE'),
                _FilterChip(label: 'NEET'),
                _FilterChip(label: 'UPSC'),
                _FilterChip(label: 'State'),
                _FilterChip(label: 'More +', isOutlined: true),
              ],
            ),
          ),
        ),
        Consumer<EntranceExamProvider>(
          builder: (context, examProvider, _) {
            if (examProvider.isLoading) {
              return const SliverFillRemaining(child: AppLoader());
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exam = examProvider.entranceExams[index];
                  return _ExamListTile(exam: exam);
                },
                childCount: examProvider.entranceExams.length,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isOutlined;

  const _FilterChip({required this.label, this.isSelected = false, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent),
        ),
      ),
    );
  }
}

class _ExamListTile extends StatelessWidget {
  final EntranceExamModel exam;

  const _ExamListTile({required this.exam});

  @override
  Widget build(BuildContext context) {
    return ContentListTile(
      title: exam.title,
      subtitle: '${exam.questions.length} Questions • ${exam.timeInMinutes} min',
      leadingIcon: Icons.school,
      leadingColor: AppColors.primary,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${exam.pointsRequired}', style: AppTextStyles.subtitle1.copyWith(color: AppColors.accent)),
          const Text('points', style: AppTextStyles.caption),
        ],
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamTakingScreen(exam: exam))),
    );
  }
}

// ==================== RESULTS TAB ====================

class _ResultsTab extends StatelessWidget {
  const _ResultsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          title: Text('My Results', style: AppTextStyles.headline3),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppCards.standard,
            child: Column(
              children: [
                const Text('Overall Performance', style: AppTextStyles.subtitle2),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.78,
                        strokeWidth: 12,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('78%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Correct', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Questions', value: '70/90'),
                    _StatItem(label: 'Time', value: '165 min'),
                    _StatItem(label: 'Exams', value: '45'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Recent Results'),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _ResultCard(
              examName: 'JEE Main 2025',
              date: 'Jan 15, 2025',
              score: '78%',
              correct: '70/90',
            ),
            childCount: 5,
          ),
        ),
      ],
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

class _ResultCard extends StatelessWidget {
  final String examName;
  final String date;
  final String score;
  final String correct;

  const _ResultCard({required this.examName, required this.date, required this.score, required this.correct});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.secondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(examName, style: AppTextStyles.subtitle1),
                  Text(date, style: AppTextStyles.caption),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(score, style: AppTextStyles.headline3.copyWith(color: AppColors.secondary)),
                Text(correct, style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PROFILE TAB ====================

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.surface,
              title: const Text('My Profile', style: AppTextStyles.headline3),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (user?.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(user?.name ?? 'User', style: AppTextStyles.headline2),
                  Text(user?.email ?? '', style: AppTextStyles.body2),
                  const SizedBox(height: AppSpacing.lg),

                  // Points Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: AppCards.gradient(AppColors.primary),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.stars, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Points Balance', style: AppTextStyles.caption),
                              Text('${user?.points ?? 0}', style: AppTextStyles.headline2.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showTopUpDialog(context),
                          style: AppButtons.primary,
                          child: const Text('Top Up'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(child: _ProfileStatCard(icon: Icons.school, label: 'Exams', value: '45')),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: _ProfileStatCard(icon: Icons.check_circle, label: 'Correct', value: '78%')),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: _ProfileStatCard(icon: Icons.local_fire_department, label: 'Streak', value: '12')),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Menu Items
                  _ProfileMenuItem(icon: Icons.receipt_long, title: 'Transaction History', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.lock, title: 'Change Password', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.notifications, title: 'Notification Settings', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.help, title: 'Help & Support', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.logout, title: 'Log Out', isDestructive: true, onTap: () async {
                    await Provider.of<AuthProvider>(context, listen: false).signOut();
                    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                  }),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTopUpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TopUpSheet(),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppCards.standard,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.headline3),
          Text(label, style: AppTextStyles.caption),
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
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.body1.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

// ==================== TOP-UP SHEET ====================

class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet();

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  int? _selectedAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('💰 Top Up', style: AppTextStyles.headline2),
          const SizedBox(height: AppSpacing.lg),
          const Text('Select Amount', style: AppTextStyles.subtitle2),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _AmountChip(amount: 100, bonus: 5, isSelected: _selectedAmount == 100, onTap: () => setState(() => _selectedAmount = 100)),
              _AmountChip(amount: 500, bonus: 25, isSelected: _selectedAmount == 500, onTap: () => setState(() => _selectedAmount = 500)),
              _AmountChip(amount: 1000, bonus: 50, isSelected: _selectedAmount == 1000, onTap: () => setState(() => _selectedAmount = 1000)),
              _AmountChip(amount: 2000, bonus: 100, isSelected: _selectedAmount == 2000, onTap: () => setState(() => _selectedAmount = 2000)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.celebration, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('First time? Get 5% extra! 🎉', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Payment Method', style: AppTextStyles.subtitle2),
          const SizedBox(height: AppSpacing.sm),
          _PaymentOption(icon: Icons.account_balance_wallet, label: 'UPI / Google Pay'),
          _PaymentOption(icon: Icons.credit_card, label: 'Credit / Debit Card'),
          _PaymentOption(icon: Icons.account_balance, label: 'Net Banking'),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAmount != null ? () => _processTopUp(context) : null,
              style: AppButtons.primary,
              child: Text('Pay ₹${_selectedAmount ?? 0} Now'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _processTopUp(BuildContext context) {
    if (_selectedAmount != null) {
      Provider.of<UserProvider>(context, listen: false).topUp(_selectedAmount!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Points added successfully!'), backgroundColor: AppColors.success),
      );
    }
  }
}

class _AmountChip extends StatelessWidget {
  final int amount;
  final int bonus;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountChip({required this.amount, required this.bonus, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
        ),
        child: Column(
          children: [
            Text('₹$amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
            Text('+$bonus pts', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PaymentOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.body1),
      trailing: Radio<bool>(value: true, groupValue: false, onChanged: (_) {}),
      contentPadding: EdgeInsets.zero,
    );
  }
}