import Cocoa
import FlutterMacOS
import WidgetKit

/// macOS federated implementation of the flow_widget Method/Event channels.
public class FlowWidgetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var storage: FlowWidgetStorage?
  private var imageStore: FlowWidgetImageStore?
  private var eventSink: FlutterEventSink?
  private var initialized = false

  private static let unsupportedLiveActivity = FlutterError(
    code: "unsupported",
    message: "Live Activities are not available on macOS.",
    details: nil
  )

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlowWidgetPlugin()
    let methodChannel = FlutterMethodChannel(
      name: "dev.flow_widget/methods",
      binaryMessenger: registrar.messenger
    )
    let eventChannel = FlutterEventChannel(
      name: "dev.flow_widget/events",
      binaryMessenger: registrar.messenger
    )
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      handleInitialize(call.arguments, result: result)
    case "dispose":
      initialized = false
      storage = nil
      imageStore = nil
      result(nil)
    case "getCapabilities":
      result(capabilities())
    case "getPlatformType":
      result("macos")
    case "getInstalledWidgets":
      result([])
    case "saveData":
      handleSaveData(call.arguments, result: result)
    case "saveBatch":
      handleSaveBatch(call.arguments, result: result)
    case "getData":
      handleGetData(call.arguments, result: result)
    case "getAllData":
      handleGetAllData(call.arguments, result: result)
    case "removeData":
      handleRemoveData(call.arguments, result: result)
    case "clearData":
      requireStorage(result: result) { storage in
        storage.clear()
        result(nil)
      }
    case "saveImage":
      handleSaveImage(call.arguments, result: result)
    case "removeImage":
      handleRemoveImage(call.arguments, result: result)
    case "update":
      handleUpdate(call.arguments, result: result)
    case "updateMany":
      handleUpdateMany(call.arguments, result: result)
    case "updateAll":
      handleUpdateAll(result: result)
    case "setTimeline":
      handleSetTimeline(call.arguments, result: result)
    case "registerConfig":
      handleRegisterConfig(call.arguments, result: result)
    case "requestPinWidget":
      result(false)
    case "startLiveActivity", "updateLiveActivity", "endLiveActivity":
      result(Self.unsupportedLiveActivity)
    case "getActiveLiveActivities":
      result([])
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func handleInitialize(_ arguments: Any?, result: @escaping FlutterResult) {
    let args = arguments as? [String: Any] ?? [:]
    let appGroupId = args["appGroupId"] as? String
    storage = FlowWidgetStorage(appGroupId: appGroupId)
    imageStore = FlowWidgetImageStore(appGroupId: appGroupId)
    initialized = true
    result(nil)
  }

  private func requireStorage(result: @escaping FlutterResult, block: (FlowWidgetStorage) -> Void) {
    guard let storage else {
      result(FlutterError(code: "not_initialized", message: "Call initialize() first.", details: nil))
      return
    }
    block(storage)
  }

  private func handleSaveData(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let key = args["key"] as? String,
          let wire = args["value"] as? [String: Any] else {
      result(FlutterError(code: "bad_args", message: "saveData requires key and value.", details: nil))
      return
    }
    requireStorage(result: result) { storage in
      storage.save(key: key, wire: wire)
      result(nil)
    }
  }

  private func handleSaveBatch(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let entries = args["entries"] as? [[String: Any]] else {
      result(FlutterError(code: "bad_args", message: "saveBatch requires entries.", details: nil))
      return
    }
    requireStorage(result: result) { storage in
      storage.saveBatch(entries: entries)
      result(nil)
    }
  }

  private func handleGetData(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let key = args["key"] as? String else {
      result(FlutterError(code: "bad_args", message: "getData requires key.", details: nil))
      return
    }
    requireStorage(result: result) { storage in
      result(storage.get(key: key))
    }
  }

  private func handleGetAllData(_ arguments: Any?, result: @escaping FlutterResult) {
    let args = arguments as? [String: Any] ?? [:]
    let prefix = args["prefix"] as? String
    requireStorage(result: result) { storage in
      result(storage.getAll(prefix: prefix))
    }
  }

  private func handleRemoveData(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let key = args["key"] as? String else {
      result(FlutterError(code: "bad_args", message: "removeData requires key.", details: nil))
      return
    }
    requireStorage(result: result) { storage in
      storage.remove(key: key)
      result(nil)
    }
  }

  private func handleSaveImage(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let key = args["key"] as? String,
          let imageStore else {
      result(FlutterError(code: "bad_args", message: "saveImage requires key and bytes.", details: nil))
      return
    }
    let mimeType = args["mimeType"] as? String ?? "image/png"
    if let typed = args["bytes"] as? FlutterStandardTypedData {
      do {
        let path = try imageStore.save(key: key, bytes: typed.data, mimeType: mimeType)
        result(path)
      } catch {
        result(FlutterError(code: "io_error", message: error.localizedDescription, details: nil))
      }
      return
    }
    if args["url"] != nil {
      result(FlutterError(
        code: "unsupported",
        message: "Remote image caching is not implemented on macOS.",
        details: nil
      ))
      return
    }
    result(FlutterError(code: "bad_args", message: "saveImage requires bytes.", details: nil))
  }

  private func handleRemoveImage(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let key = args["key"] as? String,
          let imageStore else {
      result(FlutterError(code: "bad_args", message: "removeImage requires key.", details: nil))
      return
    }
    imageStore.remove(key: key)
    result(nil)
  }

  private func handleUpdate(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let name = args["name"] as? String else {
      result(FlutterError(code: "bad_args", message: "update requires name.", details: nil))
      return
    }
    requireStorage(result: result) { storage in
      if let data = args["data"] as? [String: Any] {
        for (key, wire) in data {
          if let wireMap = wire as? [String: Any] {
            storage.save(key: key, wire: wireMap)
          }
        }
      }
      storage.setLastUpdate(millis: currentMillis())
      if #available(macOS 11.0, *) {
        FlowWidgetUpdater.reload(name: name, storage: storage)
      }
      result(nil)
    }
  }

  private func handleUpdateMany(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let requests = args["requests"] as? [[String: Any]] else {
      result(FlutterError(code: "bad_args", message: "updateMany requires requests.", details: nil))
      return
    }
    requireStorage(result: result) { storage in
      if #available(macOS 11.0, *) {
        for request in requests {
          if let name = request["name"] as? String {
            if let data = request["data"] as? [String: Any] {
              for (key, wire) in data {
                if let wireMap = wire as? [String: Any] {
                  storage.save(key: key, wire: wireMap)
                }
              }
            }
            FlowWidgetUpdater.reload(name: name, storage: storage)
          }
        }
      }
      storage.setLastUpdate(millis: currentMillis())
      result(nil)
    }
  }

  private func handleUpdateAll(result: @escaping FlutterResult) {
    requireStorage(result: result) { storage in
      storage.setLastUpdate(millis: currentMillis())
      if #available(macOS 11.0, *) {
        FlowWidgetUpdater.reloadAll()
      }
      result(nil)
    }
  }

  private func handleSetTimeline(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [String: Any],
          let widgetIdMap = args["widgetId"] as? [String: Any],
          let name = widgetIdMap["name"] as? String,
          let entries = args["entries"] as? [[String: Any]] else {
      result(FlutterError(code: "bad_args", message: "setTimeline requires widgetId and entries.", details: nil))
      return
    }
    let widgetId = widgetIdMap["id"] as? Int
    requireStorage(result: result) { storage in
      storage.setTimeline(widgetName: name, widgetId: widgetId, entries: entries)
      if #available(macOS 11.0, *) {
        FlowWidgetUpdater.reload(name: name, storage: storage)
      }
      result(nil)
    }
  }

  private func handleRegisterConfig(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let config = arguments as? [String: Any] else {
      result(FlutterError(code: "bad_args", message: "registerConfig requires config.", details: nil))
      return
    }
    requireStorage(result: result) { storage in
      storage.registerConfig(config)
      result(nil)
    }
  }

  private func capabilities() -> [String: Bool] {
    [
      "homeWidgets": true,
      "interactiveWidgets": true,
      "timelineProviders": true,
      "appGroups": true,
      "backgroundUpdates": true,
      "liveActivities": false,
      "dynamicIsland": false,
      "lockScreenWidgets": false,
      "configurableWidgets": true,
      "pinWidget": false,
      "scheduledUpdates": false,
      "pushUpdates": false,
      "remoteImageCaching": false,
      "wearTiles": false,
      "complications": false,
      "multipleInstances": true,
      "resizing": true,
      "themeSynchronization": false,
      "appIntents": false,
    ]
  }

  private func currentMillis() -> Int {
    Int(Date().timeIntervalSince1970 * 1000)
  }
}
