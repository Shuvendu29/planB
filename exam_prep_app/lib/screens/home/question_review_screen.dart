import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/entrance_exam_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/question_review_model.dart';
import '../../models/entrance_exam_model.dart';

class QuestionReviewScreen extends StatefulWidget {
  final EntranceExamModel exam;
  final Map<String, int> userAnswers; // questionId -> selectedAnswerIndex

  const QuestionReviewScreen({
    super.key,
    required this.exam,
    required this.userAnswers,
  });

  @override
  State<QuestionReviewScreen> createState() => _QuestionReviewScreenState();
}

class _QuestionReviewScreenState extends State<QuestionReviewScreen> {
  final Map<String, String> _difficulties = {};
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with default difficulty
    for (var question in widget.exam.questions) {
      _difficulties[question.id] = 'moderate';
      _commentControllers[question.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Questions'),
        actions: [
          TextButton(
            onPressed: _submitReviews,
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.exam.questions.length,
        itemBuilder: (context, index) {
          final question = widget.exam.questions[index];
          final userAnswer = widget.userAnswers[question.id];
          final isCorrect = userAnswer == question.correctAnswerIndex;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Text(
                    'Question ${index + 1}: ${question.questionText}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Options with user's answer highlighted
                  ...question.options.asMap().entries.map((entry) {
                    final optionIndex = entry.key;
                    final optionText = entry.value;
                    final isUserAnswer = userAnswer == optionIndex;
                    final isCorrectAnswer = optionIndex == question.correctAnswerIndex;

                    Color? backgroundColor;
                    if (isCorrectAnswer) {
                      backgroundColor = Colors.green.shade100;
                    } else if (isUserAnswer && !isCorrect) {
                      backgroundColor = Colors.red.shade100;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Text('${String.fromCharCode(65 + optionIndex)}. '),
                          Expanded(child: Text(optionText)),
                          if (isUserAnswer) const Icon(Icons.check_circle, color: Colors.blue),
                          if (isCorrectAnswer) const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Explanation
                  if (question.explanation.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Explanation: ${question.explanation}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Difficulty rating
                  const Text(
                    'How difficult was this question?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _difficulties[question.id],
                    items: ['easy', 'moderate', 'tough', 'hard'].map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _difficulties[question.id] = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  // Comment (optional)
                  TextField(
                    controller: _commentControllers[question.id],
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitReviews() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<EntranceExamProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    try {
      // Submit review for each question
      for (var question in widget.exam.questions) {
        final review = QuestionReviewModel(
          id: '', // Firestore will generate
          userId: authProvider.currentUser!.uid,
          examId: widget.exam.id,
          questionId: question.id,
          difficulty: _difficulties[question.id]!,
          comment: _commentControllers[question.id]?.text.isNotEmpty == true
              ? _commentControllers[question.id]!.text
              : null,
          reviewedAt: DateTime.now(),
        );

        await examProvider.submitQuestionReview(review);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviews submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting reviews: $e')),
      );
    }
  }
}