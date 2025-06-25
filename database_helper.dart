import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/question.dart';
import '../models/answer.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY,
        content TEXT,
        options TEXT,
        correct_answer TEXT,
        type TEXT,
        is_correct INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER,
        user_answer TEXT,
        FOREIGN KEY (question_id) REFERENCES questions (id)
      )
    ''');
  }

  Future<void> insertQuestion(Question question) async {
    final db = await database;
    await db.insert('questions', question.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Question>> getQuestions() async {
    final db = await database;
    final maps = await db.query('questions');
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<List<Question>> getWrongQuestions() async {
    final db = await database;
    final maps = await db.query('questions', where: 'is_correct = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<void> insertAnswer(Answer answer) async {
    final db = await database;
    await db.insert('answers', answer.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateQuestion(Question question) async {
    final db = await database;
    await db.update('questions', question.toMap(), where: 'id = ?', whereArgs: [question.id]);
  }
}