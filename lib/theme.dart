import 'package:flutter/material.dart';

// Classic Windows 95/98 Minesweeper palette.
class Palette {
  static const silver = Color(0xFFC0C0C0);
  static const silverLight = Color(0xFFDFDFDF);
  static const bevelLight = Color(0xFFFFFFFF);
  static const bevelDark = Color(0xFF808080);
  static const bevelDeep = Color(0xFF000000);
  static const cellRevealed = Color(0xFFC0C0C0);
  static const cellRevealedBorder = Color(0xFF808080);
  static const ledBg = Color(0xFF000000);
  static const ledOff = Color(0xFF3A0000);
  static const ledOn = Color(0xFFFF0000);
  static const ink = Color(0xFF000000);
  static const mineRed = Color(0xFFFF0000);
  static const flagRed = Color(0xFFFF0000);

  // Canonical Minesweeper number colors.
  static const n1 = Color(0xFF0000FF);
  static const n2 = Color(0xFF008000);
  static const n3 = Color(0xFFFF0000);
  static const n4 = Color(0xFF000080);
  static const n5 = Color(0xFF800000);
  static const n6 = Color(0xFF008080);
  static const n7 = Color(0xFF000000);
  static const n8 = Color(0xFF808080);
}

class AppColors extends ThemeExtension<AppColors> {
  final Color silver;
  final Color silverLight;
  final Color bevelLight;
  final Color bevelDark;
  final Color cellRevealed;
  final Color cellRevealedBorder;
  final Color ink;

  const AppColors({
    required this.silver,
    required this.silverLight,
    required this.bevelLight,
    required this.bevelDark,
    required this.cellRevealed,
    required this.cellRevealedBorder,
    required this.ink,
  });

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? silver,
    Color? silverLight,
    Color? bevelLight,
    Color? bevelDark,
    Color? cellRevealed,
    Color? cellRevealedBorder,
    Color? ink,
  }) =>
      AppColors(
        silver: silver ?? this.silver,
        silverLight: silverLight ?? this.silverLight,
        bevelLight: bevelLight ?? this.bevelLight,
        bevelDark: bevelDark ?? this.bevelDark,
        cellRevealed: cellRevealed ?? this.cellRevealed,
        cellRevealedBorder: cellRevealedBorder ?? this.cellRevealedBorder,
        ink: ink ?? this.ink,
      );

  @override
  AppColors lerp(AppColors? other, double t) => this;
}

const _appColors = AppColors(
  silver: Palette.silver,
  silverLight: Palette.silverLight,
  bevelLight: Palette.bevelLight,
  bevelDark: Palette.bevelDark,
  cellRevealed: Palette.cellRevealed,
  cellRevealedBorder: Palette.cellRevealedBorder,
  ink: Palette.ink,
);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Palette.silver,
    colorScheme: const ColorScheme.light(
      primary: Palette.flagRed,
      onPrimary: Colors.white,
      secondary: Palette.n1,
      onSecondary: Colors.white,
      tertiary: Palette.n2,
      onTertiary: Colors.white,
      surface: Palette.silver,
      onSurface: Palette.ink,
      error: Palette.mineRed,
      onError: Colors.white,
    ),
    extensions: const [_appColors],
    fontFamily: 'PressStart2P',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 22,
        height: 1.4,
        color: Palette.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 16,
        height: 1.4,
        color: Palette.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 12,
        height: 1.4,
        color: Palette.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 12,
        height: 1.5,
        color: Palette.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 10,
        height: 1.5,
        color: Palette.ink,
      ),
      labelLarge: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 9,
        letterSpacing: 0.5,
        color: Palette.ink,
      ),
    ),
  );
}

Color numberColor(int n) {
  switch (n) {
    case 1:
      return Palette.n1;
    case 2:
      return Palette.n2;
    case 3:
      return Palette.n3;
    case 4:
      return Palette.n4;
    case 5:
      return Palette.n5;
    case 6:
      return Palette.n6;
    case 7:
      return Palette.n7;
    case 8:
      return Palette.n8;
    default:
      return Palette.ink;
  }
}
