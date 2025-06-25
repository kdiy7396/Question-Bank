class Question {
  final int id;
  final String content; // 题目内容
  final List<String> options; // 选项（选择题）
  final String correctAnswer; // 正确答案
  final String type; // 题目类型：multiple_choice / true_false
  bool isCorrect; // 是否答对

  Question({
    required this.id,
    required this.content,
    this.options = const [],
    required this.correctAnswer,
    required this.type,
    this.isCorrect = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'options': options.join('|'),
      'correct_answer': correctAnswer,
      'type': type,
      'is_correct': isCorrect ? 1 : 0,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      content: map['content'],
      options: (map['options'] as String).split('|'),
      correctAnswer: map['correct_answer'],
      type: map['type'],
      isCorrect: map['is_correct'] == 1,
    );
  }
}

class Answer {
  final int questionId;
  final String userAnswer;

  Answer({required this.questionId, required this.userAnswer});

  Map<String, dynamic> toMap() {
    return {
      'question_id': questionId,
      'user_answer': userAnswer,
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      questionId: map['question_id'],
      userAnswer: map['user_answer'],
    );
  }
}
