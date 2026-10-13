import 'package:flutter_test/flutter_test.dart';
import 'package:re_think/models/app_rule.dart';

void main() {
  test('empty notification copy uses the shared fallback', () {
    const rule = AppRule(
      id: '1',
      platformAppId: 'com.google.android.youtube',
      displayLabel: 'YouTube',
      limitMinutes: 10,
      notificationTitle: '',
      notificationBody: '  ',
    );
    expect(rule.resolvedTitle, AppRule.fallbackTitle);
    expect(rule.resolvedBody, AppRule.fallbackBody);
  });

  test('custom copy is used when present', () {
    const rule = AppRule(
      id: '2',
      platformAppId: 'com.instagram.android',
      displayLabel: 'Instagram',
      limitMinutes: 8,
      notificationTitle: 'That’s enough TikTok',
      notificationBody: 'Unlock only if you still need it.',
    );
    expect(rule.resolvedTitle, 'That’s enough TikTok');
    expect(rule.resolvedBody, 'Unlock only if you still need it.');
  });
}
