import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/local_user_provider.dart';
import '../../widgets/common_widgets.dart';

/// Local exam taking screen for testing
class LocalExamScreen extends StatefulWidget {
  final Map<String, dynamic> exam;

  const LocalExamScreen({super.key, required this.exam});

  @override
  State<LocalExamScreen> createState() => _LocalExamScreenState();
}

class _LocalExamScreenState extends State<LocalExamScreen> {
  final Map<String, int> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isSubmitted = false;
  int _score = 0;
  DateTime _startTime = DateTime.now();

  List<Map<String, dynamic>> get questions => List<Map<String, dynamic>>.from(widget.exam['questions'] ?? []);
  Map<String, dynamic> get currentQuestion => questions[_currentQuestionIndex];

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(widget.exam['title'] ?? 'Exam')), body: const EmptyState(icon: Icons.error, title: 'No questions in this exam'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam['title'] ?? 'Exam'),
        backgroundColor: AppColors.surface,
        actions: [
          Padding(padding: const EdgeInsets.all(16), child: Text('${_currentQuestionIndex + 1}/${questions.length}', style: AppTextStyles.subtitle1)),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(value: (_currentQuestionIndex + 1) / questions.length),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question ${_currentQuestionIndex + 1}:', style: AppTextStyles.headline3),
                  const SizedBox(height: AppSpacing.md),
                  Text(currentQuestion['questionText'] ?? '', style: AppTextStyles.body1),
                  const SizedBox(height: AppSpacing.lg),

                  // Options
                  ...List.generate(
                    (currentQuestion['options'] as List?)?.length ?? 0,
                    (index) {
                      final options = currentQuestion['options'] as List?;
                      final option = options?[index] ?? '';
                      final isSelected = _answers[currentQuestion['id']] == index;

                      return RadioListTile<int>(
                        title: Text(option, style: AppTextStyles.body1),
                        value: index,
                        groupValue: _answers[currentQuestion['id']],
                        onChanged: _isSubmitted ? null : (value) {
                          setState(() {
                            _answers[currentQuestion['id']] = value!;
                          });
                        },
                        selected: isSelected,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      );
                    },
                  ),

                  // Show correct answer after submission
                  if (_isSubmitted) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: _answers[currentQuestion['id']] == currentQuestion['correctAnswerIndex']
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _answers[currentQuestion['id']] == currentQuestion['correctAnswerIndex']
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _answers[currentQuestion['id']] == currentQuestion['correctAnswerIndex']
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _answers[currentQuestion['id']] == currentQuestion['correctAnswerIndex']
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _answers[currentQuestion['id']] == currentQuestion['correctAnswerIndex']
                                  ? 'Correct!'
                                  : 'Correct answer: ${currentQuestion['options'][currentQuestion['correctAnswerIndex']]}',
                              style: TextStyle(
                                color: _answers[currentQuestion['id']] == currentQuestion['correctAnswerIndex']
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Question Navigator
          if (!_isSubmitted)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surfaceVariant,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(questions.length, (index) {
                    final q = questions[index];
                    final isAnswered = _answers.containsKey(q['id']);
                    final isCurrent = index == _currentQuestionIndex;

                    return GestureDetector(
                      onTap: () => setState(() => _currentQuestionIndex = index),
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isCurrent ? AppColors.primary : (isAnswered ? AppColors.secondary : AppColors.surface),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isCurrent ? AppColors.primary : AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : (isAnswered ? Colors.white : AppColors.textSecondary),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? () => setState(() => _currentQuestionIndex--) : null,
                  style: AppButtons.outline,
                  child: const Text('Previous'),
                ),
                if (_currentQuestionIndex == questions.length - 1)
                  ElevatedButton(
                    onPressed: _isSubmitted ? null : _submitExam,
                    style: AppButtons.success,
                    child: const Text('Submit Exam'),
                  )
                else
                  ElevatedButton(
                    onPressed: () => setState(() => _currentQuestionIndex++),
                    style: AppButtons.primary,
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitExam() {
    // Calculate score
    _score = 0;
    for (var question in questions) {
      if (_answers[question['id']] == question['correctAnswerIndex']) {
        _score++;
      }
    }

    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime).inMinutes;

    setState(() {
      _isSubmitted = true;
    });

    // Show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResultDialog(
        examTitle: widget.exam['title'] ?? 'Exam',
        totalQuestions: questions.length,
        correctAnswers: _score,
        timeTaken: timeTaken,
        pointsRequired: widget.exam['pointsRequired'] ?? 0,
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final String examTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTaken;
  final int pointsRequired;

  const _ResultDialog({
    required this.examTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTaken,
    required this.pointsRequired,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;
  bool get passed => percentage >= 35;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: passed ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.emoji_events : Icons.refresh,
              color: passed ? AppColors.success : AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(passed ? 'Congratulations!' : 'Keep Trying!', style: AppTextStyles.headline2),
          const SizedBox(height: AppSpacing.sm),
          Text(examTitle, style: AppTextStyles.body2),
          const SizedBox(height: AppSpacing.lg),
          Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: passed ? AppColors.success : AppColors.error)),
          Text('$correctAnswers / $totalQuestions correct', style: AppTextStyles.body2),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ResultStat(label: 'Time', value: '$timeTaken min'),
              _ResultStat(label: 'Points', value: passed ? '+$pointsRequired' : '0'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to exam list
              },
              style: passed ? AppButtons.primary : AppButtons.outline,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;

  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: AppTextStyles.headline3), Text(label, style: AppTextStyles.caption)]);
  }
}