import 'dart:math';

enum GameStatus { ready, playing, won, lost }

class Cell {
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  bool exploded = false;
  int adjacent = 0;
}

class Difficulty {
  final String name;
  final int width;
  final int height;
  final int mines;
  const Difficulty(this.name, this.width, this.height, this.mines);

  static const beginner = Difficulty('Beginner', 9, 9, 10);
  static const intermediate = Difficulty('Intermediate', 16, 16, 40);
  static const expert = Difficulty('Expert', 30, 16, 99);
  static const all = [beginner, intermediate, expert];
}

class Board {
  final int width;
  final int height;
  final int mineCount;
  final bool safeFirstClick;
  final Random _rng;

  late List<List<Cell>> grid;
  GameStatus status = GameStatus.ready;
  bool _minesPlaced = false;
  int revealedCount = 0;
  int flagCount = 0;

  Board({
    required this.width,
    required this.height,
    required this.mineCount,
    this.safeFirstClick = true,
    int? seed,
  }) : _rng = Random(seed) {
    _reset();
  }

  Board.fromDifficulty(Difficulty d, {int? seed, this.safeFirstClick = true})
      : width = d.width,
        height = d.height,
        mineCount = d.mines,
        _rng = Random(seed) {
    _reset();
  }

  void _reset() {
    grid = List.generate(height, (_) => List.generate(width, (_) => Cell()));
    status = GameStatus.ready;
    _minesPlaced = false;
    revealedCount = 0;
    flagCount = 0;
  }

  void reset() => _reset();

  bool _inBounds(int r, int c) => r >= 0 && r < height && c >= 0 && c < width;

