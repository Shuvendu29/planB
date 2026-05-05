import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/exam_result_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedLimit = 10;
  String? _selectedExamType;
  String? _selectedCategory;
  int? _userRank;
  ExamResultModel? _userBestScore;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
    _loadUserStats();
  }

  Future<void> _loadLeaderboard() async {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
    await leaderboardProvider.loadLeaderboard(
      limit: _selectedLimit,
      examType: _selectedExamType,
      category: _selectedCategory,
    );
  }

  Future<void> _loadUserStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      _userRank = await leaderboardProvider.getUserRank(
        authProvider.currentUser!.uid,
        examType: _selectedExamType,
        category: _selectedCategory,
      );

      _userBestScore = await leaderboardProvider.getUserBestScore(
        authProvider.currentUser!.uid,
        examType: _selectedExamType,
        category: _selectedCategory,
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // User stats card
          if (_userRank != null || _userBestScore != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_userRank != null)
                      Text('Your Rank: #$_userRank'),
                    if (_userBestScore != null)
                      Text('Best Score: ${_userBestScore!.score}/${_userBestScore!.totalQuestions} (${_userBestScore!.percentage.toStringAsFixed(1)}%)'),
                  ],
                ),
              ),
            ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Show Top: '),
                DropdownButton<int>(
                  value: _selectedLimit,
                  items: [10, 20, 50, 100].map((limit) {
                    return DropdownMenuItem(
                      value: limit,
                      child: Text('$limit'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLimit = value!);
                    _loadLeaderboard();
                    _loadUserStats();
                  },
                ),
              ],
            ),
          ),

          // Leaderboard list
          Expanded(
            child: leaderboardProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : leaderboardProvider.error != null
                    ? Center(child: Text('Error: ${leaderboardProvider.error}'))
                    : leaderboardProvider.leaderboard.isEmpty
                        ? const Center(child: Text('No results found'))
                        : ListView.builder(
                            itemCount: leaderboardProvider.leaderboard.length,
                            itemBuilder: (context, index) {
                              final result = leaderboardProvider.leaderboard[index];
                              final isCurrentUser = result.userId == Provider.of<AuthProvider>(context).currentUser?.uid;

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                color: isCurrentUser ? Colors.blue.shade50 : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getRankColor(index + 1),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    result.userName,
                                    style: TextStyle(
                                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${result.examTitle}\n${result.score}/${result.totalQuestions} (${result.percentage.toStringAsFixed(1)}%) • ${result.timeTakenMinutes}min'
                                  ),
                                  trailing: Text(
                                    '${result.percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Exam type filter (placeholder - would need to load from provider)
            const Text('Exam Type: All'),
            const SizedBox(height: 8),
            // Category filter (placeholder - would need to load from provider)
            const Text('Category: All'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}