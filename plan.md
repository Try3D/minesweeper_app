# Minesweeper — High Scores & Settings Plan

## Home screen layout (target)

Top → bottom, all full-width brutalist buttons:

1. **NEW GRID** (primary red, large) — unchanged. Routes to `LevelsScreen` (difficulty pick).
2. **HIGH SCORES** (new prominent middle button, full-width, secondary color). Routes to `HighScoresScreen`.
3. **OPTIONS** (tertiary teal) — wire up to a real `SettingsScreen` (currently a no-op `onTap`).

Removed: the side-by-side `LEVELS` + `HIGH SCORES` row. `LevelsScreen` is reachable only via NEW GRID, which is fine — it's the natural flow.

## High scores screen

### Data model

```dart
class DifficultyScores {
  int? bestSeconds;
  int played;
  int won;
  List<WinEntry> recentWins; // capped at 10
}

class WinEntry {
  int seconds;
  DateTime date;
  String? playerName; // captured at time of win
}

class Scores {
  Map<Difficulty, DifficultyScores> byDifficulty;
}
```

### Storage

- `shared_preferences` (add to `pubspec.yaml`).
- Single key `"scores_v1"`, value is JSON-encoded `Scores`. Versioned key for future migrations.
- `ScoresStore` class:
  - `Future<Scores> load()` — returns empty `Scores` on first run.
  - `Future<void> recordWin(Difficulty, seconds, playerName)` — updates best, played, won, prepends to `recentWins`, trims to 10, saves.
  - `Future<void> recordLoss(Difficulty)` — increments played only.
  - `Future<void> reset()` — clears all.
  - Exposes a `ChangeNotifier` so screens auto-refresh.

### Hook into game

- `_handleTap` → `RevealResult.won` branch: call `ScoresStore.recordWin(...)`.
- `_handleTap` → `RevealResult.exploded` branch: call `ScoresStore.recordLoss(...)`.
- Pass `ScoresStore` (or read from `AppScope.of(context)`) into `GameScreen`.

### Screen layout

Stack of three difficulty cards (Beginner / Intermediate / Expert). Each card:

- Large best-time number (`mm:ss` or `--:--` if none)
- Win % (e.g., `11/18 — 61%`)
- Last 5 win times, smallest font, scrollable horizontally if overflow
- A subtle "tap to expand" → opens a modal with the full 10-entry history

Header: "HIGH SCORES" with the wobbly underline, a back button, and a small player-name chip showing current name.

Reset all scores button at bottom (destructive, red, confirm dialog).

## Settings screen

### Options to support

| Setting | Type | Default | Notes |
|---|---|---|---|
| Player name | text (max 16 chars) | "Player" | Used on high score entries; live-validated, trimmed |
| Dark mode | toggle | system | `system` / `light` / `dark` tri-state, since system-aware is the modern default |
| Haptics | toggle | on | Gates the four `HapticFeedback` calls in `game_screen.dart` |
| First-click safety | toggle | on | Already implemented in `Board`; expose to user |
| Show timer | toggle | on | Hides the timer HUD box for distraction-free play |
| Reset high scores | button (destructive) | — | Confirm dialog, calls `ScoresStore.reset()` |
| Reset settings | button (destructive) | — | Wipes `settings_v1` key |

Skip for now: sound (no audio code yet), animation speed, color scheme variants.

### Storage

- `shared_preferences`, key `"settings_v1"`, JSON-encoded.
- `SettingsStore extends ChangeNotifier` with typed getters for each option, `setX()` setters that persist.

### Dark mode implementation

Current pain point: every screen references `Palette.X` directly as `static const`. Two options:

**(a) Idiomatic Material:** migrate every `Palette.X` to `Theme.of(context).colorScheme.X` and define both `ThemeData` light/dark in `theme.dart`. Lots of churn (every file touched), but standard.

**(b) Runtime palette:** make `Palette` an instance fetched via `InheritedWidget` (e.g. `AppPalette.of(context).primary`). Less standard, but only `theme.dart` and the widgets that use *non-standard* tokens (`accentRed`, `surfaceLowest`, etc.) need touching meaningfully — the colorScheme-mappable tokens can be replaced with `Theme.of` lookups; the rest go through `AppPalette`.

