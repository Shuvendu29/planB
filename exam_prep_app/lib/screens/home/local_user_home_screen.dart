import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/local_auth_provider.dart';
import '../../providers/local_user_provider.dart';
import '../../providers/local_exam_provider.dart';
import '../../widgets/common_widgets.dart';
import 'local_exam_screen.dart';

/// User Home Screen - Local version for testing
class LocalUserHomeScreen extends StatefulWidget {
  const LocalUserHomeScreen({super.key});

  @override
  State<LocalUserHomeScreen> createState() => _LocalUserHomeScreenState();
}

class _LocalUserHomeScreenState extends State<LocalUserHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<LocalAuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<LocalUserProvider>(context, listen: false).loadCurrentUser();
      Provider.of<LocalEntranceExamProvider>(context, listen: false).loadExams();
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
              color: Colors.black.withValues(alpha: 0.1),
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
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
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
            Consumer<LocalUserProvider>(
              builder: (context, userProvider, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      (userProvider.user?['name'] ?? 'U')[0].toString().toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Card
              Consumer<LocalUserProvider>(
                builder: (context, userProvider, _) {
                  return PointsCard(
                    points: userProvider.points,
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
                    QuickActionButton(icon: Icons.quiz_rounded, label: 'Mock Tests', color: AppColors.primary, onTap: () {}),
                    QuickActionButton(icon: Icons.newspaper_rounded, label: 'Current\nAffairs', color: AppColors.secondary, onTap: () {}),
                    QuickActionButton(icon: Icons.menu_book_rounded, label: 'Syllabus', color: AppColors.accent, onTap: () {}),
                    QuickActionButton(icon: Icons.calendar_today_rounded, label: 'Schedule', color: Colors.purple, onTap: () {}),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Recommended Exams
              const SectionHeader(title: 'Available Exams', actionText: 'See All'),
              _RecommendedExamsList(),

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
    return Consumer<LocalEntranceExamProvider>(
      builder: (context, examProvider, _) {
        if (examProvider.isLoading) {
          return const SizedBox(height: 120, child: AppLoader());
        }

        final exams = examProvider.exams.take(3).toList();
        if (exams.isEmpty) {
          return const SizedBox(height: 120, child: EmptyState(icon: Icons.school_outlined, title: 'No exams available'));
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
  final Map<String, dynamic> exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final questions = exam['questions'] as List? ?? [];
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
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.school, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(exam['title'] ?? '', style: AppTextStyles.subtitle1, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Spacer(),
          Text('${questions.length} Questions • ${exam['timeInMinutes']} min', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('${exam['pointsRequired']} Points', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LocalExamScreen(exam: exam))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ==================== EXAMS TAB ====================

class _ExamsTab extends StatelessWidget {
  const _ExamsTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          backgroundColor: AppColors.surface,
          title: Text('Browse Exams', style: AppTextStyles.headline3),
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
              ],
            ),
          ),
        ),
        Consumer<LocalEntranceExamProvider>(
          builder: (context, examProvider, _) {
            if (examProvider.isLoading) {
              return const SliverFillRemaining(child: AppLoader());
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exam = examProvider.exams[index];
                  return _ExamListTile(exam: exam);
                },
                childCount: examProvider.exams.length,
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
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent)),
      ),
    );
  }
}

class _ExamListTile extends StatelessWidget {
  final Map<String, dynamic> exam;

  const _ExamListTile({required this.exam});

  @override
  Widget build(BuildContext context) {
    final questions = exam['questions'] as List? ?? [];
    return ContentListTile(
      title: exam['title'] ?? '',
      subtitle: '${questions.length} Questions • ${exam['timeInMinutes']} min',
      leadingIcon: Icons.school,
      leadingColor: AppColors.primary,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${exam['pointsRequired']}', style: AppTextStyles.subtitle1.copyWith(color: AppColors.accent)),
          const Text('points', style: AppTextStyles.caption),
        ],
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LocalExamScreen(exam: exam))),
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
                      CircularProgressIndicator(value: 0.78, strokeWidth: 12, backgroundColor: AppColors.surfaceVariant, valueColor: const AlwaysStoppedAnimation(AppColors.secondary)),
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
        const SliverToBoxAdapter(child: SectionHeader(title: 'Recent Results')),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _ResultCard(examName: 'JEE Main 2025', date: 'Jan 15, 2025', score: '78%', correct: '70/90'),
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
    return Column(children: [Text(value, style: AppTextStyles.headline3), Text(label, style: AppTextStyles.caption)]);
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
            Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.check_circle, color: AppColors.secondary)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(examName, style: AppTextStyles.subtitle1), Text(date, style: AppTextStyles.caption)]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(score, style: AppTextStyles.headline3.copyWith(color: AppColors.secondary)), Text(correct, style: AppTextStyles.caption)]),
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
    return Consumer<LocalUserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return CustomScrollView(
          slivers: [
            const SliverAppBar(floating: true, backgroundColor: AppColors.surface, title: Text('My Profile', style: AppTextStyles.headline3)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Center(child: Text((user?['name'] ?? 'U')[0].toString().toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(user?['name'] ?? 'User', style: AppTextStyles.headline2),
                  Text(user?['email'] ?? '', style: AppTextStyles.body2),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: AppCards.gradient(AppColors.primary),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.stars, color: AppColors.primary, size: 28)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Points Balance', style: AppTextStyles.caption), Text('${userProvider.points}', style: AppTextStyles.headline2.copyWith(color: AppColors.primary))])),
                        ElevatedButton(onPressed: () => _showTopUpDialog(context), style: AppButtons.primary, child: const Text('Top Up')),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                  _ProfileMenuItem(icon: Icons.receipt_long, title: 'Transaction History', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.lock, title: 'Change Password', onTap: () {}),
                  _ProfileMenuItem(icon: Icons.logout, title: 'Log Out', isDestructive: true, onTap: () async {
                    await Provider.of<LocalAuthProvider>(context, listen: false).signOut();
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
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const _TopUpSheet());
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: AppCards.standard, child: Column(children: [Icon(icon, color: AppColors.primary), const SizedBox(height: AppSpacing.sm), Text(value, style: AppTextStyles.headline3), Text(label, style: AppTextStyles.caption)]));
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
    return ListTile(leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary), title: Text(title, style: AppTextStyles.body1.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary)), trailing: const Icon(Icons.chevron_right, color: AppColors.textHint), onTap: onTap);
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
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
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
          Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.celebration, color: AppColors.accent), SizedBox(width: AppSpacing.sm), Expanded(child: Text('First time? Get 5% extra! 🎉', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)))])),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _selectedAmount != null ? () => _processTopUp(context) : null, style: AppButtons.primary, child: Text('Pay ₹${_selectedAmount ?? 0} Now'))),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _processTopUp(BuildContext context) {
    if (_selectedAmount != null) {
      Provider.of<LocalUserProvider>(context, listen: false).topUp(_selectedAmount!);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Points added successfully!'), backgroundColor: AppColors.success));
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
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent)),
        child: Column(children: [Text('₹$amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)), Text('+$bonus pts', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : AppColors.textSecondary))]),
      ),
    );
  }
}