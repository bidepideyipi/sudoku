import 'package:flutter/material.dart';
import '../../data/models/sudoku_cell.dart';

/// 单个数独单元格组件
class SudokuCellWidget extends StatelessWidget {
  final SudokuCell cell;
  final VoidCallback onTap;
  final int row;
  final int col;

  const SudokuCellWidget({
    super.key,
    required this.cell,
    required this.onTap,
    required this.row,
    required this.col,
  });

  /// 判断是否需要在右侧显示粗边框（3×3宫格边界）
  bool get showRightBorder => (col + 1) % 3 == 0 && col < 8;

  /// 判断是否需要在底部显示粗边框（3×3宫格边界）
  bool get showBottomBorder => (row + 1) % 3 == 0 && row < 8;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(context),
          border: Border(
            left: BorderSide(
              color: Colors.grey[400]!,
              width: 0.5,
            ),
            top: BorderSide(
              color: Colors.grey[400]!,
              width: 0.5,
            ),
            right: BorderSide(
              color: showRightBorder ? Colors.black87 : Colors.grey[400]!,
              width: showRightBorder ? 3 : 0.5,
            ),
            bottom: BorderSide(
              color: showBottomBorder ? Colors.black87 : Colors.grey[400]!,
              width: showBottomBorder ? 3 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: cell.isEmpty
              ? const SizedBox.shrink()
              : Text(
                  cell.value.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.normal,
                    color: _getTextColor(context),
                  ),
                ),
        ),
      ),
    );
  }

  /// 获取单元格背景色
  Color _getCellColor(BuildContext context) {
    // 冲突状态优先级最高
    if (cell.hasConflict) {
      return Colors.red[100]!;
    }

    // 相同数字高亮（浅蓝色）
    if (cell.hasSameValueAsSelected && !cell.isSelected) {
      return Colors.blue[100]!;
    }

    // 选中单元格（深蓝色）
    if (cell.isSelected) {
      return Colors.blue[200]!;
    }

    // 同行、同列或同宫格（灰色）
    if (cell.isInSameRow || cell.isInSameCol || cell.isInSameBox) {
      return Colors.grey[200]!;
    }

    // 固定值默认为白色（不加灰色背景）
    return Colors.white;
  }

  /// 获取文字颜色
  Color _getTextColor(BuildContext context) {
    if (cell.hasConflict) {
      return Colors.red[700]!;
    }
    if (cell.isFixed) {
      return Colors.black87;
    }
    return Theme.of(context).colorScheme.primary;
  }
}
