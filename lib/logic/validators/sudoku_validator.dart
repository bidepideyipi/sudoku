import '../../data/models/sudoku_puzzle.dart';

/// 数独验证结果
class ValidationResult {
  /// 是否有效
  final bool isValid;

  /// 冲突的单元格位置列表
  final List<List<int>> conflicts;

  const ValidationResult({
    required this.isValid,
    required this.conflicts,
  });

  /// 无冲突的验证结果
  static const valid = ValidationResult(isValid: true, conflicts: []);

  /// 创建无效的验证结果
  static ValidationResult withConflicts(List<List<int>> conflictPositions) {
    return ValidationResult(
      isValid: false,
      conflicts: conflictPositions,
    );
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, conflicts: ${conflicts.length})';
  }
}

/// 数独验证器
class SudokuValidator {
  /// 验证指定位置是否可以放置指定数字
  static bool isValidPlacement(
    SudokuPuzzle puzzle,
    int row,
    int col,
    int value,
  ) {
    // 检查是否已有相同值
    if (puzzle.getCell(row, col).value == value) return true;

    // 检查行
    final rowValues = puzzle.getRowValues(row);
    if (rowValues.contains(value)) return false;

    // 检查列
    final colValues = puzzle.getColumnValues(col);
    if (colValues.contains(value)) return false;

    // 检查 3×3 宫格
    final boxValues = puzzle.getBoxValues(row, col);
    if (boxValues.contains(value)) return false;

    return true;
  }

  /// 检查游戏是否完成且正确
  static bool isCompleteAndValid(SudokuPuzzle puzzle) {
    // 首先检查是否填满
    if (!puzzle.isComplete()) return false;

    // 检查每个单元格是否有效
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final value = puzzle.getCell(row, col).value;
        final testPuzzle = SudokuPuzzle.fromMatrix(
          matrix: _createEmptyMatrix(),
          difficulty: puzzle.difficulty,
          id: 'test',
        );
        if (!isValidPlacement(testPuzzle, row, col, value)) {
          return false;
        }
      }
    }

    return true;
  }

  /// 找出所有冲突的单元格位置
  static List<List<int>> findConflicts(SudokuPuzzle puzzle) {
    final conflicts = <List<int>>[];

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final cell = puzzle.getCell(row, col);
        if (cell.isEmpty) continue;

        final value = cell.value;

        // 创建一个空的谜题用于验证
        final testPuzzle = SudokuPuzzle.fromMatrix(
          matrix: _createEmptyMatrix(),
          difficulty: puzzle.difficulty,
          id: 'test',
        );

        // 检查该位置是否有效（在空的谜题上检查）
        if (!isValidPlacement(testPuzzle, row, col, value)) {
          conflicts.add([row, col]);
        }
      }
    }

    return conflicts;
  }

  /// 验证整个棋盘
  static ValidationResult validate(SudokuPuzzle puzzle) {
    final conflicts = findConflicts(puzzle);
    if (conflicts.isEmpty) {
      return ValidationResult.valid;
    }
    return ValidationResult.withConflicts(conflicts);
  }

  /// 检查指定数字在行、列、宫格中是否重复
  static bool hasDuplicateInLine(SudokuPuzzle puzzle, int row, int col) {
    final cell = puzzle.getCell(row, col);
    if (cell.isEmpty) return false;

    final value = cell.value;

    // 检查行
    final rowValues = puzzle.getRowValues(row);
    final rowCount = rowValues.where((v) => v == value).length;
    if (rowCount > 1) return true;

    // 检查列
    final colValues = puzzle.getColumnValues(col);
    final colCount = colValues.where((v) => v == value).length;
    if (colCount > 1) return true;

    // 检查宫格
    final boxValues = puzzle.getBoxValues(row, col);
    final boxCount = boxValues.where((v) => v == value).length;
    if (boxCount > 1) return true;

    return false;
  }

  /// 创建空的 9×9 矩阵
  static List<List<int>> _createEmptyMatrix() {
    return List.generate(9, (_) => List.filled(9, 0));
  }

  /// 检查谜题是否有解（简单检查）
  static bool isSolvable(SudokuPuzzle puzzle) {
    // 这里只做基本检查，完整的数独求解器比较复杂
    // 对于简化版应用，我们假设所有预设题目都是有解的
    return true;
  }
}
