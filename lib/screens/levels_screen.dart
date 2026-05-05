import 'package:flutter/material.dart';
import '../game/board.dart';
import '../theme.dart';
import '../widgets/sketch.dart';
import 'game_screen.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SketchButton(
                      onTap: () => Navigator.of(context).pop(),
                      seed: 7,
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.arrow_back, size: 22),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Select Difficulty',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 32),
                _LevelCard(
                  difficulty: Difficulty.beginner,
                  icon: Icons.sentiment_satisfied,
                  accent: cs.secondary,
                  buttonColor: cs.secondary,
                ),
                const SizedBox(height: 18),
                _LevelCard(
                  difficulty: Difficulty.intermediate,
                  icon: Icons.my_location,
                  accent: cs.primary,
                  buttonColor: cs.primary,
                ),
                const SizedBox(height: 18),
                _LevelCard(
                  difficulty: Difficulty.expert,
                  icon: Icons.dangerous,
                  accent: cs.primary,
                  buttonColor: cs.primary,
                  buttonLabel: 'Dare to Play',
                ),
                const SizedBox(height: 18),
                _CustomCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Difficulty difficulty;
  final IconData icon;
  final Color accent;
  final Color buttonColor;
  final String? buttonLabel;

  const _LevelCard({
    required this.difficulty,
    required this.icon,
    required this.accent,
    required this.buttonColor,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ac.surfaceLowest,
        border: Border.all(color: ac.ink, width: 3),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: ac.surfaceContainer,
              border: Border.all(color: ac.ink, width: 3),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 56, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            difficulty.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Container(height: 3, width: 80, color: accent.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          _Stat(label: 'Grid', value: '${difficulty.width}×${difficulty.height}'),
          const SizedBox(height: 6),
          _Stat(label: 'Mines', value: '${difficulty.mines}', valueColor: accent),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SketchButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameScreen(difficulty: difficulty),
                ),
              ),
              background: buttonColor,
              foreground: Colors.white,
              seed: difficulty.mines.toDouble(),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  (buttonLabel ?? 'PLAY').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCard extends StatefulWidget {
  @override
  State<_CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<_CustomCard> {
  int _width = 12;
  int _height = 12;
  int _mines = 25;

  int get _maxMines => (_width * _height * 0.6).floor();

  void _start() {
    final d = Difficulty(
      'Custom $_width×$_height/$_mines',
      _width,
      _height,
      _mines,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(difficulty: d)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ac.surfaceLowest,
        border: Border.all(color: ac.ink, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 32, color: cs.tertiary),
              const SizedBox(width: 12),
              Text('Custom',
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 4),
          Container(
              height: 3,
              width: 80,
              color: cs.tertiary.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          _Stepper(
            label: 'Width',
            value: _width,
            min: 5,
            max: 40,
            onChanged: (v) => setState(() {
              _width = v;
              if (_mines > _maxMines) _mines = _maxMines;
            }),
          ),
          const SizedBox(height: 8),
          _Stepper(
            label: 'Height',
            value: _height,
            min: 5,
            max: 40,
            onChanged: (v) => setState(() {
              _height = v;
              if (_mines > _maxMines) _mines = _maxMines;
            }),
          ),
          const SizedBox(height: 8),
          _Stepper(
            label: 'Mines',
            value: _mines,
            min: 1,
            max: _maxMines,
            onChanged: (v) => setState(() => _mines = v),
          ),
          const SizedBox(height: 8),
          Text(
            'Custom games are not tracked in High Scores.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ac.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SketchButton(
              onTap: _start,
              background: cs.tertiary,
              foreground: cs.onTertiary,
              seed: 88,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Center(
                child: Text(
                  'PLAY CUSTOM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        _StepBtn(
            icon: Icons.remove,
            onTap: value > min ? () => onChanged(value - 1) : null),
        Expanded(
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        _StepBtn(
            icon: Icons.add,
            onTap: value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: disabled ? ac.surfaceContainer : ac.surfaceLowest,
          border: Border.all(color: ac.ink, width: 2.5),
        ),
        child: Icon(icon,
            size: 20,
            color: disabled ? ac.onSurfaceVariant : ac.ink),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Stat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: cs.onSurface, width: 1.5, style: BorderStyle.solid),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: valueColor ?? cs.onSurface,
              )),
        ],
      ),
    );
  }
}
