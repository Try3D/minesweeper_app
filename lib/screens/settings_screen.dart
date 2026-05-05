import 'package:flutter/material.dart';
import '../app_scope.dart';
import '../data/settings_store.dart';
import '../theme.dart';
import '../widgets/sketch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameCtrl;
  late SettingsStore _settings;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings = AppScope.settingsOf(context);
    if (_nameCtrl.text != _settings.playerName) {
      _nameCtrl.text = _settings.playerName;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _settings,
            builder: (context, _) {
              return SingleChildScrollView(
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
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: WobblyUnderline(
                        child: Text(
                          'Options',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel('Player'),
                    const SizedBox(height: 8),
                    _NameField(
                      controller: _nameCtrl,
                      onSubmit: _settings.setPlayerName,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('Appearance'),
                    const SizedBox(height: 8),
                    _ThemePicker(
                      mode: _settings.themeMode,
                      onChanged: _settings.setThemeMode,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel('Gameplay'),
                    const SizedBox(height: 8),
                    _ToggleRow(
                      label: 'Haptics',
                      value: _settings.haptics,
                      onChanged: _settings.setHaptics,
                    ),
                    const SizedBox(height: 8),
                    _ToggleRow(
                      label: 'Show timer',
                      value: _settings.showTimer,
                      onChanged: _settings.setShowTimer,
                    ),
                    const SizedBox(height: 8),
                    _ToggleRow(
                      label: 'Safe first click',
                      value: _settings.firstClickSafety,
                      onChanged: _settings.setFirstClickSafety,
                    ),
                    const SizedBox(height: 32),
                    _SectionLabel('Reset'),
                    const SizedBox(height: 8),
                    SketchButton(
                      onTap: () => _confirmResetSettings(context),
                      background: cs.surface,
                      seed: 51,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Center(
                        child: Text('RESET SETTINGS',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SketchButton(
                      onTap: () => _confirmResetScores(context),
                      background: cs.primary,
                      foreground: cs.onPrimary,
                      seed: 52,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Center(
                        child: Text('RESET HIGH SCORES',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmResetSettings(BuildContext context) async {
    final ok = await _confirm(
        context, 'Reset all settings?', 'Returns everything to defaults.');
    if (ok) await _settings.resetAll();
  }

  Future<void> _confirmResetScores(BuildContext context) async {
    final scores = AppScope.scoresOf(context);
    final ok =
        await _confirm(context, 'Reset all scores?', 'This cannot be undone.');
    if (ok) await scores.reset();
  }

  Future<bool> _confirm(
      BuildContext context, String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        final ac = AppColors.of(ctx);
        final cs = Theme.of(ctx).colorScheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: ac.ink, width: 4),
              boxShadow: [
                BoxShadow(
                    color: ac.ink, offset: const Offset(6, 6), blurRadius: 0),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(body,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ac.onSurfaceVariant)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SketchButton(
                        onTap: () => Navigator.of(ctx).pop(false),
                        background: cs.surface,
                        seed: 41,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Center(
                          child: Text('CANCEL',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SketchButton(
                        onTap: () => Navigator.of(ctx).pop(true),
                        background: cs.primary,
                        foreground: cs.onPrimary,
                        seed: 42,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Center(
                          child: Text('CONFIRM',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return ok == true;
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
        color: AppColors.of(context).onSurfaceVariant,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const _NameField({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: ac.surfaceLowest,
        border: Border.all(color: ac.ink, width: 3),
        boxShadow: [
          BoxShadow(color: ac.ink, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        maxLength: 16,
        onSubmitted: onSubmit,
        onTapOutside: (_) {
          onSubmit(controller.text);
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintText: 'Player',
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemePicker({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final m in ThemeMode.values) ...[
          Expanded(
            child: SketchButton(
              onTap: () => onChanged(m),
              background: m == mode ? cs.secondary : ac.surfaceLowest,
              foreground: m == mode ? cs.onSecondary : ac.ink,
              seed: m.index.toDouble() * 17,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  _labelFor(m),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          if (m != ThemeMode.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  String _labelFor(ThemeMode m) => switch (m) {
        ThemeMode.system => 'SYSTEM',
        ThemeMode.light => 'LIGHT',
        ThemeMode.dark => 'DARK',
      };
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ac.surfaceLowest,
          border: Border.all(color: ac.ink, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: ac.ink, offset: const Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            _Switch(value: value),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  const _Switch({required this.value});

  @override
  Widget build(BuildContext context) {
    final ac = AppColors.of(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: value ? cs.tertiary : ac.surfaceContainer,
        border: Border.all(color: ac.ink, width: 2),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 120),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: ac.surfaceLowest,
                border: Border.all(color: ac.ink, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