  Iterable<List<int>> _neighbors(int r, int c) sync* {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = r + dr, nc = c + dc;
        if (_inBounds(nr, nc)) yield [nr, nc];
      }
    }
  }

  // Place mines avoiding the first-clicked cell AND its neighbors so the
  // first reveal triggers a flood-fill. For dense boards we cap retries
  // and fall back to first-cell-safe-only.
  void _placeMines(int safeR, int safeC) {
    if (!safeFirstClick) {
      for (final row in grid) {
        for (final cell in row) {
          cell.isMine = false;
          cell.adjacent = 0;
        }
      }
      int placed = 0;
      while (placed < mineCount) {
        final idx = _rng.nextInt(width * height);
        final r = idx ~/ width, c = idx % width;
        if (grid[r][c].isMine) continue;
        grid[r][c].isMine = true;
        placed++;
      }
      _computeAdjacency();
      _minesPlaced = true;
      return;
    }
    final maxAttempts = 50;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // clear
      for (final row in grid) {
        for (final cell in row) {
          cell.isMine = false;
          cell.adjacent = 0;
        }
      }
      final forbidden = <int>{};
      forbidden.add(safeR * width + safeC);
      // try to also forbid neighbors for the zero-opening guarantee
      for (final n in _neighbors(safeR, safeC)) {
        forbidden.add(n[0] * width + n[1]);
      }
      // If too many mines for the forbidden zone, drop neighbor forbids.
      final available = width * height - forbidden.length;
      if (available < mineCount) {
        forbidden
          ..clear()
          ..add(safeR * width + safeC);
      }
      int placed = 0;
      while (placed < mineCount) {
        final idx = _rng.nextInt(width * height);
        if (forbidden.contains(idx)) continue;
        final r = idx ~/ width, c = idx % width;
        if (grid[r][c].isMine) continue;
        grid[r][c].isMine = true;
        placed++;
      }
      _computeAdjacency();
      // Accept if first cell would flood (adjacent == 0) or last attempt.
      if (grid[safeR][safeC].adjacent == 0 || attempt == maxAttempts - 1) {
        _minesPlaced = true;
        return;
      }
    }
  }

  void _computeAdjacency() {
    for (int r = 0; r < height; r++) {
      for (int c = 0; c < width; c++) {
        if (grid[r][c].isMine) continue;
        int count = 0;
        for (final n in _neighbors(r, c)) {
          if (grid[n[0]][n[1]].isMine) count++;
        }
        grid[r][c].adjacent = count;
      }
    }
  }

  RevealResult reveal(int r, int c) {
    if (status == GameStatus.won || status == GameStatus.lost) return RevealResult.noop;
    if (!_inBounds(r, c)) return RevealResult.noop;
    final cell = grid[r][c];
    if (cell.isFlagged) return RevealResult.noop;

    if (!_minesPlaced) {
      _placeMines(r, c);
      status = GameStatus.playing;
    }

    if (cell.isRevealed) {
      // Chord: revealed numbered cell, if flag count == number, reveal others.
      return _chord(r, c);
    }

    if (cell.isMine) {
      cell.isRevealed = true;
      cell.exploded = true;
      status = GameStatus.lost;
      _revealAllMines();
      return RevealResult.exploded;
    }

    _floodReveal(r, c);
    _checkWin();
    return status == GameStatus.won ? RevealResult.won : RevealResult.revealed;
  }

  void _floodReveal(int startR, int startC) {
    final queue = <List<int>>[
      [startR, startC]
    ];
    while (queue.isNotEmpty) {
      final p = queue.removeLast();
      final r = p[0], c = p[1];
      final cell = grid[r][c];
      if (cell.isRevealed || cell.isFlagged || cell.isMine) continue;
      cell.isRevealed = true;
      revealedCount++;
      if (cell.adjacent == 0) {
        for (final n in _neighbors(r, c)) {
          final nc = grid[n[0]][n[1]];
          if (!nc.isRevealed && !nc.isMine && !nc.isFlagged) {
            queue.add(n);
          }
        }
      }
    }
  }

  RevealResult _chord(int r, int c) {
    final cell = grid[r][c];
    if (cell.adjacent == 0) return RevealResult.noop;
    int flags = 0;
    for (final n in _neighbors(r, c)) {
      if (grid[n[0]][n[1]].isFlagged) flags++;
    }
    if (flags != cell.adjacent) return RevealResult.noop;
    bool exploded = false;
    for (final n in _neighbors(r, c)) {
      final nc = grid[n[0]][n[1]];
      if (nc.isFlagged || nc.isRevealed) continue;
      if (nc.isMine) {
        nc.isRevealed = true;
        nc.exploded = true;
        exploded = true;
      } else {
        _floodReveal(n[0], n[1]);
      }
    }
    if (exploded) {
      status = GameStatus.lost;
      _revealAllMines();
      return RevealResult.exploded;
    }
    _checkWin();
    return status == GameStatus.won ? RevealResult.won : RevealResult.revealed;
  }

  void _revealAllMines() {
    for (final row in grid) {
      for (final cell in row) {
        if (cell.isMine) cell.isRevealed = true;
      }
    }
  }

  bool toggleFlag(int r, int c) {
    if (status == GameStatus.won || status == GameStatus.lost) return false;
    final cell = grid[r][c];
    if (cell.isRevealed) return false;
    if (cell.isFlagged) {
      cell.isFlagged = false;
      flagCount--;
      return true;
    }
    if (flagCount >= mineCount) return false;
    cell.isFlagged = true;
    flagCount++;
    return true;
  }

  void _checkWin() {
    final total = width * height;
    if (total - revealedCount == mineCount && status != GameStatus.lost) {
      status = GameStatus.won;
      // auto-flag remaining mines
      for (final row in grid) {
        for (final cell in row) {
          if (cell.isMine && !cell.isFlagged) {
            cell.isFlagged = true;
            flagCount++;
          }
        }
      }
    }
  }

  int get minesRemaining => mineCount - flagCount;

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'mineCount': mineCount,
      'safeFirstClick': safeFirstClick,
      'status': status.name,
      'minesPlaced': _minesPlaced,
      'revealedCount': revealedCount,
      'flagCount': flagCount,
      'grid': List.generate(
        height,
        (r) => List.generate(width, (c) {
          final cell = grid[r][c];
          return {
            'mine': cell.isMine,
            'revealed': cell.isRevealed,
            'flagged': cell.isFlagged,
            'exploded': cell.exploded,
            'adj': cell.adjacent,
          };
        }),
      ),
    };
  }

  static Board fromJson(Map<String, dynamic> j) {
    final board = Board(
      width: j['width'] as int,
      height: j['height'] as int,
      mineCount: j['mineCount'] as int,
      safeFirstClick: j['safeFirstClick'] as bool? ?? true,
    );
    board.status = GameStatus.values.firstWhere(
      (s) => s.name == j['status'],
      orElse: () => GameStatus.playing,
    );
    board._minesPlaced = j['minesPlaced'] as bool? ?? true;
    board.revealedCount = j['revealedCount'] as int? ?? 0;
    board.flagCount = j['flagCount'] as int? ?? 0;
    final rawGrid = j['grid'] as List<dynamic>;
    for (int r = 0; r < board.height; r++) {
      final rawRow = rawGrid[r] as List<dynamic>;
      for (int c = 0; c < board.width; c++) {
        final raw = rawRow[c] as Map<String, dynamic>;
        final cell = board.grid[r][c];
        cell.isMine = raw['mine'] as bool? ?? false;
        cell.isRevealed = raw['revealed'] as bool? ?? false;
        cell.isFlagged = raw['flagged'] as bool? ?? false;
        cell.exploded = raw['exploded'] as bool? ?? false;
        cell.adjacent = raw['adj'] as int? ?? 0;
      }
    }
    return board;
  }
}

enum RevealResult { noop, revealed, exploded, won }
