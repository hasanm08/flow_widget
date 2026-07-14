import ClockKit
import Foundation

/// Helper for reloading watchOS complications after Flutter updates App Group data.
public enum FlowWidgetComplicationController {
  /// Requests a timeline reload for all complication families registered by the app.
  public static func reloadAllComplications() {
    let server = CLKComplicationServer.sharedInstance()
    for complication in server.activeComplications ?? [] {
      server.reloadTimeline(for: complication)
    }
  }

  /// Requests a timeline reload for a specific complication descriptor.
  public static func reloadComplication(kind: String) {
    let server = CLKComplicationServer.sharedInstance()
    guard let complications = server.activeComplications else { return }
    for complication in complications where complication.identifier == kind {
      server.reloadTimeline(for: complication)
    }
  }
}

/// Base class for CLI-generated complication data sources.
///
/// Subclasses implement `buildTimelineEntries()` using values from [FlowWidgetStorage].
open class FlowWidgetComplicationDataSource: NSObject {
  public let appGroupId: String
  public let storage: FlowWidgetStorage

  public init(appGroupId: String) {
    self.appGroupId = appGroupId
    self.storage = FlowWidgetStorage(appGroupId: appGroupId)
    super.init()
  }

  /// Reads the latest typed snapshot for a complication family.
  open func snapshot(forFamily family: String) -> [String: Any] {
    storage.getDecoded(key: "complication.\(family)")
  }
}
