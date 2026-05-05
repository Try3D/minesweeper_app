import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kKey = 'settings_v1';
const _kNameMax = 16;

class SettingsStore extends ChangeNotifier {
  String _playerName = 'Player';
  ThemeMode _themeMode = ThemeMode.system;
  bool _haptics = true;
  bool _firstClickSafety = true;
  bool _showTimer = true;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  String get playerName => _playerName;
  ThemeMode get themeMode => _themeMode;
  bool get haptics => _haptics;
  bool get firstClickSafety => _firstClickSafety;
  bool get showTimer => _showTimer;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        _playerName = (j['name'] as String?) ?? _playerName;
        _themeMode = _decodeThemeMode(j['theme'] as String?);
        _haptics = (j['haptics'] as bool?) ?? _haptics;
        _firstClickSafety =
            (j['firstClickSafety'] as bool?) ?? _firstClickSafety;
        _showTimer = (j['showTimer'] as bool?) ?? _showTimer;
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
        'theme': _encodeThemeMode(_themeMode),
        'haptics': _haptics,
        'firstClickSafety': _firstClickSafety,
        'showTimer': _showTimer,
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

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
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

  Future<void> resetAll() async {
    _playerName = 'Player';
    _themeMode = ThemeMode.system;
    _haptics = true;
    _firstClickSafety = true;
    _showTimer = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}

String _encodeThemeMode(ThemeMode m) => switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

ThemeMode _decodeThemeMode(String? s) => switch (s) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
