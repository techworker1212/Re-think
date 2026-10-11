import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_rule.dart';
import '../models/app_settings.dart';

class LocalStore {
  static const _rulesKey = 'rethink.rules';
  static const _settingsKey = 'rethink.settings';

  Future<List<AppRule>> loadRules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_rulesKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => AppRule.fromJson(Map<String, Object?>.from(item as Map)))
        .toList();
  }

  Future<void> saveRules(List<AppRule> rules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _rulesKey,
      jsonEncode(rules.map((rule) => rule.toJson()).toList()),
    );
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return const AppSettings();
    }
    return AppSettings.fromJson(
      Map<String, Object?>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