**Decision:** go with (a). The non-standard tokens (`ink`, `accentRed`, `surfaceContainer`, `surfaceLowest`) get added to a `ThemeExtension<BrutalPalette>` so they ride along on `ThemeData`. Single source of truth, no parallel inheritance tree. The migration touches every screen file, but it's mechanical.

Steps:
1. Define `BrutalPalette extends ThemeExtension<BrutalPalette>` in `theme.dart` with the non-standard tokens. Two instances: `BrutalPalette.light`, `BrutalPalette.dark`.
2. Build `ThemeData buildLight()` and `ThemeData buildDark()`. Both register the corresponding `BrutalPalette` extension.
3. Replace all `Palette.primary` / `Palette.onSurface` etc. with `Theme.of(context).colorScheme.X`.
4. Replace `Palette.ink` / `Palette.accentRed` / `Palette.surfaceLowest` with `Theme.of(context).extension<BrutalPalette>()!.X`.
5. Add helper `context.brutal` extension to keep call sites short.
6. Delete the `Palette` class.

### State propagation

- `MinesweeperApp` becomes `StatefulWidget`.
- Holds two `ChangeNotifier`s: `SettingsStore`, `ScoresStore`. Both load from prefs in `initState`.
- Wraps `MaterialApp` in a `ListenableBuilder` listening to `SettingsStore` so `themeMode` rebuilds.
- An `AppScope` `InheritedWidget` exposes both stores to descendants. Helper `AppScope.of(context)` and `AppScope.settings(context)` getters.
- No third-party state lib (Provider, Riverpod, etc.) — keeps deps minimal.

## Files to create / modify

### New
- `lib/data/scores_store.dart` — `ScoresStore`, `Scores`, `DifficultyScores`, `WinEntry`.
- `lib/data/settings_store.dart` — `SettingsStore`.
- `lib/app_scope.dart` — `AppScope` InheritedWidget.
- `lib/screens/high_scores_screen.dart`.
- `lib/screens/settings_screen.dart`.

### Modified
- `pubspec.yaml` — add `shared_preferences: ^2.x`.
- `lib/main.dart` — `StatefulWidget`, init stores, wrap `MaterialApp` in `AppScope` + `ListenableBuilder`.
- `lib/theme.dart` — `BrutalPalette` ThemeExtension, light + dark themes.
- `lib/screens/menu_screen.dart` — drop `LEVELS` button, promote `HIGH SCORES` to full-width middle, wire `OPTIONS` to settings.
- `lib/screens/game_screen.dart` — call `ScoresStore.recordWin/Loss`, gate haptics on settings, gate timer HUD on settings.
- All other screens — migrate `Palette.X` to `Theme.of(context)` / `BrutalPalette`.

## Implementation order (PRs)

1. Add `shared_preferences`. Create `ScoresStore`, `SettingsStore`, `AppScope`. Wire into `main.dart`. (No UI yet — verify load/save in a smoke test.)
2. `HighScoresScreen` skeleton. Hook `ScoresStore.recordWin/Loss` from `game_screen.dart`. Update menu screen layout (drop LEVELS, promote HIGH SCORES).
3. `SettingsScreen` with player name + reset buttons. Wire OPTIONS button.
4. Theme migration: `BrutalPalette` ThemeExtension, build dark theme, switch all references. Add dark-mode toggle to settings. (This is the largest single PR — best done last so earlier PRs don't have to know about themed colors.)
5. Wire remaining settings (haptics, show-timer, first-click-safety) into game logic.

## Open questions to revisit

- Player name: prompt on first launch or default to "Player" silently? (Plan: default silently, surface on settings screen.) YES, I Approve
- Should losses count toward "played"? (Plan: yes — standard convention.) Sure?
- Trophy/medal icons on high score cards or keep type-only? (Plan: type-only, brutalist.) Brutalist
- Custom difficulty: out of scope — would require a configurator UI and per-config score buckets. Yes, implement this inside the new grid options.
