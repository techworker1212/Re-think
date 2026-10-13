# Recenter

Set a time limit and your own reminder for the apps that eat your time. When the limit is reached,
Recenter shows your message, waits five seconds, then pauses the app until you choose to unlock it.

- **Your words:** each app gets its own notification title and message, written by you.
- **A real pause:** on iPhone, the app is shielded with Apple's Screen Time and your message is
  shown on the shield. Unlocking gives a short cool-down before the next reminder.
- **Private:** no accounts, no servers, no analytics. Everything stays on the device.
  See the [privacy policy](website/privacy.html).

## Status

| Platform | State |
| --- | --- |
| iOS 16+ | Working on a physical iPhone. Waiting on Apple's Family Controls distribution approval for TestFlight and the App Store. |
| Android 10+ | Native code written but not yet compiled. Parked for now. |

Progress and next steps are in [docs/plan.md](docs/plan.md); store requirements are in
[docs/store-readiness.md](docs/store-readiness.md).

## How it's built

- **Flutter** (`lib/`): onboarding, rules, settings, and the warning preview.
- **Pigeon bridge** (`pigeons/host_api.dart`): the typed API between Flutter and native code.
  Regenerate with `dart run pigeon --input pigeons/host_api.dart`.
- **iOS** (`ios/`):
  - `Runner/`: Family Controls authorization, the app picker, and the bridge implementation.
  - `Shared/`: rule storage in the App Group and one Device Activity monitor per rule.
  - `DeviceActivityMonitor/`: posts the 5-second warning, then applies the shield.
  - `ShieldConfiguration/`, `ShieldAction/`: the shield screen with your message, and Close and Unlock.
- **Android** (`android/`): a Usage Stats foreground service, the pause screen, and a boot receiver.
- **App icon** (`assets/icon/make_icon.swift`): renders the 1024px icon.
- **Privacy policy** (`website/`): published from the `gh-pages` branch.

## Running on an iPhone

Screen Time doesn't work in the Simulator, so you need a physical iPhone with Developer Mode
turned on.

```bash
flutter build ios --config-only --release
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release \
  -destination 'id=<device-udid>' -allowProvisioningUpdates build
```

Then install the resulting `Runner.app` with `xcrun devicectl device install app`.
