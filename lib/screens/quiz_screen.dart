import 'dart:async';
import 'package:flutter/material.dart';
import '../models/course_model.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;

  Timer? _timer;
  int _timeLeft = 10;
  static const int questionDuration = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timeLeft = questionDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _submitAnswer(-1);
      }
    });
  }

  void _submitAnswer(int index) {
    if (_answered) return;

    _timer?.cancel();

    setState(() {
      _answered = true;
      if (index != -1 && index == widget.questions[_currentQuestion].correctIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestion < widget.questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _answered = false;
        });
        _startTimer();
      } else {
        _showScoreDialog();
      }
    });
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Complete!"),
        content: Text("You scored $_score / ${widget.questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Finish"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const SizedBox.shrink();

    final q = widget.questions[_currentQuestion];

    Color timerColor = Colors.green;
    if (_timeLeft <= 5) timerColor = Colors.orange;
    if (_timeLeft <= 3) timerColor = Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${_currentQuestion + 1}/${widget.questions.length}"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _timeLeft / questionDuration,
                  backgroundColor: Colors.grey.shade300,
                  color: timerColor,
                  strokeWidth: 8,
                ),
                Text(
                  "$_timeLeft",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: timerColor),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Question Text
            Text(
              q.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Options List
            Expanded(
              child: ListView.separated(
                itemCount: q.options.length,
                separatorBuilder: (c, i) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  Color cardColor = Colors.white;
                  Color textColor = Colors.black87;

                  if (_answered) {
                    if (index == q.correctIndex) {
                      cardColor = Colors.green.shade100;
                      textColor = Colors.green.shade900;
                    } else if (index != q.correctIndex && index == -1) {
                    } else {
                      cardColor = Colors.grey.shade200;
                    }
                  }

                  return Card(
                    color: cardColor,
                    elevation: _answered ? 0 : 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: _answered && index == q.correctIndex
                                ? Colors.green
                                : Colors.transparent,
                            width: 2
                        )
                    ),
                    child: ListTile(
                      title: Text(
                        q.options[index],
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                      ),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: const TextStyle(fontSize: 12, color: Colors.teal),
                        ),
                      ),
                      onTap: () => _submitAnswer(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}