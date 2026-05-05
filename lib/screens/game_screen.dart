import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_scope.dart';
import '../game/board.dart';
import '../theme.dart';
import '../widgets/bevel.dart';
import '../widgets/cell_widget.dart';
import '../widgets/glyphs.dart';
import '../widgets/led_display.dart';

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
  bool _pressing = false;

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
      _viewerCentered = false;
      _pressing = false;
    });
    _haptic(HapticFeedback.lightImpact);
  }

  void _handleTap(int r, int c) {
    if (_board.status == GameStatus.won || _board.status == GameStatus.lost) {
      return;
    }
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
    if (_board.status == GameStatus.won || _board.status == GameStatus.lost) {
      return;
    }
    final changed = _board.toggleFlag(r, c);
    if (changed) {
      _haptic(HapticFeedback.mediumImpact);
      setState(() {});
      _maybeStartTimer();
    }
  }

  SmileyState _smileyState() {
    if (_board.status == GameStatus.lost) return SmileyState.lost;
    if (_board.status == GameStatus.won) return SmileyState.won;
    if (_pressing) return SmileyState.surprise;
    return SmileyState.idle;
  }

  @override
  Widget build(BuildContext context) {
    const cellSize = 30.0;
    final boardW = widget.difficulty.width * cellSize;
    final boardH = widget.difficulty.height * cellSize;
    final ac = AppColors.of(context);
    final showTimer = AppScope.settingsOf(context).showTimer;

    return Scaffold(
      backgroundColor: ac.silver,
      body: SafeArea(
        child: Column(
          children: [
            // Top toolbar: back button + classic HUD bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Row(
                children: [
                  BevelButton(
                    onTap: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back,
                        size: 18, color: Palette.ink),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _Hud(
                    minesRemaining: _board.minesRemaining,
                    seconds: _seconds,
                    showTimer: showTimer,
                    smileyState: _smileyState(),
                    onSmileyTap: _reset,
                  )),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: BoardFrame(
                  padding: const EdgeInsets.all(2),
                  child: ClipRect(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (!_viewerCentered) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _centerBoard(
                                constraints.biggest, boardW, boardH);
                          });
                        }
                        return InteractiveViewer(
                          transformationController: _viewer,
                          constrained: false,
                          minScale: 0.3,
                          maxScale: 4.0,
                          boundaryMargin:
                              const EdgeInsets.all(double.infinity),
                          child: SizedBox(
                            width: boardW,
                            height: boardH,
                            child: _buildGrid(cellSize),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          onTapDown: (_) => setState(() => _pressing = true),
          onTapUp: (_) => setState(() => _pressing = false),
          onTapCancel: () => setState(() => _pressing = false),
          onTap: () => _handleTap(r, c),
          onLongPress: () => _handleLongPress(r, c),
          child: RepaintBoundary(
            child: CellWidget(cell: _board.grid[r][c], size: cellSize),
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
                  child: SmileyFace(
                    size: 31,
                    state: won ? SmileyState.won : SmileyState.lost,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  won ? 'YOU WIN' : 'GAME OVER',
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  won
                      ? 'TIME: ${_formatTime(_seconds)}'
                      : 'BETTER LUCK NEXT TIME',
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: BevelButton(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _reset();
                        },
                        child: const Center(child: Text('PLAY AGAIN')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BevelButton(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Center(child: Text('LEVELS')),
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

class _SmileyButton extends StatefulWidget {
  final SmileyState state;
  final VoidCallback onTap;
  const _SmileyButton({required this.state, required this.onTap});

  @override
  State<_SmileyButton> createState() => _SmileyButtonState();
}

class _SmileyButtonState extends State<_SmileyButton> {
  // Reference CSS: width/height 35px, 2px white top/left, 2px #7B7B7B
  // bottom/right borders, no padding — sprite sits flush against bevel.
  // On press, the bevel inverts to show a sunken button (classic Win9x).
  static const _faceSize = 35.0;
  static const _dark = Color(0xFF7B7B7B);
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final topLeft = _down ? _dark : Colors.white;
    final bottomRight = _down ? Colors.white : _dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: Container(
        width: _faceSize,
        height: _faceSize,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: topLeft, width: 2),
            left: BorderSide(color: topLeft, width: 2),
            right: BorderSide(color: bottomRight, width: 2),
            bottom: BorderSide(color: bottomRight, width: 2),
          ),
        ),
        child: SmileyFace(size: _faceSize - 4, state: widget.state),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  final int minesRemaining;
  final int seconds;
  final bool showTimer;
  final SmileyState smileyState;
  final VoidCallback onSmileyTap;

  const _Hud({
    required this.minesRemaining,
    required this.seconds,
    required this.showTimer,
    required this.smileyState,
    required this.onSmileyTap,
  });

  @override
  Widget build(BuildContext context) {
    return BevelBox(
      raised: true,
      thickness: 3,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LedDisplay(value: minesRemaining),
          _SmileyButton(state: smileyState, onTap: onSmileyTap),
          showTimer
              ? LedDisplay(value: seconds > 999 ? 999 : seconds)
              : const SizedBox(width: 60),
        ],
      ),
    );
  }
}
