import 'package:flutter/material.dart';
import '../theme.dart';

class SketchButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color? background;
  final Color? foreground;
  final EdgeInsetsGeometry padding;
  final double seed;
  final double borderWidth;

  const SketchButton({
    super.key,
    required this.onTap,
    required this.child,
    this.background,
    this.foreground,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    this.seed = 0,
    this.borderWidth = 3,
  });

  @override
  State<SketchButton> createState() => _SketchButtonState();
}

class _SketchButtonState extends State<SketchButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    final bg = widget.background ?? ac.surfaceContainerHighest;
    final fg = widget.foreground ?? cs.onSurface;
    final ink = ac.ink;
    final shift = _down ? 2.0 : 0.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        transform: Matrix4.translationValues(shift, shift, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: ink, width: widget.borderWidth),
          boxShadow: [
            BoxShadow(
              color: ink,
              offset: Offset(_down ? 2 : 4, _down ? 2 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: fg),
          child: IconTheme(
            data: IconThemeData(color: fg),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class PaperBackground extends StatelessWidget {
  final Widget child;
  const PaperBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final gridColor = AppColors.of(context).ink.withValues(alpha: 0.08);
    return Container(
      color: bg,
      child: CustomPaint(
        painter: _PaperGridPainter(color: gridColor),
        child: child,
      ),
    );
  }
}

class _PaperGridPainter extends CustomPainter {
  final Color color;
  const _PaperGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperGridPainter old) => old.color != color;
}

// Diagonal hatching for unrevealed cells.
class HatchPainter extends CustomPainter {
  final Color color;
  final double spacing;
  HatchPainter({this.color = const Color(0x331B1C15), this.spacing = 6});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final diag = size.width + size.height;
    for (double i = -size.height; i < diag; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Wobbly underline drawn beneath a title.
class WobblyUnderline extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double thickness;
  const WobblyUnderline({
    super.key,
    required this.child,
    this.color,
    this.thickness = 4,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppColors.of(context).ink;
    return CustomPaint(
      foregroundPainter: _WobblyUnderlinePainter(
          color: resolvedColor, thickness: thickness),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: child,
      ),
    );
  }
}

class _WobblyUnderlinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  _WobblyUnderlinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final y = size.height - thickness / 2;
    path.moveTo(0, y);
    final waves = (size.width / 12).floor().clamp(4, 60);
    for (int i = 1; i <= waves; i++) {
      final x = size.width * i / waves;
      final dy = (i.isEven ? -2.0 : 2.0);
      path.quadraticBezierTo(
        x - size.width / waves / 2,
        y + dy,
        x,
        y,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
