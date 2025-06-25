import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';
import 'wrong_questions_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('刷题App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await quizProvider.loadQuestions('excel');
              },
              child: Text('上传Excel题库'),
            ),
            ElevatedButton(
              onPressed: () async {
                await quizProvider.loadQuestions('word');
              },
              child: Text('上传Word题库'),
            ),
            ElevatedButton(
              onPressed: () {
                quizProvider.setRandomMode(false);
                Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen()));
              },
              child: Text('顺序刷题'),
            ),
            ElevatedButton(
              onPressed: () {
                quizProvider.setRandomMode(true);
                Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen()));
              },
              child: Text('随机刷题'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => WrongQuestionsScreen()));
              },
              child: Text('查看错题集'),
            ),
          ],
        ),
      ),
    );
  }
}