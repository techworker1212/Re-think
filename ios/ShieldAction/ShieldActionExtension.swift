import ManagedSettings

/// Primary button closes the app; secondary unlocks that rule for the cool-down.
class ShieldActionExtension: ShieldActionDelegate {
  private let store = RuleStore.shared

  override func handle(
    action: ShieldAction,
    for application: ApplicationToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    respond(to: action, rule: store.rule(application: application), completionHandler)
  }

  override func handle(
    action: ShieldAction,
    for webDomain: WebDomainToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    respond(to: action, rule: store.rule(webDomain: webDomain), completionHandler)
  }

  override func handle(
    action: ShieldAction,
    for category: ActivityCategoryToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    respond(to: action, rule: store.rule(category: category), completionHandler)
  }

  private func respond(
    to action: ShieldAction,
    rule: StoredRule?,
    _ completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    switch action {
    case .secondaryButtonPressed:
      if let rule {
        RuleScheduler.unlock(rule.id, store: store)
      }
      // .defer re-evaluates the (now cleared) shield instead of closing the app.
      completionHandler(.defer)
    default:
      // Primary button ("Close …") and any action added in later iOS versions.
      completionHandler(.close)
    }
  }
}
