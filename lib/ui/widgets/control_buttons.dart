import 'package:flutter/material.dart';

/// 控制按钮组件
class ControlButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onPencil;
  final VoidCallback onValidate;
  final VoidCallback onHint;
  final bool isCompleted;

  const ControlButtons({
    super.key,
    required this.onClear,
    required this.onPencil,
    required this.onValidate,
    required this.onHint,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            context,
            icon: Icons.backspace_outlined,
            label: '擦除',
            onTap: onClear,
          ),
          _buildControlButton(
            context,
            icon: Icons.edit_outlined,
            label: '铅笔',
            onTap: onPencil,
          ),
          _buildControlButton(
            context,
            icon: Icons.check_circle,
            label: '验证',
            onTap: onValidate,
          ),
          _buildControlButton(
            context,
            icon: Icons.lightbulb,
            label: '提示',
            onTap: onHint,
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          iconSize: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
