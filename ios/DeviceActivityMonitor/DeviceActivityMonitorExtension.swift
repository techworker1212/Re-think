import DeviceActivity
import Foundation
import ManagedSettings
import UserNotifications

/// Runs in the background when a rule's usage threshold is reached: posts that rule's
/// custom warning, waits five seconds, then shields the app(s) in the rule.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  private let store = RuleStore.shared
  private let warningSeconds: UInt32 = 5

  override func eventDidReachThreshold(
    _ event: DeviceActivityEvent.Name,
    activity: DeviceActivityName
  ) {
    super.eventDidReachThreshold(event, activity: activity)
    guard event == RuleScheduler.limitEvent,
      store.monitoring,
      let rule = store.rule(id: activity.rawValue),
      rule.enabled,
      !store.isUnlocked(rule.id)
    else { return }

    store.recordInterruption()
    postWarning(for: rule)
    sleep(warningSeconds)
    RuleScheduler.shield(rule)
  }

  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    guard store.monitoring,
      let rule = store.rule(id: activity.rawValue),
      rule.enabled,
      // Recenter stopped this monitor itself to restart it (save, unlock): not a real end.
      !store.isRearming(rule.id)
    else { return }
    // A one-off window (first arm, or after an unlock) hands over to the daily window.
    // The shield stays until the user unlocks, as on Android.
    let schedule = DeviceActivityCenter().schedule(for: activity)
    if schedule?.repeats != true {
      try? RuleScheduler.arm(rule, thresholdMinutes: rule.limitMinutes, startingNow: false)
    }
  }

  private func postWarning(for rule: StoredRule) {
    let content = UNMutableNotificationContent()
    content.title = rule.title
    content.body = rule.body
    content.sound = .default
    content.threadIdentifier = rule.id
    let request = UNNotificationRequest(
      identifier: "warning.\(rule.id)",
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request)
  }
}
