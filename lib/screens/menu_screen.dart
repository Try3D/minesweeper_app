import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/bevel.dart';
import '../widgets/glyphs.dart';
import 'high_scores_screen.dart';
import 'levels_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Scaffold(
      backgroundColor: ac.silver,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white, width: 2),
                        left: BorderSide(color: Colors.white, width: 2),
                        right:
                            BorderSide(color: Color(0xFF7B7B7B), width: 2),
                        bottom:
                            BorderSide(color: Color(0xFF7B7B7B), width: 2),
                      ),
                    ),
                    child: const SmileyFace(
                        size: 31, state: SmileyState.idle),
                  ),
                  const SizedBox(height: 16),
                  BevelBox(
                    raised: true,
                    thickness: 3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Text(
                      'MINESWEEPER',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _MenuButton(
                    label: 'NEW GAME',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LevelsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: 'HIGH SCORES',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const HighScoresScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuButton(
                    label: 'OPTIONS',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MenuButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BevelButton(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
