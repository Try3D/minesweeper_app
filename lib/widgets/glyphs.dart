import 'package:flutter/material.dart';

enum SmileyState { idle, surprise, won, lost }

class SmileyFace extends StatelessWidget {
  final double size;
  final SmileyState state;
  const SmileyFace({super.key, required this.size, required this.state});

  String get _asset {
    switch (state) {
      case SmileyState.idle:
        return 'assets/images/smiley-face.png';
      case SmileyState.surprise:
        return 'assets/images/o-face.png';
      case SmileyState.won:
        return 'assets/images/cool-face.png';
      case SmileyState.lost:
        return 'assets/images/dead-face.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: size,
      height: size,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
    );
  }
}

class MineGlyph extends StatelessWidget {
  final double size;
  final bool wrong;
  const MineGlyph({super.key, required this.size, this.wrong = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      wrong ? 'assets/images/wrong-bomb.png' : 'assets/images/bomb.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
    );
  }
}

class FlagGlyph extends StatelessWidget {
  final double size;
  const FlagGlyph({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/flag.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
    );
  }
}
