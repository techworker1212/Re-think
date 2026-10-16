class AppSettings {
  static const warningSeconds = 5;

  const AppSettings({
    this.defaultLimitMinutes = 10,
    this.onboardingComplete = false,
    this.monitoringEnabled = false,
  });

  final int defaultLimitMinutes;
  final bool onboardingComplete;
  final bool monitoringEnabled;

  AppSettings copyWith({
    int? defaultLimitMinutes,
    bool? onboardingComplete,
    bool? monitoringEnabled,
  }) {
    return AppSettings(
      defaultLimitMinutes: defaultLimitMinutes ?? this.defaultLimitMinutes,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
    );
  }

  Map<String, Object?> toJson() => {
    'defaultLimitMinutes': defaultLimitMinutes,
    'onboardingComplete': onboardingComplete,
    'monitoringEnabled': monitoringEnabled,
  };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    return AppSettings(
      defaultLimitMinutes: json['defaultLimitMinutes'] as int? ?? 10,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      monitoringEnabled: json['monitoringEnabled'] as bool? ?? false,
    );
  }
}
