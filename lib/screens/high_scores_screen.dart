import 'package:flutter/material.dart';
import '../app_scope.dart';
import '../data/scores_store.dart';
import '../game/board.dart';
import '../theme.dart';
import '../widgets/bevel.dart';
import '../widgets/led_display.dart';

class HighScoresScreen extends StatelessWidget {
  const HighScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = AppScope.scoresOf(context);
    final ac = AppColors.of(context);

    return Scaffold(
      backgroundColor: ac.silver,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: scores,
          builder: (context, _) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeader(
                    title: 'HIGH SCORES',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 22),
                  for (final d in Difficulty.all) ...[
                    _ScoreCard(
                      difficulty: d,
                      stats: scores.forDifficulty(d),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final Difficulty difficulty;
  final DifficultyScores stats;
  const _ScoreCard({required this.difficulty, required this.stats});

  @override
  Widget build(BuildContext context) {
    final best = stats.bestSeconds;
    final winRate = stats.played == 0
        ? '--'
        : '${stats.won}/${stats.played}';
    return BevelBox(
      raised: true,
      thickness: 3,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            difficulty.name.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LedDisplay(
                value: best ?? 0,
                digitWidth: 22,
                digitHeight: 36,
              ),
              const SizedBox(width: 10),
              Text(
                best == null ? 'NO RECORD' : 'BEST',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WIN/PLAYED',
                  style: Theme.of(context).textTheme.labelLarge),
              Text(winRate, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          if (stats.recentWins.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('RECENT WINS',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final w in stats.recentWins.take(5))
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: BevelBox(
                        raised: false,
                        thickness: 2,
                        fill: Palette.cellRevealed,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Text(
                          _format(w.seconds),
                          style:
                              Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }
}
