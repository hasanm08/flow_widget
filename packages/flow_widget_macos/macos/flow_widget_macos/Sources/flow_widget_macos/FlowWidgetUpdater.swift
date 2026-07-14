import Foundation
import WidgetKit

/// Triggers WidgetKit timeline reloads on macOS.
enum FlowWidgetUpdater {
  @available(macOS 11.0, *)
  static func reload(name: String, storage: FlowWidgetStorage) {
    if let kind = storage.macosKind(for: name) {
      WidgetCenter.shared.reloadTimelines(ofKind: kind)
    } else {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }

  @available(macOS 11.0, *)
  static func reloadAll() {
    WidgetCenter.shared.reloadAllTimelines()
  }
}
