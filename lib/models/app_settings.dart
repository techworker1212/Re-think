class AppSettings {
  static const warningSeconds = 5;

  const AppSettings({
    this.defaultLimitMinutes = 10,
    this.cooldownMinutes = 2,
    this.onboardingComplete = false,
    this.monitoringEnabled = false,
  });

  final int defaultLimitMinutes;
  final int cooldownMinutes;
  final bool onboardingComplete;
  final bool monitoringEnabled;

  AppSettings copyWith({
    int? defaultLimitMinutes,
    int? cooldownMinutes,
    bool? onboardingComplete,
    bool? monitoringEnabled,
  }) {
    return AppSettings(
      defaultLimitMinutes: defaultLimitMinutes ?? this.defaultLimitMinutes,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
    );
  }

  Map<String, Object?> toJson() => {
    'defaultLimitMinutes': defaultLimitMinutes,
    'cooldownMinutes': cooldownMinutes,
    'onboardingComplete': onboardingComplete,
    'monitoringEnabled': monitoringEnabled,
  };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      defaultLimitMinutes: json['defaultLimitMinutes'] as int? ?? 10,
      cooldownMinutes: json['cooldownMinutes'] as int? ?? 2,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      monitoringEnabled: json['monitoringEnabled'] as bool? ?? false,
    );
  }
}
