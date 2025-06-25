import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../models/question.dart';

class WrongQuestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final wrongQuestions = quizProvider.wrongQuestions;

    return Scaffold(
      appBar: AppBar(title: Text('错题集')),
      body: ListView.builder(
        itemCount: wrongQuestions.length,
        itemBuilder: (context, index) {
          final question = wrongQuestions[index];
          return ListTile(
            title: Text(question.content),
            subtitle: Text('正确答案: ${question.correctAnswer}'),
            onTap: () {
              // 重做逻辑：跳转到刷题界面并加载该题目
              quizProvider.setRandomMode(false);
              Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen()));
            },
          );
        },
      ),
    );
  }
}