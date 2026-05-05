import 'package:flutter/material.dart';
import '../game/board.dart';
import '../theme.dart';
import '../widgets/bevel.dart';
import 'game_screen.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Scaffold(
      backgroundColor: ac.silver,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  BevelButton(
                    onTap: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back,
                        size: 18, color: Palette.ink),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: BevelBox(
                  raised: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Text(
                    'DIFFICULTY',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const _LevelCard(difficulty: Difficulty.beginner),
              const SizedBox(height: 12),
              const _LevelCard(difficulty: Difficulty.intermediate),
              const SizedBox(height: 12),
              const _LevelCard(difficulty: Difficulty.expert),
              const SizedBox(height: 12),
              const _CustomCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Difficulty difficulty;
  const _LevelCard({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return BevelBox(
      raised: true,
      thickness: 3,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            difficulty.name.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Stat(label: 'GRID',
                  value: '${difficulty.width}x${difficulty.height}'),
              const SizedBox(width: 10),
              _Stat(label: 'MINES', value: '${difficulty.mines}'),
            ],
          ),
          const SizedBox(height: 12),
          BevelButton(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameScreen(difficulty: difficulty),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Center(child: Text('PLAY')),
          ),
        ],
      ),
    );
  }
}

class _CustomCard extends StatefulWidget {
  const _CustomCard();
  @override
  State<_CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<_CustomCard> {
  int _width = 30;
  int _height = 20;
  int _mines = 145;

  int get _maxMines => (_width * _height * 0.5).floor();

  void _start() {
    final d = Difficulty(
      'Custom ${_width}x$_height/$_mines',
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
    return BevelBox(
      raised: true,
      thickness: 3,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('CUSTOM', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _Stepper(
            label: 'WIDTH',
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
            label: 'HEIGHT',
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
            label: 'MINES',
            value: _mines,
            min: 1,
            max: _maxMines,
            onChanged: (v) => setState(() => _mines = v),
          ),
          const SizedBox(height: 12),
          BevelButton(
            onTap: _start,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Center(child: Text('PLAY CUSTOM')),
          ),
          const SizedBox(height: 6),
          Text(
            'Custom games are not tracked.',
            style: Theme.of(context).textTheme.labelLarge,
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
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        _StepBtn(
          icon: Icons.remove,
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        Expanded(
          child: Center(
            child: Text(
              '$value',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
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
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: BevelButton(
        onTap: onTap ?? () {},
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: Palette.ink),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BevelBox(
        raised: false,
        thickness: 2,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        fill: Palette.cellRevealed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
