import 'package:flutter/material.dart';
import '../theme.dart';

// Classic Win9x chiseled bevel. `raised` paints the highlight on
// the top/left and shadow on bottom/right; `false` reverses it for
// the "pressed" / sunken look.
class BevelBox extends StatelessWidget {
  final Widget child;
  final bool raised;
  final double thickness;
  final Color? fill;
  final EdgeInsetsGeometry padding;

  const BevelBox({
    super.key,
    required this.child,
    this.raised = true,
    this.thickness = 3,
    this.fill,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return CustomPaint(
      painter: _BevelPainter(
        raised: raised,
        thickness: thickness,
        fill: fill ?? ac.silver,
        light: ac.bevelLight,
        dark: ac.bevelDark,
      ),
      child: Padding(
        padding: EdgeInsets.all(thickness).add(padding),
        child: child,
      ),
    );
  }
}

class _BevelPainter extends CustomPainter {
  final bool raised;
  final double thickness;
  final Color fill;
  final Color light;
  final Color dark;

  const _BevelPainter({
    required this.raised,
    required this.thickness,
    required this.fill,
    required this.light,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = thickness;
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);
    final topLeft = raised ? light : dark;
    final bottomRight = raised ? dark : light;
    final lp = Paint()..color = topLeft;
    final dp = Paint()..color = bottomRight;
    // top (full width) and left (full height) own their corners.
    canvas.drawRect(Rect.fromLTWH(0, 0, w, t), lp);
    canvas.drawRect(Rect.fromLTWH(0, 0, t, h), lp);
    // bottom and right are inset by t so they don't overlap top/left.
    canvas.drawRect(Rect.fromLTWH(t, h - t, w - t, t), dp);
    canvas.drawRect(Rect.fromLTWH(w - t, t, t, h - t), dp);
  }

  @override
  bool shouldRepaint(covariant _BevelPainter old) =>
      old.raised != raised ||
      old.thickness != thickness ||
      old.fill != fill ||
      old.light != light ||
      old.dark != dark;
}

// A tappable raised bevel button that depresses (sunken) on press.
class BevelButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double thickness;
  final Color? fill;

  const BevelButton({
    super.key,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.thickness = 3,
    this.fill,
  });

  @override
  State<BevelButton> createState() => _BevelButtonState();
}

class _BevelButtonState extends State<BevelButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: widget.onTap,
      child: BevelBox(
        raised: !_down,
        thickness: widget.thickness,
        fill: widget.fill,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}

// Back button + centered title on one row, used by secondary screens.
class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const ScreenHeader({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BevelButton(
            onTap: onBack,
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_back, size: 18, color: Palette.ink),
          ),
        ),
        BevelBox(
          raised: true,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

// The full board frame: outer raised bevel containing a sunken inner pane.
class BoardFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const BoardFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return BevelBox(
      raised: true,
      thickness: 3,
      child: Padding(
        padding: padding,
        child: BevelBox(raised: false, thickness: 3, child: child),
      ),
    );
  }
}
