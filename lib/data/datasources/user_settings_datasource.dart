import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_settings.dart';
import '../../config/app_config.dart';
import '../models/sudoku_puzzle.dart';

/// 用户设置数据源
class UserSettingsDataSource {
  static const String _dbName = 'user_settings.db';
  static const String _tableName = 'settings';
  static const int _version = 1;

  Database? _database;

  /// 获取数据库实例
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, _dbName);

    return await openDatabase(
      dbPath,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            default_difficulty INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// 获取用户设置
  Future<UserSettings?> getSettings() async {
    final db = await _db;
    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: ['user_settings'],
    );

    if (results.isEmpty) return null;

    return UserSettings.fromMap(results.first);
  }

  /// 保存用户设置
  Future<void> saveSettings(UserSettings settings) async {
    final db = await _db;
    final data = settings.copyWith(updatedAt: DateTime.now()).toMap();

    await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新默认难度
  Future<void> updateDefaultDifficulty(Difficulty difficulty) async {
    final settings = await getSettings();
    final now = DateTime.now();

    if (settings != null) {
      final updated = settings.copyWith(
        defaultDifficulty: difficulty,
        updatedAt: now,
      );
      await saveSettings(updated);
    } else {
      final newSettings = UserSettings(
        id: 'user_settings',
        defaultDifficulty: difficulty,
        createdAt: now,
        updatedAt: now,
      );
      await saveSettings(newSettings);
    }
  }

  /// 初始化默认设置（如果不存在）
  Future<UserSettings> initDefaultSettings() async {
    final existing = await getSettings();
    if (existing != null) return existing;

    final defaultSettings = UserSettings.createDefault();
    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
