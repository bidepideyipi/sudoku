import '../data/models/sudoku_puzzle.dart';

/// 应用配置
class AppConfig {
  static const String baseUrl = 'http://127.0.0.1:9000';
  static const String apiVersion = 'api/v1';
  static const String puzzleBatchPath = '/$apiVersion/sudoku/puzzle/batch';

  static String getPuzzleBatchUrl() => '$baseUrl$puzzleBatchPath';

  static int difficultyToInt(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy: return 1;
      case Difficulty.medium: return 2;
      case Difficulty.hard: return 3;
      case Difficulty.expert: return 4;
    }
  }

  static Difficulty intToDifficulty(int value) {
    switch (value) {
      case 1: return Difficulty.easy;
      case 2: return Difficulty.medium;
      case 3: return Difficulty.hard;
      case 4: return Difficulty.expert;
      default: return Difficulty.easy;
    }
  }
}
