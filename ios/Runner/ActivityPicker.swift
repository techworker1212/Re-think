import FamilyControls
import SwiftUI
import UIKit

/// Wraps Apple's FamilyActivityPicker. Apple never reveals the picked app's name to
/// Re-think, which is why the Flutter editor asks the user for a label.
struct ActivityPickerView: View {
  @State var selection = FamilyActivitySelection()
  let onFinish: (FamilyActivitySelection?) -> Void

  var body: some View {
    NavigationStack {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle("Pick an app")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { onFinish(nil) }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") { onFinish(selection) }
              .disabled(isEmpty)
          }
        }
    }
  }

  private var isEmpty: Bool {
    selection.applicationTokens.isEmpty
      && selection.categoryTokens.isEmpty
      && selection.webDomainTokens.isEmpty
  }
}

enum ActivitySelectionCoding {
  /// The selection travels through Flutter as an opaque string (the rule's platformAppId).
  static func encode(_ selection: FamilyActivitySelection) -> String? {
    (try? JSONEncoder().encode(selection))?.base64EncodedString()
  }

  static func decode(_ value: String) -> FamilyActivitySelection? {
    guard let data = Data(base64Encoded: value) else { return nil }
    return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
  }
}
