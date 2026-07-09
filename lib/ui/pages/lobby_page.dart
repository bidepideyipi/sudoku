import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/sudoku_game_provider.dart';
import '../../logic/providers/settings_provider.dart';
import '../../data/models/sudoku_puzzle.dart';
import '../widgets/mode_card.dart';
import 'sudoku_home_page.dart';
import 'settings_page.dart';

/// 大厅页面
class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(hours: 24);

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // 初始化设置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    // 计算到今日午夜剩余时间
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _remainingTime = midnight.difference(now);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          }
        });
      }
    });
  }

  void _startFreeMode(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    final difficulty = provider.defaultDifficulty;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => SudokuGameProvider()..newGame(difficulty),
          child: const SudokuHomePage(),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String modeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(modeName),
        content: const Text('该模式即将推出，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final defaultDifficulty = settingsProvider.defaultDifficulty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 每日挑战
              ModeCard(
                mode: GameMode.dailyChallenge,
                onTap: () {
                  // TODO: 启动每日挑战
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('每日挑战即将推出')),
                  );
                },
                subtitle: _formatCountdown(_remainingTime),
              ),
              const SizedBox(height: 12),

              // 自由模式
              ModeCard(
                mode: GameMode.freePlay,
                onTap: () => _startFreeMode(context),
                subtitle: '默认: ${_getDifficultyText(defaultDifficulty)}',
              ),
              const SizedBox(height: 12),

              // 副本挑战
              ModeCard(
                mode: GameMode.dungeon,
                isLocked: true,
                onTap: () => _showComingSoonDialog(context, '副本挑战'),
              ),
              const SizedBox(height: 12),

              // 对战模式
              ModeCard(
                mode: GameMode.battle,
                isLocked: true,
                onTap: () => _showComingSoonDialog(context, '对战模式'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '剩余 $hours:$minutes:$seconds';
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
}
