import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sudoku_puzzle.dart';
import '../../config/app_config.dart';

/// 数独题目本地数据源
class PuzzleLocalDataSource {
  static const String _assetPath = 'assets/data/puzzles.db';
  static const String _tableName = 'puzzles';

  Database? _database;

  /// 获取数据库实例
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库 - 从 asset 加载
  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, 'puzzles.db');

    // 从 asset 复制数据库
    ByteData data = await rootBundle.load(_assetPath);
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes);

    return await openDatabase(dbPath);
  }

  /// 获取指定难度的随机题目
  Future<SudokuPuzzle?> getRandomPuzzle(Difficulty difficulty) async {
    final db = await _db;
    final difficultyInt = AppConfig.difficultyToInt(difficulty);

    final results = await db.query(
      _tableName,
      where: 'difficulty = ?',
      whereArgs: [difficultyInt],
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (results.isEmpty) return null;

    return _rowToPuzzle(results.first);
  }

  /// 将数据库行转换为 SudokuPuzzle
  SudokuPuzzle _rowToPuzzle(Map<String, dynamic> row) {
    final id = row['id'] as String;
    final difficulty = AppConfig.intToDifficulty(row['difficulty'] as int);
    final puzzleStr = row['puzzle'] as String;
    final solutionStr = row['solution'] as String?;

    return SudokuPuzzle.fromMatrix(
      matrix: _stringToMatrix(puzzleStr),
      difficulty: difficulty,
      id: id,
      solution: solutionStr != null ? _stringToMatrix(solutionStr) : null,
    );
  }

  /// 81位字符串转 9×9 矩阵
  List<List<int>> _stringToMatrix(String str) {
    final matrix = <List<int>>[];
    for (int i = 0; i < 9; i++) {
      final row = <int>[];
      for (int j = 0; j < 9; j++) {
        row.add(int.parse(str[i * 9 + j]));
      }
      matrix.add(row);
    }
    return matrix;
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
