import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/settings_provider.dart';
import '../../data/models/sudoku_puzzle.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // 默认难度设置
              _buildDifficultySection(context, provider),

              const Divider(height: 32),

              // 其他设置（预留）
              _buildOtherSection(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDifficultySection(BuildContext context, SettingsProvider provider) {
    final theme = Theme.of(context);
    final currentDifficulty = provider.defaultDifficulty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '游戏设置',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                title: const Text('默认难度'),
                subtitle: Text(_getDifficultyText(currentDifficulty)),
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(height: 1),
              // 难度选项
              ...Difficulty.values.map((difficulty) {
                final isSelected = difficulty == currentDifficulty;
                return RadioListTile<Difficulty>(
                  title: Text(_getDifficultyText(difficulty)),
                  subtitle: Text(_getDifficultyDescription(difficulty)),
                  value: difficulty,
                  groupValue: currentDifficulty,
                  onChanged: (value) async {
                    if (value != null) {
                      try {
                        await provider.updateDefaultDifficulty(value);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('默认难度已更新')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('更新失败，请重试')),
                          );
                        }
                      }
                    }
                  },
                  selected: isSelected,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '其他',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于'),
                subtitle: const Text('数独 v1.0.0'),
                onTap: () {
                  // TODO: 显示关于对话框
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
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

  String _getDifficultyDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '适合新手，轻松入门';
      case Difficulty.medium:
        return '有一定挑战，需要技巧';
      case Difficulty.hard:
        return '考验逻辑，难度较高';
      case Difficulty.expert:
        return '极致挑战，大师级别';
    }
  }
}
