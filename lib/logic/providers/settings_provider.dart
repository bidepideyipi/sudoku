import 'package:flutter/foundation.dart';
import '../../data/models/user_settings.dart';
import '../../data/models/sudoku_puzzle.dart';
import '../../data/datasources/user_settings_datasource.dart';

/// 设置状态管理
class SettingsProvider with ChangeNotifier {
  final UserSettingsDataSource _dataSource;

  UserSettings? _settings;
  bool _isLoading = false;
  String? _error;

  SettingsProvider(this._dataSource);

  UserSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Difficulty get defaultDifficulty =>
      _settings?.defaultDifficulty ?? Difficulty.easy;

  /// 初始化设置
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _dataSource.initDefaultSettings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新默认难度
  Future<void> updateDefaultDifficulty(Difficulty difficulty) async {
    try {
      await _dataSource.updateDefaultDifficulty(difficulty);
      if (_settings != null) {
        _settings = _settings!.copyWith(
          defaultDifficulty: difficulty,
          updatedAt: DateTime.now(),
        );
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 重新加载设置
  Future<void> reload() async {
    _settings = await _dataSource.getSettings();
    notifyListeners();
  }
}
