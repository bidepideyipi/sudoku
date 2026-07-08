import 'package:flutter/material.dart';

/// 数字键盘组件
class NumberPad extends StatelessWidget {
  final Function(int number) onNumberTap;
  final VoidCallback onClearTap;

  const NumberPad({
    super.key,
    required this.onNumberTap,
    required this.onClearTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton(1, context),
            const SizedBox(width: 8),
            _buildNumberButton(2, context),
            const SizedBox(width: 8),
            _buildNumberButton(3, context),
            const SizedBox(width: 8),
            _buildNumberButton(4, context),
            const SizedBox(width: 8),
            _buildNumberButton(5, context),
            const SizedBox(width: 8),
            _buildNumberButton(6, context),
            const SizedBox(width: 8),
            _buildNumberButton(7, context),
            const SizedBox(width: 8),
            _buildNumberButton(8, context),
            const SizedBox(width: 8),
            _buildNumberButton(9, context),
            const SizedBox(width: 8),
            _buildClearButton(context),
          ],
        ),
      ),
    );
  }

  /// 构建数字按钮
  Widget _buildNumberButton(int number, BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: () => onNumberTap(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 构建清除按钮
  Widget _buildClearButton(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 50,
      child: OutlinedButton(
        onPressed: onClearTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '清除',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
