import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'dart:async';

class QuizProvider with ChangeNotifier {
  List<QuestionModel> questions = [
    QuestionModel(
      question: 'What does OOP stand for?',
      options: ['Object-Oriented Programming', 'Order of Operations Protocol', 'Open Output Platform', 'None of these'],
      correctIndex: 0,
    ),
    QuestionModel(
      question: 'Which data structure uses LIFO order?',
      options: ['Queue', 'Stack', 'Heap', 'Tree'],
      correctIndex: 1,
    ),
    QuestionModel(
      question: 'What is the time complexity of binary search?',
      options: ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'],
      correctIndex: 2,
    ),
    QuestionModel(
      question: 'Which layer of OSI model handles routing?',
      options: ['Data Link', 'Transport', 'Network', 'Application'],
      correctIndex: 2,
    ),
    QuestionModel(
      question: 'What does SQL stand for?',
      options: ['Structured Query Language', 'Simple Queue Language', 'System Query Logic', 'Standard Query Library'],
      correctIndex: 0,
    ),
  ];

  int currentIndex = 0;
  int score        = 0;
  int timeLeft     = 30;
  bool isFinished  = false;
  Timer? _timer;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        timeLeft--;
      } else {
        nextQuestion();
      }
      notifyListeners();
    });
  }

  void answer(int index) {
    if (questions[currentIndex].correctIndex == index) score++;
    nextQuestion();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      timeLeft = 30;
    } else {
      _timer?.cancel();
      isFinished = true;
    }
    notifyListeners();
  }

  void resetQuiz() {
    _timer?.cancel();
    currentIndex = 0;
    score        = 0;
    timeLeft     = 30;
    isFinished   = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}