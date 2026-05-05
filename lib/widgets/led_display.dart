import 'package:flutter/material.dart';
import '../theme.dart';

// A 3-digit red 7-segment display, painted with CustomPainter so we
// don't ship a font. Negative or overflow values clamp to -99..999
// and render as classic Minesweeper does.
class LedDisplay extends StatelessWidget {
  final int value;
  final int digits;
  final double digitWidth;
  final double digitHeight;

  const LedDisplay({
    super.key,
    required this.value,
    this.digits = 3,
    this.digitWidth = 18,
    this.digitHeight = 30,
  });

  @override
  Widget build(BuildContext context) {
    int v = value;
    final maxV = _pow10(digits) - 1;
    final minV = -(_pow10(digits - 1) - 1);
    if (v > maxV) v = maxV;
    if (v < minV) v = minV;

    final isNeg = v < 0;
    final absStr = v.abs().toString().padLeft(digits, '0');
    final chars = <String>[];
    for (int i = 0; i < absStr.length; i++) {
      if (i == 0 && isNeg) {
        chars.add('-');
      } else {
        chars.add(absStr[i]);
      }
    }

    return Container(
      padding: const EdgeInsets.all(2),
      color: Palette.bevelDark,
      child: Container(
        color: Palette.ledBg,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final ch in chars)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: CustomPaint(
                  size: Size(digitWidth, digitHeight),
                  painter: _DigitPainter(char: ch),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}

// Segments:
//   _a_
//  f   b
//   -g-
//  e   c
//   _d_
class _DigitPainter extends CustomPainter {
  final String char;
  const _DigitPainter({required this.char});

  static const _map = <String, List<bool>>{
    '0': [true, true, true, true, true, true, false],
    '1': [false, true, true, false, false, false, false],
    '2': [true, true, false, true, true, false, true],
    '3': [true, true, true, true, false, false, true],
    '4': [false, true, true, false, false, true, true],
    '5': [true, false, true, true, false, true, true],
    '6': [true, false, true, true, true, true, true],
    '7': [true, true, true, false, false, false, false],
    '8': [true, true, true, true, true, true, true],
    '9': [true, true, true, true, false, true, true],
    '-': [false, false, false, false, false, false, true],
    ' ': [false, false, false, false, false, false, false],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final segs = _map[char] ?? _map[' ']!;
    final off = Paint()..color = Palette.ledOff;
    final on = Paint()..color = Palette.ledOn;
    final w = size.width;
    final h = size.height;
    final t = (w * 0.18).clamp(2.0, 6.0); // segment thickness
    final pad = t * 0.4;

    void hSeg(double y, bool active) {
      final p = Path()
        ..moveTo(t / 2 + pad, y - t / 2)
        ..lineTo(w - t / 2 - pad, y - t / 2)
        ..lineTo(w - pad, y)
        ..lineTo(w - t / 2 - pad, y + t / 2)
        ..lineTo(t / 2 + pad, y + t / 2)
        ..lineTo(pad, y)
        ..close();
      canvas.drawPath(p, active ? on : off);
    }

    void vSeg(double x, double y0, double y1, bool active) {
      final p = Path()
        ..moveTo(x - t / 2, y0 + pad)
        ..lineTo(x + t / 2, y0 + pad)
        ..lineTo(x + t / 2, y1 - pad)
        ..lineTo(x - t / 2, y1 - pad)
        ..close();
      canvas.drawPath(p, active ? on : off);
    }

    final yA = t / 2;
    final yG = h / 2;
    final yD = h - t / 2;
    // a (top)
    hSeg(yA, segs[0]);
    // g (middle)
    hSeg(yG, segs[6]);
    // d (bottom)
    hSeg(yD, segs[3]);
    // f (top-left vertical)
    vSeg(t / 2, yA, yG, segs[5]);
    // b (top-right vertical)
    vSeg(w - t / 2, yA, yG, segs[1]);
    // e (bottom-left vertical)
    vSeg(t / 2, yG, yD, segs[4]);
    // c (bottom-right vertical)
    vSeg(w - t / 2, yG, yD, segs[2]);
  }

  @override
  bool shouldRepaint(covariant _DigitPainter old) => old.char != char;
}
