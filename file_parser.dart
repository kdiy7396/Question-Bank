import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:docx_template/docx_template.dart';
import '../models/question.dart';

class FileParser {
  // 解析 Excel 文件
  static Future<List<Question>> parseExcel(String path) async {
    var bytes = await File(path).readAsBytes();
    var excel = Excel.decodeBytes(bytes);
    List<Question> questions = [];

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      for (var row in sheet!.rows.skip(1)) { // 跳过标题行
        questions.add(Question(
          id: questions.length + 1,
          content: row[0]?.value.toString() ?? '',
          options: row[1]?.value.toString().split(',') ?? [],
          correctAnswer: row[2]?.value.toString() ?? '',
          type: row[3]?.value.toString() == 'true_false' ? 'true_false' : 'multiple_choice',
        ));
      }
    }
    return questions;
  }

  // 解析 Word 文件
  static Future<List<Question>> parseWord(String path) async {
    final doc = await DocxTemplate.fromFile(File(path));
    // 假设 Word 文件每段为一道题，格式为：题目|选项1,选项2,...|正确答案|类型
    List<Question> questions = [];
    // 这里需要根据实际 Word 格式解析，示例代码简化
    // 实际实现需根据 Word 文档结构调整
    return questions;
  }

  // 上传文件
  static Future<List<Question>> uploadFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == 'excel' ? ['xlsx', 'xls'] : ['docx'],
    );
    if (result != null && result.files.single.path != null) {
      if (type == 'excel') {
        return parseExcel(result.files.single.path!);
      } else {
        return parseWord(result.files.single.path!);
      }
    }
    return [];
  }
}