import 'package:flutter/widgets.dart';
import 'data/scores_store.dart';
import 'data/settings_store.dart';

class AppScope extends InheritedWidget {
  final SettingsStore settings;
  final ScoresStore scores;

  const AppScope({
    super.key,
    required this.settings,
    required this.scores,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope.of called outside an AppScope');
    return scope!;
  }

  static SettingsStore settingsOf(BuildContext context) =>
      of(context).settings;
  static ScoresStore scoresOf(BuildContext context) => of(context).scores;

  @override
  bool updateShouldNotify(AppScope old) =>
      settings != old.settings || scores != old.scores;
}
