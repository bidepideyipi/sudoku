import 'dart:convert';
import 'sudoku_puzzle.dart';

/// 模拟数独题目数据
class MockPuzzleData {
  /// 简单难度题目（更简单，约45-50个已知数字）
  static const Map<String, dynamic> easyPuzzle1 = {
    'id': 'easy_001',
    'difficulty': 'easy',
    'puzzle': [
      [5, 3, 4, 6, 0, 8, 9, 0, 0],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 0, 0, 3, 7, 9, 1],
      [7, 1, 3, 0, 0, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 0, 8, 0, 1, 7, 9],
    ],
  };

  static const Map<String, dynamic> easyPuzzle2 = {
    'id': 'easy_002',
    'difficulty': 'easy',
    'puzzle': [
      [0, 0, 3, 4, 5, 6, 7, 8, 9],
      [0, 5, 0, 0, 8, 9, 1, 2, 3],
      [7, 8, 9, 1, 0, 0, 4, 5, 6],
      [2, 3, 1, 5, 6, 4, 8, 9, 0],
      [5, 6, 4, 8, 9, 7, 2, 3, 0],
      [8, 9, 7, 2, 3, 1, 5, 6, 0],
      [3, 1, 2, 6, 4, 5, 9, 7, 8],
      [6, 4, 5, 9, 0, 8, 3, 1, 2],
      [9, 7, 8, 0, 1, 0, 6, 4, 5],
    ],
  };

  static const Map<String, dynamic> easyPuzzle3 = {
    'id': 'easy_003',
    'difficulty': 'easy',
    'puzzle': [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9],
    ],
  };

  static const Map<String, dynamic> easyPuzzle4 = {
    'id': 'easy_004',
    'difficulty': 'easy',
    'puzzle': [
      [0, 0, 9, 8, 0, 2, 1, 6, 0],
      [0, 0, 2, 0, 5, 0, 3, 0, 0],
      [0, 0, 4, 0, 3, 0, 7, 0, 2],
      [2, 1, 0, 0, 6, 8, 9, 5, 0],
      [0, 4, 3, 9, 2, 0, 6, 0, 0],
      [6, 0, 8, 0, 0, 1, 0, 4, 8],
      [9, 0, 8, 5, 1, 0, 4, 2, 6],
      [0, 0, 0, 0, 0, 6, 0, 3, 0],
      [0, 0, 0, 0, 0, 0, 5, 0, 9],
    ],
  };

  /// 中等难度题目
  static const Map<String, dynamic> mediumPuzzle1 = {
    'id': 'medium_001',
    'difficulty': 'medium',
    'puzzle': [
      [0, 2, 0, 6, 0, 8, 0, 0, 0],
      [5, 8, 0, 0, 0, 9, 7, 0, 0],
      [0, 0, 0, 0, 4, 0, 0, 0, 0],
      [3, 7, 0, 0, 0, 1, 0, 8, 0],
      [6, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 2, 0, 0, 0, 3, 7],
      [0, 0, 0, 0, 5, 0, 0, 0, 0],
      [0, 0, 3, 9, 0, 0, 0, 0, 2],
      [0, 0, 0, 7, 0, 6, 0, 9, 0],
    ],
  };

  static const Map<String, dynamic> mediumPuzzle2 = {
    'id': 'medium_002',
    'difficulty': 'medium',
    'puzzle': [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 3, 0, 8, 5],
      [0, 0, 1, 0, 2, 0, 0, 0, 0],
      [0, 0, 0, 5, 0, 7, 0, 0, 0],
      [0, 0, 4, 0, 0, 0, 1, 0, 0],
      [0, 9, 0, 0, 0, 0, 0, 0, 0],
      [5, 0, 0, 0, 0, 0, 0, 7, 3],
      [0, 0, 2, 0, 1, 0, 0, 0, 0],
      [0, 0, 0, 4, 0, 0, 0, 0, 9],
    ],
  };

  /// 困难难度题目
  static const Map<String, dynamic> hardPuzzle1 = {
    'id': 'hard_001',
    'difficulty': 'hard',
    'puzzle': [
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
    ],
  };

  /// 按难度获取所有题目
  static List<Map<String, dynamic>> getPuzzlesByDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return [easyPuzzle1, easyPuzzle2, easyPuzzle3, easyPuzzle4];
      case Difficulty.medium:
        return [mediumPuzzle1, mediumPuzzle2];
      case Difficulty.hard:
        return [hardPuzzle1];
    }
  }

  /// 获取随机题目
  static Map<String, dynamic> getRandomPuzzle(Difficulty difficulty) {
    final puzzles = getPuzzlesByDifficulty(difficulty);
    // 简单轮换，实际应用可以使用随机
    return puzzles[DateTime.now().millisecond % puzzles.length];
  }

  /// 从 JSON 字符串解析谜题
  static SudokuPuzzle? fromJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final puzzle = json['puzzle'] as List<List<int>>;
      final difficultyStr = json['difficulty'] as String;
      final id = json['id'] as String;

      final difficulty = Difficulty.values.firstWhere(
        (d) => d.name == difficultyStr,
        orElse: () => Difficulty.easy,
      );

      return SudokuPuzzle.fromMatrix(
        matrix: puzzle,
        difficulty: difficulty,
        id: id,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取指定难度的谜题对象
  static SudokuPuzzle getPuzzle(Difficulty difficulty) {
    final puzzleData = getRandomPuzzle(difficulty);
    final puzzle = puzzleData['puzzle'] as List<List<int>>;

    return SudokuPuzzle.fromMatrix(
      matrix: puzzle,
      difficulty: difficulty,
      id: puzzleData['id'] as String,
    );
  }
}
