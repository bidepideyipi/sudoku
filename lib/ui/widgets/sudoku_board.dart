import 'package:flutter/material.dart';
import '../../data/models/sudoku_puzzle.dart';
import 'sudoku_grid.dart';

/// 数独棋盘容器组件
class SudokuBoard extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final Function(int row, int col) onCellTap;

  const SudokuBoard({
    super.key,
    required this.puzzle,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SudokuGrid(
        puzzle: puzzle,
        onCellTap: onCellTap,
      ),
    );
  }
}
