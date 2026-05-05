import 'package:flutter/material.dart';
import '../game/board.dart';
import '../theme.dart';
import 'bevel.dart';
import 'glyphs.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final double size;

  const CellWidget({super.key, required this.cell, required this.size});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);

    if (cell.isRevealed) {
      if (cell.isMine) {
        return _RevealedCell(
          size: size,
          background: cell.exploded ? Palette.mineRed : ac.cellRevealed,
          child: MineGlyph(size: size * 0.78),
        );
      }
      return _RevealedCell(
        size: size,
        background: ac.cellRevealed,
        child: cell.adjacent == 0
            ? const SizedBox()
            : Text(
                '${cell.adjacent}',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: size * 0.45,
                  color: numberColor(cell.adjacent),
                ),
              ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: BevelBox(
        raised: true,
        thickness: (size * 0.075).clamp(2.0, 4.0),
        fill: ac.silver,
        child: Center(
          child: cell.isFlagged ? FlagGlyph(size: size * 0.72) : null,
        ),
      ),
    );
  }
}

class _RevealedCell extends StatelessWidget {
  final double size;
  final Color background;
  final Widget? child;
  const _RevealedCell({
    required this.size,
    required this.background,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(color: ac.cellRevealedBorder, width: 1),
          left: BorderSide(color: ac.cellRevealedBorder, width: 1),
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
