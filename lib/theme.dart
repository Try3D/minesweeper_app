import 'package:flutter/material.dart';

class Palette {
  static const background = Color(0xFFFBFAEE);
  static const surface = Color(0xFFFBFAEE);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFEFEEE3);
  static const surfaceContainerHighest = Color(0xFFE4E3D7);
  static const surfaceVariant = Color(0xFFE4E3D7);
  static const surfaceDim = Color(0xFFDBDBCF);
  static const surfaceContainerLow = Color(0xFFF5F4E8);
  static const onBackground = Color(0xFF1B1C15);
  static const onSurface = Color(0xFF1B1C15);
  static const onSurfaceVariant = Color(0xFF5B403F);
  static const outline = Color(0xFF8F6F6E);
  static const outlineVariant = Color(0xFFE4BEBC);
  static const primary = Color(0xFFB7102A);
  static const primaryContainer = Color(0xFFDB313F);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF485F84);
  static const onSecondary = Color(0xFFFFFFFF);
  static const tertiary = Color(0xFF00685D);
  static const onTertiary = Color(0xFFFFFFFF);
  static const error = Color(0xFFBA1A1A);
  static const accentRed = Color(0xFFE63946);
  static const ink = Color(0xFF1B1C15);
}

class AppColors extends ThemeExtension<AppColors> {
  final Color ink;
  final Color surfaceLowest;
  final Color surfaceContainer;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outlineVariant;

  const AppColors({
    required this.ink,
    required this.surfaceLowest,
    required this.surfaceContainer,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outlineVariant,
  });

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? ink,
    Color? surfaceLowest,
    Color? surfaceContainer,
    Color? surfaceContainerHighest,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outlineVariant,
  }) =>
      AppColors(
        ink: ink ?? this.ink,
        surfaceLowest: surfaceLowest ?? this.surfaceLowest,
        surfaceContainer: surfaceContainer ?? this.surfaceContainer,
        surfaceContainerHighest:
            surfaceContainerHighest ?? this.surfaceContainerHighest,
        surfaceVariant: surfaceVariant ?? this.surfaceVariant,
        onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
        outlineVariant: outlineVariant ?? this.outlineVariant,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ink: Color.lerp(ink, other.ink, t)!,
      surfaceLowest: Color.lerp(surfaceLowest, other.surfaceLowest, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHighest:
          Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
    );
  }
}

const _lightColors = AppColors(
  ink: Color(0xFF1B1C15),
  surfaceLowest: Color(0xFFFFFFFF),
  surfaceContainer: Color(0xFFEFEEE3),
  surfaceContainerHighest: Color(0xFFE4E3D7),
  surfaceVariant: Color(0xFFE4E3D7),
  onSurfaceVariant: Color(0xFF5B403F),
  outlineVariant: Color(0xFFE4BEBC),
);

const _darkColors = AppColors(
  ink: Color(0xFFD4D0B8),
  surfaceLowest: Color(0xFF141510),
  surfaceContainer: Color(0xFF22231C),
  surfaceContainerHighest: Color(0xFF2A2B23),
  surfaceVariant: Color(0xFF2A2B23),
  onSurfaceVariant: Color(0xFFAEA592),
  outlineVariant: Color(0xFF3D3830),
);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Palette.background,
    colorScheme: const ColorScheme.light(
      primary: Palette.primary,
      onPrimary: Palette.onPrimary,
      secondary: Palette.secondary,
      onSecondary: Palette.onSecondary,
      tertiary: Palette.tertiary,
      onTertiary: Palette.onTertiary,
      surface: Palette.surface,
      onSurface: Palette.onSurface,
      error: Palette.error,
      onError: Colors.white,
    ),
    extensions: const [_lightColors],
    fontFamily: 'Epilogue',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.9,
        height: 1.1,
        color: Palette.onBackground,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: Palette.onBackground,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Palette.onBackground,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Palette.onBackground,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Palette.onBackground,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Palette.onBackground,
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  const darkOnSurface = Color(0xFFE8E6D0);
  const darkSurface = Color(0xFF1A1B14);
  const darkPrimary = Color(0xFFE63946);
  const darkSecondary = Color(0xFF7A9ECC);
  const darkTertiary = Color(0xFF00C9B5);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: Colors.white,
      secondary: darkSecondary,
      onSecondary: Colors.white,
      tertiary: darkTertiary,
      onTertiary: Colors.white,
      surface: darkSurface,
      onSurface: darkOnSurface,
      error: Color(0xFFCF6679),
      onError: Colors.white,
    ),
    extensions: const [_darkColors],
    fontFamily: 'Epilogue',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.9,
        height: 1.1,
        color: darkOnSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: darkOnSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: darkOnSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: darkOnSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: darkOnSurface,
      ),
    ),
  );
}
