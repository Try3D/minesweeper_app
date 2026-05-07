import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/board.dart';

const _kKey = 'saved_game_v1';

class SavedGame {
  final Board board;
  final Difficulty difficulty;
  final int seconds;

  const SavedGame({
    required this.board,
    required this.difficulty,
    required this.seconds,
  });
}

class SavedGameStore extends ChangeNotifier {
  SavedGame? _current;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get hasSavedGame => _current != null;
  SavedGame? get current => _current;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        final board = Board.fromJson(j['board'] as Map<String, dynamic>);
        if (board.status == GameStatus.playing) {
          final dj = j['difficulty'] as Map<String, dynamic>;
          final difficulty = Difficulty(
            dj['name'] as String,
            dj['width'] as int,
            dj['height'] as int,
            dj['mines'] as int,
          );
          _current = SavedGame(
            board: board,
            difficulty: difficulty,
            seconds: j['seconds'] as int? ?? 0,
          );
        }
      } catch (_) {
        // Corrupt — ignore.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> save(Board board, Difficulty difficulty, int seconds) async {
    if (board.status != GameStatus.playing) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      jsonEncode({
        'seconds': seconds,
        'difficulty': {
          'name': difficulty.name,
          'width': difficulty.width,
          'height': difficulty.height,
          'mines': difficulty.mines,
        },
        'board': board.toJson(),
      }),
    );
    _current = SavedGame(board: board, difficulty: difficulty, seconds: seconds);
    notifyListeners();
  }

  Future<void> clear() async {
    if (_current == null) return;
    _current = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
    notifyListeners();
  }
}
