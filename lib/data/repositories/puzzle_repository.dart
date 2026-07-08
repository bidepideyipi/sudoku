import '../models/sudoku_puzzle.dart';
import '../datasources/puzzle_remote_datasource.dart';
import '../datasources/puzzle_local_datasource.dart';

/// 数独题目仓库
class PuzzleRepository {
  final PuzzleRemoteDataSource _remote;
  final PuzzleLocalDataSource _local;

  PuzzleRepository({
    PuzzleRemoteDataSource? remote,
    PuzzleLocalDataSource? local,
  })  : _remote = remote ?? PuzzleRemoteDataSource(),
        _local = local ?? PuzzleLocalDataSource();

  /// 初始化 - 可选同步题目到本地
  Future<void> init() async {
    // 可选：后台同步题目，但不阻塞启动
    _syncInBackground();
  }

  /// 获取指定难度的题目
  Future<SudokuPuzzle> getPuzzle(Difficulty difficulty) async {
    // 优先从本地获取
    final localPuzzle = await _local.getRandomPuzzle(difficulty);
    if (localPuzzle != null) {
      return localPuzzle;
    }

    // 尝试从远程获取
    try {
      final puzzles = await _remote.fetchPuzzles(difficulty, 1);
      if (puzzles.isNotEmpty) {
        return puzzles.first;
      }
    } catch (_) {}

    throw Exception('无法获取题目');
  }

  /// 后台同步
  Future<void> _syncInBackground() async {
    // 这里可以添加后台同步逻辑
    // 暂不实现，保持简单
  }

  void dispose() {
    _remote.dispose();
    _local.close();
  }
}
