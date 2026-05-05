import 'package:flutter/material.dart';
import '../app_scope.dart';
import '../data/scores_store.dart';
import '../game/board.dart';
import '../theme.dart';
import '../widgets/sketch.dart';

class HighScoresScreen extends StatelessWidget {
  const HighScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scores = AppScope.scoresOf(context);

    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: scores,
            builder: (context, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SketchButton(
                          onTap: () => Navigator.of(context).pop(),
                          seed: 7,
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.arrow_back, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: WobblyUnderline(
                        child: Text(
                          'High Scores',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    for (final d in Difficulty.all) ...[
                      _ScoreCard(
                        difficulty: d,
                        stats: scores.forDifficulty(d),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
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
    final ac = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    final best = stats.bestSeconds;
    final winRate = stats.played == 0
        ? '—'
        : '${stats.won}/${stats.played} · ${(stats.won * 100 / stats.played).round()}%';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ac.surfaceLowest,
        border: Border.all(color: ac.ink, width: 3),
        boxShadow: [
          BoxShadow(color: ac.ink, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            difficulty.name.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: ac.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                best == null ? '--:--' : _format(best),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -1.5,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  best == null ? 'NO RECORD' : 'BEST',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: ac.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 2, color: ac.ink),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WIN RATE',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: ac.onSurfaceVariant)),
              Text(winRate,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          if (stats.recentWins.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('RECENT WINS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: ac.onSurfaceVariant)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final w in stats.recentWins.take(5))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ac.surfaceContainer,
                          border: Border.all(color: ac.ink, width: 1.5),
                        ),
                        child: Text(
                          _format(w.seconds),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w900),
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
