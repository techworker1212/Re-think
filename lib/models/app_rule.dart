class AppRule {
  static const fallbackCopy = "Re-think — time's up on this app.";
  static const titleMax = 50;
  static const bodyMax = 120;

  const AppRule({
    required this.id,
    required this.platformAppId,
    required this.displayLabel,
    required this.limitMinutes,
    required this.notificationTitle,
    required this.notificationBody,
    this.enabled = true,
  });

  final String id;
  final String platformAppId;
  final String displayLabel;
  final int limitMinutes;
  final String notificationTitle;
  final String notificationBody;
  final bool enabled;

  String get resolvedTitle {
    final title = notificationTitle.trim();
    if (title.isEmpty) {
      return fallbackCopy;
    }
    return title;
  }

  String get resolvedBody {
    final body = notificationBody.trim();
    if (body.isEmpty) {
      return fallbackCopy;
    }
    return body;
  }

  AppRule copyWith({
    String? id,
    String? platformAppId,
    String? displayLabel,
    int? limitMinutes,
    String? notificationTitle,
    String? notificationBody,
    bool? enabled,
  }) {
    return AppRule(
      id: id ?? this.id,
      platformAppId: platformAppId ?? this.platformAppId,
      displayLabel: displayLabel ?? this.displayLabel,
      limitMinutes: limitMinutes ?? this.limitMinutes,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationBody: notificationBody ?? this.notificationBody,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'platformAppId': platformAppId,
    'displayLabel': displayLabel,
    'limitMinutes': limitMinutes,
    'notificationTitle': notificationTitle,
    'notificationBody': notificationBody,
    'enabled': enabled,
  };

  factory AppRule.fromJson(Map<String, Object?> json) {
    return AppRule(
      id: json['id'] as String,
      platformAppId: json['platformAppId'] as String? ?? '',
      displayLabel: json['displayLabel'] as String? ?? 'App',
      limitMinutes: json['limitMinutes'] as int? ?? 10,
      notificationTitle: json['notificationTitle'] as String? ?? '',
      notificationBody: json['notificationBody'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
