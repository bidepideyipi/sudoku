import 'sudoku_cell.dart';

/// 难度级别
enum Difficulty {
  easy,
  medium,
  hard,
  expert,
}

/// 数独谜题数据模型
class SudokuPuzzle {
  /// 9×9 网格数据（二维数组）
  final List<List<SudokuCell>> grid;

  /// 难度级别
  final Difficulty difficulty;

  /// 谜题 ID
  final String id;

  /// 完整答案（用于验证）
  final List<List<int>>? solution;

  const SudokuPuzzle({
    required this.grid,
    required this.difficulty,
    required this.id,
    this.solution,
  });

  /// 从二维整数数组创建谜题
  factory SudokuPuzzle.fromMatrix({
    required List<List<int>> matrix,
    required Difficulty difficulty,
    required String id,
    List<List<int>>? solution,
  }) {
    final grid = <List<SudokuCell>>[];

    for (int row = 0; row < 9; row++) {
      final rowCells = <SudokuCell>[];
      for (int col = 0; col < 9; col++) {
        final value = matrix[row][col];
        if (value == 0) {
          rowCells.add(SudokuCell.empty());
        } else {
          rowCells.add(SudokuCell.fixed(value));
        }
      }
      grid.add(rowCells);
    }

    return SudokuPuzzle(
      grid: grid,
      difficulty: difficulty,
      id: id,
      solution: solution,
    );
  }

  /// 获取指定位置的单元格
  SudokuCell getCell(int row, int col) {
    return grid[row][col];
  }

  /// 更新指定位置的单元格
  SudokuPuzzle withCell(int row, int col, SudokuCell newCell) {
    final newGrid = <List<SudokuCell>>[];
    for (int r = 0; r < 9; r++) {
      if (r == row) {
        final newRow = <SudokuCell>[];
        for (int c = 0; c < 9; c++) {
          newRow.add(c == col ? newCell : grid[r][c]);
        }
        newGrid.add(newRow);
      } else {
        newGrid.add(grid[r]);
      }
    }

    return SudokuPuzzle(
      grid: newGrid,
      difficulty: difficulty,
      id: id,
      solution: solution,
    );
  }

  /// 检查是否完成
  bool isComplete() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col].isEmpty) return false;
      }
    }
    return true;
  }

  /// 计算已填入的单元格数量
  int get filledCount {
    int count = 0;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (!grid[row][col].isEmpty) count++;
      }
    }
    return count;
  }

  /// 获取指定行的所有值
  List<int> getRowValues(int row) {
    return grid[row].map((cell) => cell.value).toList();
  }

  /// 获取指定列的所有值
  List<int> getColumnValues(int col) {
    return grid.map((row) => row[col].value).toList();
  }

  /// 获取指定 3×3 宫格的所有值
  List<int> getBoxValues(int row, int col) {
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    final values = <int>[];

    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        values.add(grid[r][c].value);
      }
    }
    return values;
  }

  @override
  String toString() {
    return 'SudokuPuzzle(id: $id, difficulty: $difficulty, filledCount: $filledCount/81)';
  }
}
