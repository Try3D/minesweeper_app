import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/board.dart';

const _kKey = 'scores_v1';
const _kRecentCap = 10;

class WinEntry {
  final int seconds;
  final DateTime date;
  final String? playerName;
  WinEntry({required this.seconds, required this.date, this.playerName});

  Map<String, dynamic> toJson() => {
    's': seconds,
    'd': date.toIso8601String(),
    if (playerName != null) 'n': playerName,
  };

  factory WinEntry.fromJson(Map<String, dynamic> j) => WinEntry(
    seconds: j['s'] as int,
    date: DateTime.parse(j['d'] as String),
    playerName: j['n'] as String?,
  );
}

class DifficultyScores {
  int? bestSeconds;
  int played;
  int won;
  List<WinEntry> recentWins;

  DifficultyScores({
    this.bestSeconds,
    this.played = 0,
    this.won = 0,
    List<WinEntry>? recentWins,
  }) : recentWins = recentWins ?? [];

  Map<String, dynamic> toJson() => {
    if (bestSeconds != null) 'b': bestSeconds,
    'p': played,
    'w': won,
    'r': recentWins.map((e) => e.toJson()).toList(),
  };

  factory DifficultyScores.fromJson(Map<String, dynamic> j) => DifficultyScores(
    bestSeconds: j['b'] as int?,
    played: (j['p'] as int?) ?? 0,
    won: (j['w'] as int?) ?? 0,
    recentWins: ((j['r'] as List?) ?? const [])
        .map((e) => WinEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ScoresStore extends ChangeNotifier {
  final Map<String, DifficultyScores> _byName = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  DifficultyScores forDifficulty(Difficulty d) =>
      _byName[d.name] ?? DifficultyScores();

  bool isTrackedDifficulty(Difficulty d) =>
      Difficulty.all.any((p) => p.name == d.name);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    _byName.clear();
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          _byName[entry.key] = DifficultyScores.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      } catch (_) {
        // Corrupt — start fresh.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      for (final e in _byName.entries) e.key: e.value.toJson(),
    });
    await prefs.setString(_kKey, encoded);
  }

  Future<void> recordWin(
    Difficulty d, {
    required int seconds,
    String? playerName,
  }) async {
    if (!isTrackedDifficulty(d)) return;
    final s = _byName.putIfAbsent(d.name, DifficultyScores.new);
    s.played += 1;
    s.won += 1;
    if (s.bestSeconds == null || seconds < s.bestSeconds!) {
      s.bestSeconds = seconds;
    }
    s.recentWins.insert(
      0,
      WinEntry(seconds: seconds, date: DateTime.now(), playerName: playerName),
    );
    if (s.recentWins.length > _kRecentCap) {
      s.recentWins.removeRange(_kRecentCap, s.recentWins.length);
    }
    notifyListeners();
    await _save();
  }

  Future<void> recordLoss(Difficulty d) async {
    if (!isTrackedDifficulty(d)) return;
    final s = _byName.putIfAbsent(d.name, DifficultyScores.new);
    s.played += 1;
    notifyListeners();
    await _save();
  }

  Future<void> reset() async {
    _byName.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
