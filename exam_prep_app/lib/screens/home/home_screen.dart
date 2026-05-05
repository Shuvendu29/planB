import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/entrance_exam_provider.dart';
import '../../models/content_model.dart';
import '../../models/entrance_exam_model.dart';
import 'leaderboard_screen.dart';
import 'exam_taking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<UserProvider>(context, listen: false).loadUser(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Prep App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Points display
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Points: ${userProvider.user?.points ?? 0}'),
                ElevatedButton(
                  onPressed: () => _showTopUpDialog(context),
                  child: const Text('Top Up'),
                ),
              ],
            ),
          ),
          // Content list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('entrance_exams')
                  .where('status', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No entrance exams available'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title'] ?? ''),
                      subtitle: Text('${data['questions']?.length ?? 0} questions • ${data['timeInMinutes'] ?? 0} min'),
                      trailing: ElevatedButton(
                        onPressed: () => _attemptEntranceExam(context, doc.id, data),
                        child: const Text('Take Exam'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top Up Points'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount in Rs'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = int.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                await Provider.of<UserProvider>(context, listen: false).topUp(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Top Up'),
          ),
        ],
      ),
    );
  }

  void _attemptEntranceExam(BuildContext context, String examId, Map<String, dynamic> examData) async {
    try {
      // Load full exam data including questions
      final doc = await FirebaseFirestore.instance.collection('entrance_exams').doc(examId).get();
      if (doc.exists) {
        final exam = EntranceExamModel.fromMap(doc.data()!, doc.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamTakingScreen(exam: exam),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exam: $e')),
      );
    }
  }

  void _attemptTest(BuildContext context, ContentModel content) {
    // Placeholder for test logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting ${content.title}')),
    );
  }
}