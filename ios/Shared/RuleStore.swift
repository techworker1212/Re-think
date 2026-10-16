import FamilyControls
import Foundation
import ManagedSettings

/// A rule as the app and its Screen Time extensions see it. Copy is already resolved
/// (fallback applied) by Flutter.
struct StoredRule: Codable {
  var id: String
  var label: String
  var limitMinutes: Int
  var title: String
  var body: String
  var enabled: Bool
  var selection: FamilyActivitySelection

  func covers(application token: ApplicationToken) -> Bool {
    selection.applicationTokens.contains(token)
  }

  func covers(category token: ActivityCategoryToken) -> Bool {
    selection.categoryTokens.contains(token)
  }

  func covers(webDomain token: WebDomainToken) -> Bool {
    selection.webDomainTokens.contains(token)
  }
}

/// Rules and state in the App Group, so the monitor and shield extensions can read the
/// user's custom copy without the app running.
final class RuleStore {
  static let appGroup = "group.com.aquibkhan.recenter"
  static let shared = RuleStore()

  private let defaults: UserDefaults

  init(defaults: UserDefaults? = UserDefaults(suiteName: RuleStore.appGroup)) {
    self.defaults = defaults ?? .standard
  }

  func rules() -> [StoredRule] {
    guard let data = defaults.data(forKey: Keys.rules) else { return [] }
    return (try? JSONDecoder().decode([StoredRule].self, from: data)) ?? []
  }

  func rule(id: String) -> StoredRule? {
    rules().first { $0.id == id }
  }

  func rule(application token: ApplicationToken?) -> StoredRule? {
    guard let token else { return nil }
    return rules().first { $0.covers(application: token) }
  }

  func rule(category token: ActivityCategoryToken?) -> StoredRule? {
    guard let token else { return nil }
    return rules().first { $0.covers(category: token) }
  }

  func rule(webDomain token: WebDomainToken?) -> StoredRule? {
    guard let token else { return nil }
    return rules().first { $0.covers(webDomain: token) }
  }

  func upsert(_ rule: StoredRule) {
    save(rules().filter { $0.id != rule.id } + [rule])
  }

  func delete(id: String) {
    save(rules().filter { $0.id != id })
  }

  private func save(_ rules: [StoredRule]) {
    if let data = try? JSONEncoder().encode(rules) {
      defaults.set(data, forKey: Keys.rules)
    }
  }

  var monitoring: Bool {
    get { defaults.bool(forKey: Keys.monitoring) }
    set { defaults.set(newValue, forKey: Keys.monitoring) }
  }

  var cooldownMinutes: Int {
    get { defaults.object(forKey: Keys.cooldown) as? Int ?? 2 }
    set { defaults.set(newValue, forKey: Keys.cooldown) }
  }

  /// The rule is unlocked (no warnings or shields) until this time.
  func unlockedUntil(_ ruleId: String) -> Date? {
    defaults.object(forKey: Keys.unlockedUntil + ruleId) as? Date
  }

  func setUnlockedUntil(_ date: Date?, for ruleId: String) {
    defaults.set(date, forKey: Keys.unlockedUntil + ruleId)
  }

  /// True during an unlock. The 15-second margin means the event that ends the cool-down
  /// is never mistaken for one inside it, even if iOS delivers it slightly early.
  func isUnlocked(_ ruleId: String, at now: Date = Date()) -> Bool {
    guard let until = unlockedUntil(ruleId) else { return false }
    return now < until.addingTimeInterval(-15)
  }

  /// Recenter is about to stop and restart this rule's monitor. iOS reports that stop as
  /// "interval ended", which must not be mistaken for the real end of a window.
  func markRearming(_ ruleId: String) {
    defaults.set(Date(), forKey: Keys.rearmingAt + ruleId)
  }

  func isRearming(_ ruleId: String, at now: Date = Date()) -> Bool {
    guard let at = defaults.object(forKey: Keys.rearmingAt + ruleId) as? Date else { return false }
    return now.timeIntervalSince(at) < 30
  }

  var interruptionsToday: Int {
    guard defaults.string(forKey: Keys.interruptionDay) == Self.today() else { return 0 }
    return defaults.integer(forKey: Keys.interruptions)
  }

  func recordInterruption() {
    let count = interruptionsToday + 1
    defaults.set(Self.today(), forKey: Keys.interruptionDay)
    defaults.set(count, forKey: Keys.interruptions)
  }

  private static func today() -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }

  private enum Keys {
    static let rules = "rules"
    static let monitoring = "monitoring"
    static let cooldown = "cooldownMinutes"
    static let interruptions = "interruptions"
    static let interruptionDay = "interruptionDay"
    static let unlockedUntil = "unlockedUntil."
    static let rearmingAt = "rearmingAt."
  }
}
