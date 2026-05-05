import 'package:flutter/material.dart';
import '../game/board.dart';
import '../theme.dart';
import 'sketch.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final double size;
  final int seed;

  const CellWidget({
    super.key,
    required this.cell,
    required this.size,
    required this.seed,
  });

  Color _colorFor(int adjacent, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (adjacent) {
      1 => cs.secondary,
      2 => cs.tertiary,
      3 => cs.primary,
      4 => dark ? const Color(0xFF5A85C0) : const Color(0xFF30476A),
      5 => dark ? const Color(0xFFCF4040) : const Color(0xFF8B0000),
      6 => dark ? const Color(0xFF00B09E) : const Color(0xFF008376),
      7 => AppColors.of(context).ink,
      8 => dark ? const Color(0xFF9E7A79) : const Color(0xFF5B403F),
      _ => cs.onSurface,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    final sz = size;

    if (cell.isRevealed) {
      if (cell.isMine) {
        return _RevealedMine(size: sz, exploded: cell.exploded);
      }
      return Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
          color: ac.surfaceLowest,
          border: Border.all(color: ac.outlineVariant, width: 1.2),
        ),
        alignment: Alignment.center,
        child: cell.adjacent == 0
            ? const SizedBox()
            : Text(
                '${cell.adjacent}',
                style: TextStyle(
                  fontSize: sz * 0.5,
                  fontWeight: FontWeight.w900,
                  color: _colorFor(cell.adjacent, context),
                ),
              ),
      );
    }
    // Unrevealed: hatched, sharp brutalist border.
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        color: ac.surfaceContainer,
        border: Border.all(color: ac.ink, width: 1.6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!cell.isFlagged)
            Positioned.fill(
              child: CustomPaint(
                painter: HatchPainter(
                  color: ac.ink.withValues(alpha: 0.18),
                ),
              ),
            ),
          if (cell.isFlagged)
            Icon(
              Icons.tour,
              size: sz * 0.7,
              color: cs.primary,
            ),
        ],
      ),
    );
  }
}

class _RevealedMine extends StatelessWidget {
  final double size;
  final bool exploded;
  const _RevealedMine({required this.size, required this.exploded});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: exploded ? cs.primary : ac.surfaceLowest,
        border: Border.all(color: ac.ink, width: 1.6),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.coronavirus,
        size: size * 0.75,
        color: exploded ? cs.onPrimary : ac.ink,
      ),
    );
  }
}
