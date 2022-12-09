import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/quiz_provider.dart';

class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context);

    final question = provider.questions[provider.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        centerTitle: true,
        elevation: 2,
      ),

      body: Column(
        children: [
          Text("Time: ${provider.timeLeft}s"),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(question.question,
                style: TextStyle(fontSize: 18)),
          ),

          ...List.generate(question.options.length, (index) {
            return ElevatedButton(
              onPressed: () => provider.answer(index),
              child: Text(question.options[index]),
            );
          }),

          Text("Score: ${provider.score}")
        ],
      ),
    );
  }
}