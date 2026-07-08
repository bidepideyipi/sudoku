import 'package:flutter/foundation.dart';
import '../../data/models/sudoku_puzzle.dart';
import '../../data/repositories/puzzle_repository.dart';
import '../validators/sudoku_validator.dart';

/// 游戏状态
enum GameStatus {
  /// 游戏中
  playing,

  /// 已完成
  completed,

  /// 已暂停
  paused,
}

/// 数独游戏状态管理 Provider
class SudokuGameProvider extends ChangeNotifier {
  final PuzzleRepository _repository = PuzzleRepository();

  /// 是否已初始化
  bool _isInitialized = false;

  /// 当前谜题
  SudokuPuzzle _currentPuzzle = SudokuPuzzle.fromMatrix(
    matrix: _emptyMatrix(),
    difficulty: Difficulty.easy,
    id: 'initial',
  );

  /// 当前难度
  Difficulty _currentDifficulty = Difficulty.easy;

  /// 选中的单元格位置 (row, col)
  (int, int)? _selectedPosition;

  /// 游戏状态
  GameStatus _gameStatus = GameStatus.playing;

  /// 验证结果
  ValidationResult? _validationResult;

  /// 获取当前谜题
  SudokuPuzzle get currentPuzzle => _currentPuzzle;

  /// 获取当前难度
  Difficulty get currentDifficulty => _currentDifficulty;

  /// 获取选中位置
  (int, int)? get selectedPosition => _selectedPosition;

  /// 获取游戏状态
  GameStatus get gameStatus => _gameStatus;

  /// 获取验证结果
  ValidationResult? get validationResult => _validationResult;

  /// 初始化 Provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('开始初始化 Repository...');
      await _repository.init();
      _isInitialized = true;
      debugPrint('Repository 初始化成功');

      // 加载第一个题目
      debugPrint('加载简单难度题目...');
      await newGame(Difficulty.easy);
      debugPrint('题目加载成功');
    } catch (e) {
      // 初始化失败，使用空题目
      debugPrint('初始化失败: $e');
      _isInitialized = true;

      // 创建一个默认题目
      _currentPuzzle = SudokuPuzzle.fromMatrix(
        matrix: _emptyMatrix(),
        difficulty: Difficulty.easy,
        id: 'fallback',
      );
    }
  }

  /// 是否有选中的单元格
  bool get hasSelection => _selectedPosition != null;

  /// 游戏完成度
  double get progress {
    if (_currentPuzzle.filledCount == 0) return 0.0;
    return _currentPuzzle.filledCount / 81;
  }

  /// 创建空矩阵
  static List<List<int>> _emptyMatrix() {
    return List.generate(9, (_) => List.filled(9, 0));
  }

  /// 开始新游戏
  Future<void> newGame([Difficulty? difficulty]) async {
    _currentDifficulty = difficulty ?? _currentDifficulty;
    _currentPuzzle = await _repository.getPuzzle(_currentDifficulty);
    _selectedPosition = null;
    _gameStatus = GameStatus.playing;
    _validationResult = null;
    notifyListeners();
  }

  /// 重新开始当前游戏
  Future<void> restartGame() async {
    final puzzle = await _repository.getPuzzle(_currentDifficulty);
    _currentPuzzle = puzzle;
    _selectedPosition = null;
    _gameStatus = GameStatus.playing;
    _validationResult = null;
    notifyListeners();
  }

  /// 选择单元格
  void selectCell(int row, int col) {
    final selectedCell = _currentPuzzle.getCell(row, col);
    final selectedValue = selectedCell.value;

    // 清除之前的高亮状态
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _currentPuzzle.getCell(r, c);
        _currentPuzzle = _currentPuzzle.withCell(r, c, cell.clearHighlights());
      }
    }

    // 设置新的高亮状态
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _currentPuzzle.getCell(r, c);

        // 计算是否在同一3×3宫格
        final boxRow = (row ~/ 3) * 3;
        final boxCol = (col ~/ 3) * 3;
        final inSameBox = r >= boxRow && r < boxRow + 3 && c >= boxCol && c < boxCol + 3;

        // 检查是否与选中单元格有相同值
        final sameValue = selectedValue != 0 && cell.value == selectedValue;

        final highlighted = cell.withHighlight(
          inSameRow: r == row,
          inSameCol: c == col,
          inSameBox: inSameBox,
          sameValueAsSelected: sameValue,
        );

        // 设置选中状态
        final finalCell = (r == row && c == col)
            ? highlighted.withSelected(true)
            : highlighted;

        _currentPuzzle = _currentPuzzle.withCell(r, c, finalCell);
      }
    }

    _selectedPosition = (row, col);

    notifyListeners();
  }

  /// 输入数字
  void inputNumber(int number) {
    if (_selectedPosition == null) return;

    final (row, col) = _selectedPosition!;
    final cell = _currentPuzzle.getCell(row, col);

    // 固定值不能修改
    if (cell.isFixed) return;

    // 更新单元格值
    final newCell = cell.withValue(number);
    _currentPuzzle = _currentPuzzle.withCell(row, col, newCell);

    // 清除验证结果
    _validationResult = null;

    // 检查是否完成
    if (_currentPuzzle.isComplete()) {
      if (SudokuValidator.isCompleteAndValid(_currentPuzzle)) {
        _gameStatus = GameStatus.completed;
      }
    }

    notifyListeners();
  }

  /// 清除选中单元格的值
  void clearCell() {
    if (_selectedPosition == null) return;

    final (row, col) = _selectedPosition!;
    final cell = _currentPuzzle.getCell(row, col);

    // 固定值不能清除
    if (cell.isFixed) return;

    inputNumber(0);
  }

  /// 验证棋盘
  void validateBoard() {
    _validationResult = SudokuValidator.validate(_currentPuzzle);

    // 更新所有单元格的冲突状态
    final conflicts = _validationResult!.conflicts;
    for (final pos in conflicts) {
      final row = pos[0];
      final col = pos[1];
      final cell = _currentPuzzle.getCell(row, col);
      _currentPuzzle = _currentPuzzle.withCell(
        row,
        col,
        cell.withConflict(true),
      );
    }

    notifyListeners();
  }

  /// 清除冲突标记
  void clearConflicts() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = _currentPuzzle.getCell(row, col);
        if (cell.hasConflict) {
          _currentPuzzle = _currentPuzzle.withCell(
            row,
            col,
            cell.withConflict(false),
          );
        }
      }
    }
    _validationResult = null;
    notifyListeners();
  }

  /// 暂停游戏
  void pauseGame() {
    _gameStatus = GameStatus.paused;
    notifyListeners();
  }

  /// 继续游戏
  void resumeGame() {
    _gameStatus = GameStatus.playing;
    notifyListeners();
  }

  /// 获取提示
  void getHint() {
    if (_selectedPosition == null) return;

    final (row, col) = _selectedPosition!;
    final cell = _currentPuzzle.getCell(row, col);

    // 只提示非固定值的单元格
    if (cell.isFixed) return;

    // 优先使用 solution 字段获取正确答案
    if (_currentPuzzle.solution != null) {
      final correctValue = _currentPuzzle.solution![row][col];
      if (correctValue != 0) {
        inputNumber(correctValue);
        return;
      }
    }

    // 降级：随机选择一个有效数字
    for (int num = 1; num <= 9; num++) {
      if (SudokuValidator.isValidPlacement(_currentPuzzle, row, col, num)) {
        inputNumber(num);
        return;
      }
    }
  }
}
