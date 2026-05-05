import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/entrance_exam_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/exam_type_model.dart';
import '../../models/exam_category_model.dart';

class AdminExamManagementScreen extends StatefulWidget {
  const AdminExamManagementScreen({super.key});

  @override
  State<AdminExamManagementScreen> createState() => _AdminExamManagementScreenState();
}

class _AdminExamManagementScreenState extends State<AdminExamManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final examProvider = Provider.of<EntranceExamProvider>(context, listen: false);
    await examProvider.loadExamTypes();
    await examProvider.loadExamCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Exam Types'),
            Tab(text: 'Categories'),
            Tab(text: 'Pending Exams'),
            Tab(text: 'Reviews'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExamTypesTab(),
          _buildCategoriesTab(),
          _buildPendingExamsTab(),
          _buildReviewsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExamTypesTab() {
    final examProvider = Provider.of<EntranceExamProvider>(context);

    return ListView.builder(
      itemCount: examProvider.examTypes.length,
      itemBuilder: (context, index) {
        final examType = examProvider.examTypes[index];
        return ListTile(
          title: Text(examType.name),
          subtitle: Text(examType.description),
          trailing: Text(examType.isActive ? 'Active' : 'Inactive'),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    final examProvider = Provider.of<EntranceExamProvider>(context);

    return ListView.builder(
      itemCount: examProvider.examCategories.length,
      itemBuilder: (context, index) {
        final category = examProvider.examCategories[index];
        final examType = examProvider.examTypes.firstWhere(
          (type) => type.id == category.examTypeId,
          orElse: () => ExamTypeModel(id: '', name: 'Unknown', description: '', createdAt: DateTime.now(), createdBy: ''),
        );

        return ListTile(
          title: Text(category.name),
          subtitle: Text('${category.description}\nExam Type: ${examType.name}'),
          trailing: Text(category.isActive ? 'Active' : 'Inactive'),
        );
      },
    );
  }

  Widget _buildPendingExamsTab() {
    return FutureBuilder<List<dynamic>>(
      future: Provider.of<EntranceExamProvider>(context, listen: false).getPendingEntranceExams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No pending exams'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final exam = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(exam.title),
                subtitle: Text('${exam.questions.length} questions • ${exam.timeInMinutes} min'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _approveExam(exam.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _rejectExam(exam.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    // This would show question reviews that need admin attention
    return const Center(
      child: Text('Question reviews management coming soon'),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedExamTypeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(_tabController.index == 0 ? 'Add Exam Type' : 'Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              if (_tabController.index == 1) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedExamTypeId,
                  decoration: const InputDecoration(labelText: 'Exam Type'),
                  items: Provider.of<EntranceExamProvider>(context).examTypes.map((type) {
                    return DropdownMenuItem(
                      value: type.id,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedExamTypeId = value),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _addItem(nameController.text, descriptionController.text, selectedExamTypeId),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem(String name, String description, String? examTypeId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<EntranceExamProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    try {
      if (_tabController.index == 0) {
        // Add exam type
        final examType = ExamTypeModel(
          id: '',
          name: name,
          description: description,
          createdAt: DateTime.now(),
          createdBy: authProvider.currentUser!.uid,
        );
        await examProvider.addExamType(examType, authProvider.currentUser!.uid);
      } else {
        // Add category
        if (examTypeId == null) return;

        final category = ExamCategoryModel(
          id: '',
          name: name,
          description: description,
          examTypeId: examTypeId,
          createdAt: DateTime.now(),
          createdBy: authProvider.currentUser!.uid,
        );
        await examProvider.addExamCategory(category, authProvider.currentUser!.uid);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _approveExam(String examId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<EntranceExamProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    try {
      await examProvider.approveEntranceExam(examId, authProvider.currentUser!.uid);
      setState(() {}); // Refresh the tab
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam approved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rejectExam(String examId) async {
    final examProvider = Provider.of<EntranceExamProvider>(context, listen: false);

    try {
      await examProvider.rejectEntranceExam(examId);
      setState(() {}); // Refresh the tab
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam rejected!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}