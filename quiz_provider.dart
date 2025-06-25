import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/database_helper.dart';
import '../utils/file_parser.dart';
import 'dart:math';

class QuizProvider with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _wrongQuestions = [];
  int _currentIndex = 0;
  bool _isRandomMode = false;

  List<Question> get questions => _questions;
  List<Question> get wrongQuestions => _wrongQuestions;
  int get currentIndex => _currentIndex;
  bool get isRandomMode => _isRandomMode;

  Future<void> loadQuestions(String type) async {
    _questions = await FileParser.uploadFile(type);
    for (var question in _questions) {
      await DatabaseHelper.instance.insertQuestion(question);
    }
    _questions = await DatabaseHelper.instance.getQuestions();
    notifyListeners();
  }

  Future<void> loadWrongQuestions() async {
    _wrongQuestions = await DatabaseHelper.instance.getWrongQuestions();
    notifyListeners();
  }

  void setRandomMode(bool value) {
    _isRandomMode = value;
    notifyListeners();
  }

  Question getCurrentQuestion() {
    if (_isRandomMode) {
      return _questions[Random().nextInt(_questions.length)];
    }
    return _questions[_currentIndex];
  }

  void nextQuestion() {
    if (!_isRandomMode && _currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void submitAnswer(int questionId, String userAnswer) async {
    final question = _questions.firstWhere((q) => q.id == questionId);
    final isCorrect = question.correctAnswer == userAnswer;
    question.isCorrect = isCorrect;
    await DatabaseHelper.instance.updateQuestion(question);
    await DatabaseHelper.instance.insertAnswer(Answer(questionId: questionId, userAnswer: userAnswer));
    if (!isCorrect) {
      await loadWrongQuestions();
    }
    nextQuestion();
  }
}