import 'package:flutter/material.dart';
import '../app_scope.dart';
import '../data/settings_store.dart';
import '../theme.dart';
import '../widgets/bevel.dart';

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
    final ac = AppColors.of(context);
    return Scaffold(
      backgroundColor: ac.silver,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _settings,
          builder: (context, _) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        'OPTIONS',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SectionLabel('PLAYER'),
                  const SizedBox(height: 8),
                  _NameField(
                    controller: _nameCtrl,
                    onSubmit: _settings.setPlayerName,
                  ),
                  const SizedBox(height: 22),
                  _SectionLabel('GAMEPLAY'),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    label: 'HAPTICS',
                    value: _settings.haptics,
                    onChanged: _settings.setHaptics,
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    label: 'SHOW TIMER',
                    value: _settings.showTimer,
                    onChanged: _settings.setShowTimer,
                  ),
                  const SizedBox(height: 8),
                  _ToggleRow(
                    label: 'SAFE FIRST CLICK',
                    value: _settings.firstClickSafety,
                    onChanged: _settings.setFirstClickSafety,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel('RESET'),
                  const SizedBox(height: 8),
                  BevelButton(
                    onTap: () => _confirmResetSettings(context),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Center(child: Text('RESET SETTINGS')),
                  ),
                  const SizedBox(height: 8),
                  BevelButton(
                    onTap: () => _confirmResetScores(context),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Center(child: Text('RESET HIGH SCORES')),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmResetSettings(BuildContext context) async {
    final ok = await _confirm(
        context, 'RESET ALL SETTINGS?', 'Returns everything to defaults.');
    if (ok) await _settings.resetAll();
  }

  Future<void> _confirmResetScores(BuildContext context) async {
    final scores = AppScope.scoresOf(context);
    final ok = await _confirm(
        context, 'RESET ALL SCORES?', 'This cannot be undone.');
    if (ok) await scores.reset();
  }

  Future<bool> _confirm(
      BuildContext context, String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: BevelBox(
            raised: true,
            thickness: 3,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(body,
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: BevelButton(
                        onTap: () => Navigator.of(ctx).pop(false),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Center(child: Text('CANCEL')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BevelButton(
                        onTap: () => Navigator.of(ctx).pop(true),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Center(child: Text('OK')),
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
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const _NameField({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return BevelBox(
      raised: false,
      thickness: 2,
      fill: Palette.cellRevealed,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        maxLength: 16,
        onSubmitted: onSubmit,
        onTapOutside: (_) {
          onSubmit(controller.text);
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintText: 'PLAYER',
        ),
      ),
    );
  }
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: BevelBox(
        raised: true,
        thickness: 2,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            _CheckBox(checked: value),
          ],
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final bool checked;
  const _CheckBox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return BevelBox(
      raised: false,
      thickness: 2,
      fill: Palette.cellRevealed,
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        width: 16,
        height: 16,
        child: checked
            ? const Icon(Icons.check, size: 14, color: Palette.ink)
            : null,
      ),
    );
  }
}
