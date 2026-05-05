import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/content_model.dart';
import 'admin_exam_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
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
          // Admin action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminExamManagementScreen()),
                    ),
                    icon: const Icon(Icons.school),
                    label: const Text('Manage Exams'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content approval section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Pending Content Approvals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Content approval list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('content')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No pending content'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final content = ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(content.title),
                        subtitle: Text('${content.type} - ${content.description}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approveContent(doc.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _rejectContent(doc.id),
                            ),
                          ],
                        ),
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

  void _approveContent(String id) async {
    await FirebaseFirestore.instance.collection('content').doc(id).update({
      'status': 'approved',
      'approvedAt': Timestamp.now(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content approved')),
    );
  }

  void _rejectContent(String id) async {
    await FirebaseFirestore.instance.collection('content').doc(id).update({
      'status': 'rejected',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content rejected')),
    );
  }
}