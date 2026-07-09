import 'package:flutter/material.dart';

/// 游戏模式枚举
enum GameMode {
  dailyChallenge,
  freePlay,
  dungeon,
  battle,
}

/// 模式卡片组件
class ModeCard extends StatelessWidget {
  final GameMode mode;
  final VoidCallback onTap;
  final bool isLocked;
  final String? subtitle;
  final bool isCompleted;

  const ModeCard({
    super.key,
    required this.mode,
    required this.onTap,
    this.isLocked = false,
    this.subtitle,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLocked
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? theme.colorScheme.outline.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildIcon(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? _getDescription(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isLocked) ...[
                    const SizedBox(height: 2),
                    Text(
                      '即将推出',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isLocked)
              Icon(
                Icons.lock,
                color: theme.colorScheme.onSurfaceVariant,
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final theme = Theme.of(context);
    Color iconColor;

    switch (mode) {
      case GameMode.dailyChallenge:
        iconColor = Colors.amber;
        break;
      case GameMode.freePlay:
        iconColor = Colors.blue;
        break;
      case GameMode.dungeon:
        iconColor = Colors.indigo;
        break;
      case GameMode.battle:
        iconColor = Colors.red;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isLocked
            ? theme.colorScheme.surfaceContainerHighest
            : iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getIcon(),
        color: isLocked ? theme.colorScheme.onSurfaceVariant : iconColor,
        size: 22,
      ),
    );
  }

  IconData _getIcon() {
    switch (mode) {
      case GameMode.dailyChallenge:
        return Icons.today_outlined;
      case GameMode.freePlay:
        return Icons.casino_outlined;
      case GameMode.dungeon:
        return Icons.map_outlined;
      case GameMode.battle:
        return Icons.sports_esports;
    }
  }

  String _getTitle() {
    switch (mode) {
      case GameMode.dailyChallenge:
        return '每日挑战';
      case GameMode.freePlay:
        return '自由模式';
      case GameMode.dungeon:
        return '副本挑战';
      case GameMode.battle:
        return '对战模式';
    }
  }

  String _getDescription() {
    switch (mode) {
      case GameMode.dailyChallenge:
        return '全球统一题目，限时24小时';
      case GameMode.freePlay:
        return '选择难度，随机出题';
      case GameMode.dungeon:
        return '挑战固定关卡，解锁新内容';
      case GameMode.battle:
        return '实时对战，匹配对手';
    }
  }
}
