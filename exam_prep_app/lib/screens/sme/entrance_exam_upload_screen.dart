import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/entrance_exam_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/entrance_exam_model.dart';
import '../../models/question_model.dart';

class EntranceExamUploadScreen extends StatefulWidget {
  const EntranceExamUploadScreen({super.key});

  @override
  State<EntranceExamUploadScreen> createState() => _EntranceExamUploadScreenState();
}

class _EntranceExamUploadScreenState extends State<EntranceExamUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _marksPerQuestionController = TextEditingController(text: '1');
  final _timeController = TextEditingController(text: '60');

  String? _selectedExamTypeId;
  String? _selectedCategoryId;
  bool _negativeMarking = false;
  List<QuestionModel> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final examProvider = Provider.of<EntranceExamProvider>(context, listen: false);
    await examProvider.loadExamTypes();
    await examProvider.loadExamCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _marksPerQuestionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<EntranceExamProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Entrance Exam'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Exam Details
              const Text(
                'Exam Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Exam Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Exam Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedExamTypeId,
                decoration: const InputDecoration(
                  labelText: 'Examination Type',
                  border: OutlineInputBorder(),
                ),
                items: examProvider.examTypes.map((type) {
                  return DropdownMenuItem(
                    value: type.id,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExamTypeId = value;
                    _selectedCategoryId = null; // Reset category when type changes
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _selectedExamTypeId != null
                    ? examProvider.getCategoriesForExamType(_selectedExamTypeId!).map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList()
                    : [],
                onChanged: _selectedExamTypeId != null ? (value) {
                  setState(() => _selectedCategoryId = value);
                } : null,
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Settings
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marksPerQuestionController,
                      decoration: const InputDecoration(
                        labelText: 'Marks per Question',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Negative Marking'),
                value: _negativeMarking,
                onChanged: (value) => setState(() => _negativeMarking = value ?? false),
              ),

              const SizedBox(height: 24),

              // Questions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Questions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Questions List
              if (_questions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No questions added yet. Click "Add Question" to start.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('Q${index + 1}: ${question.questionText}'),
                        subtitle: Text('${question.options.length} options'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editQuestion(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteQuestion(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _questions.isNotEmpty ? _submitExam : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Submit Exam for Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addQuestion() {
    _showQuestionDialog();
  }

  void _editQuestion(int index) {
    _showQuestionDialog(existingQuestion: _questions[index], index: index);
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _showQuestionDialog({QuestionModel? existingQuestion, int? index}) {
    final questionController = TextEditingController(text: existingQuestion?.questionText ?? '');
    final explanationController = TextEditingController(text: existingQuestion?.explanation ?? '');
    final optionControllers = List.generate(
      4,
      (i) => TextEditingController(text: existingQuestion != null && i < existingQuestion.options.length ? existingQuestion.options[i] : ''),
    );
    int correctAnswerIndex = existingQuestion?.correctAnswerIndex ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingQuestion != null ? 'Edit Question' : 'Add Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: correctAnswerIndex,
                        onChanged: (value) => setState(() => correctAnswerIndex = value!),
                      ),
                      Expanded(
                        child: TextField(
                          controller: optionControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Option ${String.fromCharCode(65 + i)}',
                            suffixIcon: correctAnswerIndex == i ? const Icon(Icons.check_circle, color: Colors.green) : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                TextField(
                  controller: explanationController,
                  decoration: const InputDecoration(labelText: 'Explanation (optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final question = QuestionModel(
                  id: existingQuestion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  questionText: questionController.text,
                  options: optionControllers.map((c) => c.text).toList(),
                  correctAnswerIndex: correctAnswerIndex,
                  explanation: explanationController.text,
                );

                setState(() {
                  if (index != null) {
                    _questions[index] = question;
                  } else {
                    _questions.add(question);
                  }
                });

                Navigator.pop(context);
                this.setState(() {}); // Update parent state
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitExam() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<EntranceExamProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    try {
      final exam = EntranceExamModel(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        examTypeId: _selectedExamTypeId!,
        categoryId: _selectedCategoryId!,
        negativeMarking: _negativeMarking,
        marksPerQuestion: double.parse(_marksPerQuestionController.text),
        timeInMinutes: int.parse(_timeController.text),
        questions: _questions,
        uploadedBy: authProvider.currentUser!.uid,
        uploadedAt: DateTime.now(),
      );

      await examProvider.submitEntranceExam(exam, authProvider.currentUser!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam submitted for review!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}