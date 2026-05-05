import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper_app/game/board.dart';

void main() {
  test('first reveal places mines and is safe', () {
    final b = Board(width: 9, height: 9, mineCount: 10, seed: 42);
    final result = b.reveal(4, 4);
    expect(result, isNot(RevealResult.exploded));
    expect(b.grid[4][4].isRevealed, true);
    expect(b.grid[4][4].isMine, false);
    expect(b.status, anyOf(GameStatus.playing, GameStatus.won));
  });

  test('first reveal triggers a flood fill (zero-cell guarantee)', () {
    final b = Board(width: 9, height: 9, mineCount: 10, seed: 7);
    b.reveal(0, 0);
    int revealed = 0;
    for (final row in b.grid) {
      for (final c in row) {
        if (c.isRevealed) revealed++;
      }
    }
    expect(revealed, greaterThan(1));
  });

  test('flag toggles and is capped at mine count', () {
    final b = Board(width: 5, height: 5, mineCount: 2, seed: 1);
    expect(b.toggleFlag(0, 0), true);
    expect(b.toggleFlag(0, 1), true);
    expect(b.toggleFlag(0, 2), false); // cap reached
    expect(b.flagCount, 2);
    expect(b.toggleFlag(0, 0), true); // unflag
    expect(b.flagCount, 1);
  });

  test('revealing a mine ends the game', () {
    final b = Board(width: 4, height: 4, mineCount: 1, seed: 2);
    // First click safe cell
    b.reveal(0, 0);
    // Find a mine and reveal it
    int? mr, mc;
    for (int r = 0; r < 4 && mr == null; r++) {
      for (int c = 0; c < 4; c++) {
        if (b.grid[r][c].isMine) {
          mr = r;
          mc = c;
          break;
        }
      }
    }
    expect(mr, isNotNull);
    final res = b.reveal(mr!, mc!);
    expect(res, RevealResult.exploded);
    expect(b.status, GameStatus.lost);
  });

  test('clearing all non-mine cells wins', () {
    final b = Board(width: 3, height: 3, mineCount: 1, seed: 5);
    b.reveal(0, 0);
    // Reveal every non-mine cell
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (!b.grid[r][c].isMine && !b.grid[r][c].isRevealed) {
          b.reveal(r, c);
        }
      }
    }
    expect(b.status, GameStatus.won);
  });
}
