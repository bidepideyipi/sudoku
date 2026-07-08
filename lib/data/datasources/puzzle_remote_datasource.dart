import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sudoku_puzzle.dart';
import '../../config/app_config.dart';

/// 远程数据源异常
class RemoteDataSourceException implements Exception {
  final String message;
  RemoteDataSourceException(this.message);

  @override
  String toString() => 'RemoteDataSourceException: $message';
}

/// 后端 API 响应模型
class PuzzleApiResponse {
  final int code;
  final String message;
  final PuzzleApiData? data;

  PuzzleApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory PuzzleApiResponse.fromJson(Map<String, dynamic> json) {
    return PuzzleApiResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null
          ? PuzzleApiData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isSuccess => code == 0;
}

class PuzzleApiData {
  final List<PuzzleApiItem> puzzles;
  final int total;

  PuzzleApiData({
    required this.puzzles,
    required this.total,
  });

  factory PuzzleApiData.fromJson(Map<String, dynamic> json) {
    final puzzlesList = json['puzzles'] as List;
    return PuzzleApiData(
      puzzles: puzzlesList
          .map((item) => PuzzleApiItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}

class PuzzleApiItem {
  final String id;
  final String puzzle;      // 81位字符串
  final String solution;    // 81位字符串
  final int difficulty;     // 1-4
  final String createdAt;

  PuzzleApiItem({
    required this.id,
    required this.puzzle,
    required this.solution,
    required this.difficulty,
    required this.createdAt,
  });

  factory PuzzleApiItem.fromJson(Map<String, dynamic> json) {
    return PuzzleApiItem(
      id: json['id'] as String,
      puzzle: json['puzzle'] as String,
      solution: json['solution'] as String,
      difficulty: json['difficulty'] as int,
      createdAt: json['createdAt'] as String,
    );
  }
}

/// 数独题目远程数据源
class PuzzleRemoteDataSource {
  final http.Client _client;

  PuzzleRemoteDataSource({
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// 批量获取题目
  ///
  /// [difficulty] 难度级别
  /// [count] 获取数量，1-500
  /// 返回题目列表
  Future<List<SudokuPuzzle>> fetchPuzzles(Difficulty difficulty, int count) async {
    if (count < 1 || count > 500) {
      throw RemoteDataSourceException('count 必须在 1-500 之间');
    }

    final url = AppConfig.getPuzzleBatchUrl();
    final difficultyInt = AppConfig.difficultyToInt(difficulty);

    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'difficulty': difficultyInt,
          'count': count,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = PuzzleApiResponse.fromJson(jsonResponse);

        if (!apiResponse.isSuccess) {
          throw RemoteDataSourceException('API 错误: ${apiResponse.message}');
        }

        if (apiResponse.data == null) {
          throw RemoteDataSourceException('响应数据为空');
        }

        return apiResponse.data!.puzzles.map((item) {
          return _apiItemToPuzzle(item);
        }).toList();
      } else {
        throw RemoteDataSourceException(
            'HTTP 错误: ${response.statusCode} ${response.reasonPhrase}');
      }
    } on RemoteDataSourceException {
      rethrow;
    } catch (e) {
      throw RemoteDataSourceException('网络请求失败: $e');
    }
  }

  /// 将 API 返回的题目项转换为 SudokuPuzzle
  SudokuPuzzle _apiItemToPuzzle(PuzzleApiItem item) {
    final puzzleMatrix = _stringToMatrix(item.puzzle);
    final solutionMatrix = _stringToMatrix(item.solution);
    final difficulty = AppConfig.intToDifficulty(item.difficulty);

    return SudokuPuzzle.fromMatrix(
      matrix: puzzleMatrix,
      difficulty: difficulty,
      id: item.id,
      solution: solutionMatrix,
    );
  }

  /// 将81位字符串转换为9×9二维数组
  List<List<int>> _stringToMatrix(String str) {
    if (str.length != 81) {
      throw RemoteDataSourceException('题目字符串长度必须为81，当前: ${str.length}');
    }

    final matrix = <List<int>>[];
    for (int i = 0; i < 9; i++) {
      final row = <int>[];
      for (int j = 0; j < 9; j++) {
        final index = i * 9 + j;
        final char = str[index];
        final value = int.parse(char);
        row.add(value);
      }
      matrix.add(row);
    }
    return matrix;
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}
