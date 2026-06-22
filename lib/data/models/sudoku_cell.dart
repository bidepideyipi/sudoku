/// 单元格状态枚举
enum CellState {
  /// 空单元格
  empty,

  /// 初始固定值（不可修改）
  fixed,

  /// 用户输入的值
  userFilled,
}

/// 数独单元格数据模型
class SudokuCell {
  /// 单元格值（0 表示空）
  final int value;

  /// 单元格状态
  final CellState state;

  /// 是否被选中
  final bool isSelected;

  /// 是否有冲突（验证时使用）
  final bool hasConflict;

  /// 是否与选中单元格在同一行（用于高亮显示）
  final bool isInSameRow;

  /// 是否与选中单元格在同一列（用于高亮显示）
  final bool isInSameCol;

  /// 是否与选中单元格在同一3×3宫格（用于高亮显示）
  final bool isInSameBox;

  /// 是否与选中单元格有相同的值（用于高亮显示）
  final bool hasSameValueAsSelected;

  const SudokuCell({
    required this.value,
    required this.state,
    this.isSelected = false,
    this.hasConflict = false,
    this.isInSameRow = false,
    this.isInSameCol = false,
    this.isInSameBox = false,
    this.hasSameValueAsSelected = false,
  });

  /// 创建空的单元格
  factory SudokuCell.empty() {
    return const SudokuCell(
      value: 0,
      state: CellState.empty,
      isInSameRow: false,
      isInSameCol: false,
      isInSameBox: false,
      hasSameValueAsSelected: false,
    );
  }

  /// 创建固定值的单元格
  factory SudokuCell.fixed(int value) {
    return SudokuCell(
      value: value,
      state: CellState.fixed,
      isInSameRow: false,
      isInSameCol: false,
      isInSameBox: false,
      hasSameValueAsSelected: false,
    );
  }

  /// 创建用户填入的单元格
  factory SudokuCell.userFilled(int value) {
    return SudokuCell(
      value: value,
      state: CellState.userFilled,
      isInSameRow: false,
      isInSameCol: false,
      isInSameBox: false,
      hasSameValueAsSelected: false,
    );
  }

  /// 判断是否为空
  bool get isEmpty => value == 0;

  /// 判断是否为固定值
  bool get isFixed => state == CellState.fixed;

  /// 更新选中状态
  SudokuCell withSelected(bool selected) {
    return SudokuCell(
      value: value,
      state: state,
      isSelected: selected,
      hasConflict: hasConflict,
      isInSameRow: isInSameRow,
      isInSameCol: isInSameCol,
      isInSameBox: isInSameBox,
      hasSameValueAsSelected: hasSameValueAsSelected,
    );
  }

  /// 更新冲突状态
  SudokuCell withConflict(bool conflict) {
    return SudokuCell(
      value: value,
      state: state,
      isSelected: isSelected,
      hasConflict: conflict,
      isInSameRow: isInSameRow,
      isInSameCol: isInSameCol,
      isInSameBox: isInSameBox,
      hasSameValueAsSelected: hasSameValueAsSelected,
    );
  }

  /// 更新值（用于用户输入）
  SudokuCell withValue(int newValue) {
    return SudokuCell(
      value: newValue,
      state: newValue == 0 ? CellState.empty : CellState.userFilled,
      isSelected: isSelected,
      hasConflict: hasConflict,
      isInSameRow: isInSameRow,
      isInSameCol: isInSameCol,
      isInSameBox: isInSameBox,
      hasSameValueAsSelected: hasSameValueAsSelected,
    );
  }

  /// 更新高亮状态
  SudokuCell withHighlight({
    bool? inSameRow,
    bool? inSameCol,
    bool? inSameBox,
    bool? sameValueAsSelected,
  }) {
    return SudokuCell(
      value: value,
      state: state,
      isSelected: isSelected,
      hasConflict: hasConflict,
      isInSameRow: inSameRow ?? isInSameRow,
      isInSameCol: inSameCol ?? isInSameCol,
      isInSameBox: inSameBox ?? isInSameBox,
      hasSameValueAsSelected: sameValueAsSelected ?? hasSameValueAsSelected,
    );
  }

  /// 清除所有高亮状态
  SudokuCell clearHighlights() {
    return SudokuCell(
      value: value,
      state: state,
      isSelected: false,
      hasConflict: hasConflict,
      isInSameRow: false,
      isInSameCol: false,
      isInSameBox: false,
      hasSameValueAsSelected: false,
    );
  }

  @override
  String toString() {
    return 'SudokuCell(value: $value, state: $state, isSelected: $isSelected, hasConflict: $hasConflict, isInSameRow: $isInSameRow, isInSameCol: $isInSameCol, isInSameBox: $isInSameBox, hasSameValueAsSelected: $hasSameValueAsSelected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SudokuCell &&
        other.value == value &&
        other.state == state &&
        other.isSelected == isSelected &&
        other.hasConflict == hasConflict &&
        other.isInSameRow == isInSameRow &&
        other.isInSameCol == isInSameCol &&
        other.isInSameBox == isInSameBox &&
        other.hasSameValueAsSelected == hasSameValueAsSelected;
  }

  @override
  int get hashCode {
    return value.hashCode ^
        state.hashCode ^
        isSelected.hashCode ^
        hasConflict.hashCode ^
        isInSameRow.hashCode ^
        isInSameCol.hashCode ^
        isInSameBox.hashCode ^
        hasSameValueAsSelected.hashCode;
  }
}
