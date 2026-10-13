# Store readiness

Nothing here has been submitted. This is the checklist for when you're ready.

## Identifiers

| Thing | Value |
| --- | --- |
| iOS bundle ID | `com.aquibkhan.rethink` |
| Android applicationId | `com.rethink.app` (check it is free on Play before publishing) |
| iOS extensions | `com.aquibkhan.rethink.DeviceActivityMonitor`, `.ShieldConfiguration`, `.ShieldAction` |
| App Group (app + all 3 extensions) | `group.com.aquibkhan.rethink` |
| Minimum OS | iOS 16, Android 10 (API 29) |

## Apple (App Store)

1. **Request the Family Controls distribution entitlement now.** The Account Holder does this at
   developer.apple.com/contact/request/family-controls-distribution, once for **each** of the
   4 bundle IDs above. Approval takes days to weeks. Development builds on a device work without it;
   TestFlight and the App Store don't.
2. In Certificates, Identifiers & Profiles, register all 4 bundle IDs and turn on
   **Family Controls** and **App Groups** (`group.com.aquibkhan.rethink`) for each one.
3. In Xcode, set the Team on all 4 targets (Runner, DeviceActivityMonitor, ShieldConfiguration,
   ShieldAction). The entitlements files are already in place.
4. App Review notes: explain that Re-think uses Screen Time (individual authorization) only to
   watch apps the user picks, show the user's own reminder, and shield those apps. There is no
   account, no server, and no data leaves the device.
5. Privacy nutrition label: **Data Not Collected**.
6. Test on a physical iPhone. The Simulator can't authorize Family Controls or fire DeviceActivity events.

**How limits behave on iOS:** DeviceActivity counts **total use since the window started** (from
when monitoring was armed until midnight, then daily). It doesn't count one continuous session the
way Android does. After an unlock, the next warning comes after `cooldown` minutes of further use.

## Google Play

1. **Release signing:** create `android/key.properties` (already git-ignored) with `storeFile`,
   `storePassword`, `keyAlias`, `keyPassword`. Without it, release builds use debug keys.
2. **Foreground service declaration (`specialUse`):** in Play Console → App content → Foreground
   service permissions, use the same justification as the manifest property:
   *"Checks which app is in the foreground so it can show the user's own time-limit reminder and
   pause screen for apps they chose to limit."* Attach a short video of: add rule → use app past
   limit → 5s warning → pause screen → unlock.
3. **Usage Access (`PACKAGE_USAGE_STATS`):** the onboarding screen is the prominent disclosure.
   It says what is read (the current foreground app), why, and that it stays on the device.
4. **Display over other apps (`SYSTEM_ALERT_WINDOW`):** this lets the pause screen open over the
   blocked app. If it's denied, the app falls back to a tappable notification.
5. **Do not** declare `isAccessibilityTool`. No Accessibility Service is used.
6. **Not used, on purpose:** `QUERY_ALL_PACKAGES` (a launcher-intent `<queries>` is used
   instead), `USE_FULL_SCREEN_INTENT`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (onboarding opens
   the battery settings list instead), and `DevicePolicyManager`.
7. **Data safety form:** no data collected or shared. App activity (app usage) is processed only
   on the device.

## Still to do before submission

- [ ] App icon. Both platforms still use the Flutter default. Replace
      `ios/Runner/Assets.xcassets/AppIcon.appiconset` and `android/app/src/main/res/mipmap-*`.
- [ ] Store screenshots: home, rule editor with preview, Android pause screen, iOS shield.
- [ ] Privacy policy URL (required by both stores even with no data collected).
- [ ] Physical-device verification matrix (see the plan's "Verification" section).
