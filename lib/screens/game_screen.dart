import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_scope.dart';
import '../game/board.dart';
import '../theme.dart';
import '../widgets/cell_widget.dart';
import '../widgets/sketch.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Board _board;
  Timer? _timer;
  int _seconds = 0;
  final TransformationController _viewer = TransformationController();
  bool _viewerCentered = false;
  bool _boardInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_boardInitialized) {
      final safe = AppScope.settingsOf(context).firstClickSafety;
      _board = Board.fromDifficulty(widget.difficulty, safeFirstClick: safe);
      _boardInitialized = true;
    }
  }

  bool _hapticsOn() => AppScope.settingsOf(context).haptics;
  void _haptic(VoidCallback fn) {
    if (_hapticsOn()) fn();
  }

  void _centerBoard(Size viewport, double boardW, double boardH) {
    if (_viewerCentered) return;
    final dx = (viewport.width - boardW) / 2;
    final dy = (viewport.height - boardH) / 2;
    _viewer.value = Matrix4.identity()..translateByDouble(dx, dy, 0, 1);
    _viewerCentered = true;
  }

  void _resetViewer() {
    _viewerCentered = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _viewer.dispose();
    super.dispose();
  }

  void _maybeStartTimer() {
    if (_timer == null && _board.status == GameStatus.playing) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        if (_board.status != GameStatus.playing) {
          _timer?.cancel();
          _timer = null;
          return;
        }
        setState(() => _seconds++);
      });
    }
  }

  void _reset() {
    final safe = AppScope.settingsOf(context).firstClickSafety;
    setState(() {
      _board = Board.fromDifficulty(widget.difficulty, safeFirstClick: safe);
      _seconds = 0;
      _timer?.cancel();
      _timer = null;
      _resetViewer();
    });
    _haptic(HapticFeedback.lightImpact);
  }

  void _handleTap(int r, int c) {
    if (_board.status == GameStatus.won || _board.status == GameStatus.lost) return;
    final result = _board.reveal(r, c);
    setState(() {});
    _maybeStartTimer();
    switch (result) {
      case RevealResult.revealed:
        _haptic(HapticFeedback.selectionClick);
        break;
      case RevealResult.exploded:
        _haptic(HapticFeedback.heavyImpact);
        AppScope.scoresOf(context).recordLoss(widget.difficulty);
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) _showEndDialog(won: false);
        });
        break;
      case RevealResult.won:
        _haptic(HapticFeedback.lightImpact);
        Future.delayed(const Duration(milliseconds: 80), () {
          if (_hapticsOn()) HapticFeedback.lightImpact();
        });
        AppScope.scoresOf(context).recordWin(
          widget.difficulty,
          seconds: _seconds,
          playerName: AppScope.settingsOf(context).playerName,
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showEndDialog(won: true);
        });
        break;
      case RevealResult.noop:
        break;
    }
  }

  void _handleLongPress(int r, int c) {
    if (_board.status == GameStatus.won || _board.status == GameStatus.lost) return;
    final changed = _board.toggleFlag(r, c);
    if (changed) {
      _haptic(HapticFeedback.mediumImpact);
      setState(() {});
      _maybeStartTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    const cellSize = 40.0;
    final boardW = widget.difficulty.width * cellSize;
    final boardH = widget.difficulty.height * cellSize;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen infinite-canvas board
          PaperBackground(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (!_viewerCentered) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _centerBoard(constraints.biggest, boardW, boardH);
                  });
                }
                return InteractiveViewer(
                  transformationController: _viewer,
                  constrained: false,
                  minScale: 0.3,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: SizedBox(
                    width: boardW,
                    height: boardH,
                    child: _buildGrid(cellSize),
                  ),
                );
              },
            ),
          ),
          // HUD overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SketchButton(
                          onTap: () => Navigator.of(context).pop(),
                          seed: 11,
                          padding: const EdgeInsets.all(10),
                          child: const Icon(Icons.arrow_back, size: 22),
                        ),
                        const SizedBox(width: 10),
                        IgnorePointer(
                          child: _HudBox(
                            child: Text(
                              _board.minesRemaining.toString().padLeft(3, '0'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: cs.primary,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (AppScope.settingsOf(context).showTimer)
                          IgnorePointer(
                            child: _HudBox(
                              child: Text(
                                _formatTime(_seconds),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(double cellSize) {
    final rows = <Widget>[];
    for (int r = 0; r < widget.difficulty.height; r++) {
      final row = <Widget>[];
      for (int c = 0; c < widget.difficulty.width; c++) {
        row.add(GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(r, c),
          onLongPress: () => _handleLongPress(r, c),
          child: CellWidget(
            cell: _board.grid[r][c],
            size: cellSize,
            seed: r * widget.difficulty.width + c,
          ),
        ));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: row));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  void _showEndDialog({required bool won}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        final ac = AppColors.of(ctx);
        final cs = Theme.of(ctx).colorScheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: ac.ink, width: 4),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  won ? Icons.emoji_events : Icons.dangerous,
                  size: 96,
                  color: won ? cs.primary : ac.ink,
                ),
                const SizedBox(height: 12),
                Transform.rotate(
                  angle: -0.03,
                  child: Text(
                    won ? 'MISSION ACCOMPLISHED' : 'BOOM!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  won
                      ? 'Sector cleared. No casualties.'
                      : 'You stepped on the ink.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ac.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _StatBox(label: 'Time', value: _formatTime(_seconds)),
                    const SizedBox(width: 8),
                    _StatBox(
                      label: 'Mines',
                      value: '${_board.flagCount}/${_board.mineCount}',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SketchButton(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _reset();
                        },
                        background: cs.primary,
                        foreground: cs.onPrimary,
                        seed: 31,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Center(
                          child: Text('PLAY AGAIN',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SketchButton(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        background: cs.surface,
                        seed: 32,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Center(
                          child: Text('LEVELS',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HudBox extends StatelessWidget {
  final Widget child;
  const _HudBox({required this.child});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ac.surfaceLowest,
        border: Border.all(color: ac.ink, width: 2.5),
        boxShadow: [
          BoxShadow(color: ac.ink, offset: const Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: ac.surfaceContainer,
          border: Border.all(color: ac.ink, width: 2.5),
        ),
        child: Column(
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: ac.onSurfaceVariant,
                    letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
