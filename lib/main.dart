import 'package:flutter/material.dart';
import 'app_scope.dart';
import 'data/scores_store.dart';
import 'data/settings_store.dart';
import 'screens/menu_screen.dart';
import 'theme.dart';

void main() => runApp(const MinesweeperApp());

class MinesweeperApp extends StatefulWidget {
  const MinesweeperApp({super.key});

  @override
  State<MinesweeperApp> createState() => _MinesweeperAppState();
}

class _MinesweeperAppState extends State<MinesweeperApp> {
  final SettingsStore _settings = SettingsStore();
  final ScoresStore _scores = ScoresStore();

  @override
  void initState() {
    super.initState();
    _settings.load();
    _scores.load();
  }

  @override
  void dispose() {
    _settings.dispose();
    _scores.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      settings: _settings,
      scores: _scores,
      child: MaterialApp(
        title: 'Minesweeper',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const MenuScreen(),
      ),
    );
  }
}
