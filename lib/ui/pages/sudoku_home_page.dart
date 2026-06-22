import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/sudoku_game_provider.dart';
import '../../data/models/sudoku_puzzle.dart';
import '../widgets/game_header.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/control_buttons.dart';

/// 数独游戏主页面
class SudokuHomePage extends StatelessWidget {
  const SudokuHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<SudokuGameProvider>(
          builder: (context, provider, child) {
            // 显示完成对话框
            if (provider.gameStatus == GameStatus.completed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showCompletionDialog(context);
              });
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // 游戏头部
                  GameHeader(
                    puzzle: provider.currentPuzzle,
                    progress: provider.progress,
                  ),

                  const SizedBox(height: 16),

                  // 数独棋盘
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SudokuBoard(
                      puzzle: provider.currentPuzzle,
                      onCellTap: (row, col) {
                        provider.selectCell(row, col);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 数字键盘
                  _NumberPadSection(provider: provider),

                  const SizedBox(height: 16),

                  // 控制按钮
                  ControlButtons(
                    onClear: () => provider.clearCell(),
                    onPencil: () => _showNewGameDialog(context),
                    onValidate: () => provider.validateBoard(),
                    onHint: () => provider.getHint(),
                    isCompleted: provider.gameStatus == GameStatus.completed,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 显示完成对话框
  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('恭喜！'),
        content: const Text('你已完成这个数独谜题！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showNewGameDialog(context);
            },
            child: const Text('开始新游戏'),
          ),
        ],
      ),
    );
  }

  /// 显示新游戏对话框
  void _showNewGameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开始新游戏'),
        content: const Text('选择难度'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SudokuGameProvider>().newGame(Difficulty.easy);
            },
            child: const Text('简单'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SudokuGameProvider>().newGame(Difficulty.medium);
            },
            child: const Text('中等'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SudokuGameProvider>().newGame(Difficulty.hard);
            },
            child: const Text('困难'),
          ),
        ],
      ),
    );
  }
}

/// 数字键盘部分（内部组件，使用 Provider）
class _NumberPadSection extends StatelessWidget {
  final SudokuGameProvider provider;

  const _NumberPadSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 按钮大小 = 可用宽度 / 9
          final buttonSize = (constraints.maxWidth - 8 * 8) / 9;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNumberButton(1, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(2, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(3, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(4, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(5, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(6, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(7, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(8, buttonSize, context),
                const SizedBox(width: 8),
                _buildNumberButton(9, buttonSize, context),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建数字按钮
  Widget _buildNumberButton(int number, double size, BuildContext context) {
    // 字体大小随按钮大小缩放，但不小于16
    final fontSize = (size * 0.4).clamp(16.0, 32.0);

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: () => provider.inputNumber(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
