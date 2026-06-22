import '../models/sudoku_puzzle.dart';
import '../models/puzzle_data.dart';

/// 模拟数独题目仓库
class MockPuzzleRepository {
  /// 获取指定难度的题目
  SudokuPuzzle getPuzzle(Difficulty difficulty) {
    return MockPuzzleData.getPuzzle(difficulty);
  }

  /// 获取简单难度题目
  SudokuPuzzle getEasyPuzzle() {
    return getPuzzle(Difficulty.easy);
  }

  /// 获取中等难度题目
  SudokuPuzzle getMediumPuzzle() {
    return getPuzzle(Difficulty.medium);
  }

  /// 获取困难难度题目
  SudokuPuzzle getHardPuzzle() {
    return getPuzzle(Difficulty.hard);
  }

  /// 获取下一个随机题目
  SudokuPuzzle getRandomPuzzle() {
    final difficulties = Difficulty.values;
    final randomDifficulty =
        difficulties[DateTime.now().millisecond % difficulties.length];
    return getPuzzle(randomDifficulty);
  }
}
