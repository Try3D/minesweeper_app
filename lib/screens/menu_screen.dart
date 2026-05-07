import 'package:flutter/material.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/bevel.dart';
import '../widgets/glyphs.dart';
import 'game_screen.dart';
import 'high_scores_screen.dart';
import 'levels_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _onPlay(BuildContext context) {
    final saved = AppScope.savedGameOf(context);
    if (!saved.hasSavedGame) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LevelsScreen()),
      );
      return;
    }
    _showContinueDialog(context);
  }

  void _showContinueDialog(BuildContext context) {
    final saved = AppScope.savedGameOf(context).current!;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: BevelBox(
            raised: true,
            thickness: 3,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CONTINUE?',
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  saved.difficulty.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: BevelButton(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => GameScreen(
                          difficulty: saved.difficulty,
                          savedBoard: saved.board,
                          savedSeconds: saved.seconds,
                        ),
                      ));
                    },
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text('CONTINUE',
                          style: Theme.of(ctx).textTheme.bodyLarge),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: BevelButton(
                    onTap: () {
                      AppScope.savedGameOf(context).clear();
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const LevelsScreen(),
                      ));
                    },
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text('NEW GAME',
                          style: Theme.of(ctx).textTheme.bodyLarge),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Scaffold(
      backgroundColor: ac.silver,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: ListenableBuilder(
                listenable: AppScope.savedGameOf(context),
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white, width: 2),
                            left: BorderSide(color: Colors.white, width: 2),
                            right:
                                BorderSide(color: Color(0xFF7B7B7B), width: 2),
                            bottom:
                                BorderSide(color: Color(0xFF7B7B7B), width: 2),
                          ),
                        ),
                        child: const SmileyFace(
                            size: 31, state: SmileyState.idle),
                      ),
                      const SizedBox(height: 16),
                      BevelBox(
                        raised: true,
                        thickness: 3,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Text(
                          'MINESWEEPER',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _MenuButton(
                        label: 'PLAY',
                        onTap: () => _onPlay(context),
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        label: 'HIGH SCORES',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HighScoresScreen()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        label: 'OPTIONS',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MenuButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BevelButton(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
