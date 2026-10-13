import 'package:flutter/material.dart';

import '../models/app_rule.dart';
import '../screens/rule_editor_screen.dart';
import '../screens/settings_screen.dart';
import '../state/app_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recenter'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(controller: controller),
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add),
            label: const Text('Add app'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Monitoring'),
                subtitle: Text(
                  controller.settings.monitoringEnabled
                      ? 'Watching selected apps'
                      : 'Paused',
                ),
                value: controller.settings.monitoringEnabled,
                onChanged: controller.setMonitoring,
              ),
              if (controller.missingPermissions.isNotEmpty)
                _PermissionBanner(controller: controller),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text('${controller.interruptionsToday}'),
                  subtitle: const Text('Interruptions today'),
                ),
              ),
              if (controller.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Text('App rules', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (controller.rules.isEmpty)
                const Text(
                  'Add an app, set a time limit, and write the reminder you want to see when time is up.',
                ),
              ...controller.rules.map((rule) => _RuleTile(
                    rule: rule,
                    onEdit: () => _openEditor(context, rule: rule),
                    onToggle: (enabled) =>
                        controller.setRuleEnabled(rule, enabled),
                    onDelete: () => _confirmDelete(context, rule),
                  )),
              const SizedBox(height: 72),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppRule rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${rule.displayLabel}?'),
        content: const Text('Its limit and reminder will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteRule(rule.id);
    }
  }

  Future<void> _openEditor(BuildContext context, {AppRule? rule}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RuleEditorScreen(controller: controller, existing: rule),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.controller});

  final AppController controller;

  static const _labels = {
    'familyControls': 'Screen Time access',
    'usageAccess': 'Usage access',
    'notifications': 'Notifications',
    'overlay': 'Display over other apps',
  };

  @override
  Widget build(BuildContext context) {
    final missing = controller.missingPermissions;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recenter needs a few permissions to work',
              style: TextStyle(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: missing
                  .map(
                    (kind) => ActionChip(
                      avatar: const Icon(Icons.lock_open, size: 18),
                      label: Text(_labels[kind] ?? kind),
                      onPressed: controller.busy
                          ? null
                          : () => controller.requestPermission(kind),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({
    required this.rule,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final AppRule rule;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(rule.displayLabel),
        subtitle: Text(
          '${rule.limitMinutes} min · ${rule.resolvedTitle}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: onEdit,
        onLongPress: onDelete,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: rule.enabled, onChanged: onToggle),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
