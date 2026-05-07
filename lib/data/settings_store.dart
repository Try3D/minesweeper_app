import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kKey = 'settings_v1';
const _kNameMax = 16;

const int kLongPressDurationMin = 100;
const int kLongPressDurationMax = 500;
const int kLongPressDurationDefault = 500;

class SettingsStore extends ChangeNotifier {
  String _playerName = 'Player';
  bool _haptics = true;
  bool _firstClickSafety = true;
  bool _showTimer = true;
  int _longPressDurationMs = kLongPressDurationDefault;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  String get playerName => _playerName;
  bool get haptics => _haptics;
  bool get firstClickSafety => _firstClickSafety;
  bool get showTimer => _showTimer;
  int get longPressDurationMs => _longPressDurationMs;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        _playerName = (j['name'] as String?) ?? _playerName;
        _haptics = (j['haptics'] as bool?) ?? _haptics;
        _firstClickSafety =
            (j['firstClickSafety'] as bool?) ?? _firstClickSafety;
        _showTimer = (j['showTimer'] as bool?) ?? _showTimer;
        _longPressDurationMs =
            (j['longPressDurationMs'] as int?) ?? _longPressDurationMs;
      } catch (_) {
        // Corrupt — keep defaults.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kKey,
      jsonEncode({
        'name': _playerName,
        'haptics': _haptics,
        'firstClickSafety': _firstClickSafety,
        'showTimer': _showTimer,
        'longPressDurationMs': _longPressDurationMs,
      }),
    );
  }

  Future<void> setPlayerName(String value) async {
    var v = value.trim();
    if (v.length > _kNameMax) v = v.substring(0, _kNameMax);
    if (v.isEmpty) v = 'Player';
    if (v == _playerName) return;
    _playerName = v;
    notifyListeners();
    await _save();
  }

  Future<void> setHaptics(bool value) async {
    if (value == _haptics) return;
    _haptics = value;
    notifyListeners();
    await _save();
  }

  Future<void> setFirstClickSafety(bool value) async {
    if (value == _firstClickSafety) return;
    _firstClickSafety = value;
    notifyListeners();
    await _save();
  }

  Future<void> setShowTimer(bool value) async {
    if (value == _showTimer) return;
    _showTimer = value;
    notifyListeners();
    await _save();
  }

  Future<void> setLongPressDurationMs(int value) async {
    final clamped =
        value.clamp(kLongPressDurationMin, kLongPressDurationMax);
    if (clamped == _longPressDurationMs) return;
    _longPressDurationMs = clamped;
    notifyListeners();
    await _save();
  }

  Future<void> resetAll() async {
    _playerName = 'Player';
    _haptics = true;
    _firstClickSafety = true;
    _showTimer = true;
    _longPressDurationMs = kLongPressDurationDefault;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
