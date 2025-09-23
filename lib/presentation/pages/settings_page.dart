import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.audioSettingsController,
    this.initializeOnMount = true,
    this.disposeController = false,
  });

  final AudioSettingsController audioSettingsController;
  final bool initializeOnMount;
  final bool disposeController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.initializeOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.audioSettingsController.init();
      });
    }
  }

  @override
  void dispose() {
    if (widget.disposeController) {
      widget.audioSettingsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres audio')),
      body: ValueListenableBuilder<AudioSettingsState>(
        valueListenable: widget.audioSettingsController,
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _VolumeSliderTile(
                label: 'Volume musique',
                value: state.bgmVolume,
                onChanged: widget.audioSettingsController.updateBgmVolume,
                sliderKey: const Key('settings.audio.bgmSlider'),
              ),
              const SizedBox(height: 24),
              _VolumeSliderTile(
                label: 'Volume effets',
                value: state.sfxVolume,
                onChanged: widget.audioSettingsController.updateSfxVolume,
                sliderKey: const Key('settings.audio.sfxSlider'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VolumeSliderTile extends StatelessWidget {
  const _VolumeSliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.sliderKey,
  });

  final String label;
  final double value;
  final Future<void> Function(double) onChanged;
  final Key sliderKey;

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text('$percentage%', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Slider(
          key: sliderKey,
          value: value,
          onChanged: (v) => onChanged(v),
          min: 0,
          max: 1,
          divisions: 20,
          label: '$percentage%',
        ),
      ],
    );
  }
}
