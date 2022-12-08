import 'package:flutter/material.dart';
import '../models/question_model.dart';
import 'dart:async';

class QuizProvider with ChangeNotifier {
  List<QuestionModel> questions = [
    QuestionModel(
      question: "What is Flutter?",
      options: ["SDK", "Language", "IDE", "Database"],
      correctIndex: 0,
    ),
    QuestionModel(
      question: "Which language is used in Flutter?",
      options: ["Java", "Kotlin", "Dart", "Python"],
      correctIndex: 2,
    ),
  ];

  int currentIndex = 0;
  int score = 0;
  int timeLeft = 30;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        timeLeft--;
      } else {
        nextQuestion();
      }
      notifyListeners();
    });
  }

  void answer(int index) {
    if (questions[currentIndex].correctIndex == index) {
      score++;
    }
    nextQuestion();
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      timeLeft = 30;
    } else {
      timer?.cancel();
    }
    notifyListeners();
  }
}