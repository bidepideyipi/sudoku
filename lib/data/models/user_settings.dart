import '../../config/app_config.dart';
import 'sudoku_puzzle.dart';

/// 用户设置模型
class UserSettings {
  final String id;
  final Difficulty defaultDifficulty;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.defaultDifficulty,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建默认设置
  factory UserSettings.createDefault() {
    final now = DateTime.now();
    return UserSettings(
      id: 'user_settings',
      defaultDifficulty: Difficulty.easy,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从数据库行创建
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as String,
      defaultDifficulty: AppConfig.intToDifficulty(map['default_difficulty'] as int),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// 转换为数据库行
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'default_difficulty': AppConfig.difficultyToInt(defaultDifficulty),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并更新部分字段
  UserSettings copyWith({
    String? id,
    Difficulty? defaultDifficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
