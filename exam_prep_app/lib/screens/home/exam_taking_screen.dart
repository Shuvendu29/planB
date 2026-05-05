import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../models/exam_result_model.dart';
import '../../models/entrance_exam_model.dart';
import 'question_review_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  final EntranceExamModel exam;

  const ExamTakingScreen({super.key, required this.exam});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final Map<String, int> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isSubmitted = false;
  int _score = 0;
  DateTime _startTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.exam.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${_currentQuestionIndex + 1}/${widget.exam.questions.length}'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.exam.questions.length,
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1}:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion.questionText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _answers[currentQuestion.id] == index;

                    return RadioListTile<int>(
                      title: Text(option),
                      value: index,
                      groupValue: _answers[currentQuestion.id],
                      onChanged: _isSubmitted ? null : (value) {
                        setState(() {
                          _answers[currentQuestion.id!] = value!;
                        });
                      },
                      selected: isSelected,
                    );
                  }),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                  child: const Text('Previous'),
                ),
                if (_currentQuestionIndex == widget.exam.questions.length - 1)
                  ElevatedButton(
                    onPressed: _isSubmitted ? null : _submitExam,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Submit Exam'),
                  )
                else
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.exam.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitExam() async {
    // Calculate score
    _score = 0;
    for (var question in widget.exam.questions) {
      if (_answers[question.id] == question.correctAnswerIndex) {
        _score++;
      }
    }

    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime).inMinutes;

    // Submit result
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final result = ExamResultModel(
        id: '',
        userId: authProvider.currentUser!.uid,
        userName: userProvider.user?.name ?? 'Anonymous',
        examId: widget.exam.id,
        examTitle: widget.exam.title,
        score: _score,
        totalQuestions: widget.exam.questions.length,
        timeTakenMinutes: timeTaken,
        completedAt: endTime,
        examType: 'entrance_exam',
        category: widget.exam.categoryId,
      );

      await leaderboardProvider.submitExamResult(result);
    }

    setState(() {
      _isSubmitted = true;
    });

    // Show results and option to review
    _showResultsDialog();
  }

  void _showResultsDialog() {
    final percentage = (_score / widget.exam.questions.length) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exam Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $_score/${widget.exam.questions.length}'),
            Text('Percentage: ${percentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('Would you like to review the questions?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Finish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuestionReviewScreen(
                    exam: widget.exam,
                    userAnswers: _answers,
                  ),
                ),
              );
            },
            child: const Text('Review Questions'),
          ),
        ],
      ),
    );
  }
}