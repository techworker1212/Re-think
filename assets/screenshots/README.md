# App Store screenshots

- `raw/`: unframed 1320×2868 captures (iPhone 18 Pro Max simulator, or device screenshots).
- `app-store/`: framed images ready to upload (6.9" display size, opaque).

The Simulator can't authorize Screen Time, so in-app screens are captured from a demo build that
fakes granted permissions and sample rules:

```bash
flutter build ios --simulator --debug --dart-define=RECENTER_DEMO=true
xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100
xcrun simctl io booted screenshot assets/screenshots/raw/01-home.png
```

To frame a capture with a headline:

```bash
swift assets/screenshots/make_screenshot.swift raw/01-home.png app-store/01-home.png "Limits for the apps that steal your time"
```

The notification and shield screenshots must come from a real iPhone. Blur anything behind the
notification (it usually shows another app's content) by keeping only the status bar and banner sharp:

```bash
swift assets/screenshots/focus_region.swift original.png raw/03-notification.png 0,0,1206,170,0 24,178,1158,194,62
```

Headlines can force a line break with `\n`, e.g. `'A 5-second\nheads-up first'`.
