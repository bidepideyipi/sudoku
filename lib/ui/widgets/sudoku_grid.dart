import 'package:flutter/material.dart';
import '../../data/models/sudoku_puzzle.dart';
import 'sudoku_cell_widget.dart';

/// 数独 9×9 网格组件
class SudokuGrid extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final Function(int row, int col) onCellTap;

  const SudokuGrid({
    super.key,
    required this.puzzle,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black87,
          width: 3,
        ),
        color: Colors.white,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          childAspectRatio: 1.0,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          final row = index ~/ 9;
          final col = index % 9;
          final cell = puzzle.getCell(row, col);

          return SudokuCellWidget(
            cell: cell,
            row: row,
            col: col,
            onTap: () => onCellTap(row, col),
            solution: puzzle.solution,
          );
        },
      ),
    );
  }
}
