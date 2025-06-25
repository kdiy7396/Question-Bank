import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/question.dart';

class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final question = quizProvider.getCurrentQuestion();

    return Scaffold(
      appBar: AppBar(title: Text('刷题')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(question.content, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (question.type == 'multiple_choice') ...[
              ...question.options.map((option) => RadioListTile(
                    title: Text(option),
                    value: option,
                    groupValue: null,
                    onChanged: (value) {
                      quizProvider.submitAnswer(question.id, value!);
                    },
                  )),
            ] else ...[
              RadioListTile(
                title: Text('正确'),
                value: 'true',
                groupValue: null,
                onChanged: (value) {
                  quizProvider.submitAnswer(question.id, value!);
                },
              ),
              RadioListTile(
                title: Text('错误'),
                value: 'false',
                groupValue: null,
                onChanged: (value) {
                  quizProvider.submitAnswer(question.id, value!);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}