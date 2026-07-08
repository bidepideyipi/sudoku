import 'package:flutter/material.dart';
import '../../data/models/sudoku_puzzle.dart';

/// 游戏头部组件
class GameHeader extends StatelessWidget {
  final SudokuPuzzle puzzle;
  final double progress;

  const GameHeader({
    super.key,
    required this.puzzle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 标题和难度
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '数独',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _buildDifficultyChip(context),
            ],
          ),
          const SizedBox(height: 16),
          // 进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '完成度',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${puzzle.filledCount}/81',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建难度标签
  Widget _buildDifficultyChip(BuildContext context) {
    final difficultyText = _getDifficultyText();
    final color = _getDifficultyColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        difficultyText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 获取难度文本
  String _getDifficultyText() {
    switch (puzzle.difficulty) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困难';
      case Difficulty.expert:
        return '专家';
    }
  }

  /// 获取难度颜色
  Color _getDifficultyColor(BuildContext context) {
    switch (puzzle.difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.expert:
        return Colors.purple;
    }
  }
}
