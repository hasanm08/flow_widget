import Foundation

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// Bridge between the paired iOS Flutter host and the watchOS extension.
///
/// Flutter writes typed values to the shared App Group from the iOS app.
/// The Watch extension reads the same store and reloads complications.
public enum FlowWidgetWatchBridge {
  /// Notification posted when App Group data changes. Observe in the Watch extension.
  public static let dataDidChangeNotification = Notification.Name("FlowWidgetWatchDataDidChange")

  /// Called from the iOS host after persisting data to the App Group.
  public static func notifyWatchExtension(appGroupId: String) {
    UserDefaults(suiteName: appGroupId)?.set(
      Date().timeIntervalSince1970,
      forKey: "flow_widget.watch_ping"
    )
    #if canImport(WatchConnectivity)
    if WCSession.isSupported() {
      let session = WCSession.default
      if session.activationState == .activated {
        session.transferUserInfo(["flow_widget": "update"])
      }
    }
    #endif
    NotificationCenter.default.post(name: dataDidChangeNotification, object: nil)
  }

  /// Called from the Watch extension when data may have changed.
  public static func handleDataUpdate(appGroupId: String) {
    FlowWidgetComplicationController.reloadAllComplications()
  }
}
