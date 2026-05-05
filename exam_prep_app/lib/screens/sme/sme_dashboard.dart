import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/content_model.dart';
import 'entrance_exam_upload_screen.dart';

class SMEDashboard extends StatefulWidget {
  const SMEDashboard({super.key});

  @override
  State<SMEDashboard> createState() => _SMEDashboardState();
}

class _SMEDashboardState extends State<SMEDashboard> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'exam';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SME Dashboard'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Upload Content', style: TextStyle(fontSize: 20)),
            DropdownButton<String>(
              value: _selectedType,
              items: ['exam', 'mock_test', 'current_affairs', 'study_notes']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _uploadContent(authProvider.currentUser!.uid),
              child: const Text('Upload Content'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EntranceExamUploadScreen()),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Upload Entrance Exam'),
            ),
            const SizedBox(height: 20),
            const Text('Your Uploads', style: TextStyle(fontSize: 18)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('content')
                    .where('uploadedBy', isEqualTo: authProvider.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No uploads yet'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final content = ContentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                      return ListTile(
                        title: Text(content.title),
                        subtitle: Text('Status: ${content.status}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadContent(String uid) async {
    final content = ContentModel(
      id: '', // Firestore will generate
      type: _selectedType,
      title: _titleController.text,
      description: _descriptionController.text,
      fileUrls: [], // Placeholder, add file upload later
      uploadedBy: uid,
      uploadedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance.collection('content').add(content.toMap());

    _titleController.clear();
    _descriptionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content uploaded for review')),
    );
  }
}