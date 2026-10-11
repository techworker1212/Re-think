import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../state/app_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final settings = controller.settings;
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Warning length'),
                subtitle: Text(
                  '${AppSettings.warningSeconds} seconds (fixed in v1)',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Default limit: ${settings.defaultLimitMinutes} min'),
                subtitle: Slider(
                  min: 1,
                  max: 60,
                  divisions: 59,
                  value: settings.defaultLimitMinutes.toDouble(),
                  onChanged: (value) {
                    controller.updateSettings(defaultLimitMinutes: value.round());
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Cool-down: ${settings.cooldownMinutes} min'),
                subtitle: Slider(
                  min: 1,
                  max: 15,
                  divisions: 14,
                  value: settings.cooldownMinutes.toDouble(),
                  onChanged: (value) {
                    controller.updateSettings(cooldownMinutes: value.round());
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rules, notification copy, and usage stay on this device. Re-think has no account and no backend.',
              ),
            ],
          ),
        );
      },
    );
  }
}
