import '../bridge/messages.g.dart';
import '../bridge/native_bridge.dart';
import '../models/app_rule.dart';
import '../models/app_settings.dart';
import '../persistence/local_store.dart';

/// Demo mode for App Store screenshots in the Simulator, where Screen Time can't be
/// authorized. Only active in builds made with `--dart-define=RECENTER_DEMO=true`.
const demoMode = bool.fromEnvironment('RECENTER_DEMO');

/// Pretends every permission is granted and monitoring is running, without touching
/// any native code.
class DemoBridge extends NativeBridge {
  DemoBridge() : super(api: RecenterHostApi());

  static final _granted = PermissionSnapshot(
    familyControls: true,
    notifications: true,
    usageAccess: true,
    overlay: true,
    batteryExemption: true,
  );

  @override
  Future<PermissionSnapshot> status() async => _granted;

  @override
  Future<PermissionSnapshot> request(String kind) async => _granted;

  @override
  Future<void> upsert(AppRule rule) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<MonitoringStatus> monitoring() async =>
      MonitoringStatus(running: true, interruptionsToday: 3);

  @override
  Future<List<ListedApp>> installedApps() async => const [];

  @override
  Future<String> pickIosActivity() async => 'demo-selection';

  @override
  Future<void> unlock(String ruleId) async {}

  @override
  Future<void> saveSettings(AppSettings settings) async {}
}

/// Keeps the sample rules in memory so demo runs never touch real saved data.
class DemoStore extends LocalStore {
  List<AppRule> _rules = const [
    AppRule(
      id: 'demo_instagram',
      platformAppId: 'demo-selection',
      displayLabel: 'Instagram',
      limitMinutes: 15,
      unlockMinutes: 5,
      notificationTitle: 'That’s enough Instagram',
      notificationBody: 'You said 15 minutes. Call Mum instead?',
    ),
    AppRule(
      id: 'demo_tiktok',
      platformAppId: 'demo-selection',
      displayLabel: 'TikTok',
      limitMinutes: 10,
      unlockMinutes: 1,
      notificationTitle: 'Put the phone down',
      notificationBody: 'Ten minutes is plenty. Your book is waiting.',
    ),
    AppRule(
      id: 'demo_youtube',
      platformAppId: 'demo-selection',
      displayLabel: 'YouTube',
      limitMinutes: 30,
      notificationTitle: 'One more video?',
      notificationBody: 'You came for one. Time to get back to your project.',
    ),
  ];
  AppSettings _settings = const AppSettings(
    onboardingComplete: true,
    monitoringEnabled: true,
  );

  @override
  Future<List<AppRule>> loadRules() async => _rules;

  @override
  Future<void> saveRules(List<AppRule> rules) async => _rules = rules;

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async => _settings = settings;
}
