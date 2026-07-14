import Flutter
import UIKit

public class FlowWidgetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private static let methodChannelName = "dev.flow_widget/methods"
    private static let eventChannelName = "dev.flow_widget/events"

    private var storage: FlowWidgetStorage?
    private var imageStore: FlowWidgetImageStore?
    private var updater: FlowWidgetUpdater?
    private var liveActivityManager: FlowWidgetLiveActivityManager?
    private var eventSink: FlutterEventSink?
    private var initialized = false
    private var debugLogging = false
    private var appGroupId: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlowWidgetPlugin()
        let methodChannel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case "initialize":
                try handleInitialize(call.arguments, result: result)
            case "dispose":
                disposeNative()
                result(nil)
            case "getCapabilities":
                result(FlowWidgetCapabilitiesProvider.capabilities())
            case "getPlatformType":
                result("ios")
            case "getInstalledWidgets":
                try ensureInitialized(result: result) {
                    result(self.requireUpdater().getInstalledWidgets())
                }
            case "saveData":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let key = args["key"] as? String,
                          let wire = args["value"] as? [String: Any] else {
                        return badArgs(result, message: "saveData requires key and value")
                    }
                    try self.requireStorage().saveData(
                        key: key,
                        wire: wire,
                        groupId: args["groupId"] as? String
                    )
                    result(nil)
                }
            case "saveBatch":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let entries = args["entries"] as? [[String: Any]] else {
                        return badArgs(result, message: "saveBatch requires entries")
                    }
                    try self.requireStorage().saveBatch(
                        entries: entries,
                        groupId: args["groupId"] as? String
                    )
                    result(nil)
                }
            case "getData":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let key = args["key"] as? String else {
                        return badArgs(result, message: "getData requires key")
                    }
                    let value = try self.requireStorage().getData(
                        key: key,
                        groupId: args["groupId"] as? String
                    )
                    result(value)
                }
            case "getAllData":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any] else {
                        return badArgs(result, message: "getAllData requires arguments map")
                    }
                    let allData = try self.requireStorage().getAllData(
                        prefix: args["prefix"] as? String,
                        groupId: args["groupId"] as? String
                    )
                    result(allData)
                }
            case "removeData":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let key = args["key"] as? String else {
                        return badArgs(result, message: "removeData requires key")
                    }
                    self.requireStorage().removeData(
                        key: key,
                        groupId: args["groupId"] as? String
                    )
                    result(nil)
                }
            case "clearData":
                try ensureInitialized(result: result) {
                    let groupId = (call.arguments as? [String: Any])?["groupId"] as? String
                    self.requireStorage().clearData(groupId: groupId)
                    result(nil)
                }
            case "saveImage":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any] else {
                        return badArgs(result, message: "saveImage requires arguments")
                    }
                    let path = try self.requireImageStore().saveImage(args: args)
                    result(path)
                }
            case "removeImage":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let key = args["key"] as? String else {
                        return badArgs(result, message: "removeImage requires key")
                    }
                    self.requireImageStore().removeImage(key: key)
                    result(nil)
                }
            case "update":
                try ensureInitialized(result: result) {
                    guard let request = call.arguments as? [String: Any] else {
                        return badArgs(result, message: "update requires request")
                    }
                    try self.requireUpdater().update(request: request)
                    result(nil)
                }
            case "updateMany":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let requests = args["requests"] as? [[String: Any]] else {
                        return badArgs(result, message: "updateMany requires requests")
                    }
                    try self.requireUpdater().updateMany(requests: requests)
                    result(nil)
                }
            case "updateAll":
                try ensureInitialized(result: result) {
                    self.requireUpdater().updateAll()
                    result(nil)
                }
            case "setTimeline":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let widgetId = args["widgetId"] as? [String: Any],
                          let entries = args["entries"] as? [[String: Any]] else {
                        return badArgs(result, message: "setTimeline requires widgetId and entries")
                    }
                    try self.requireUpdater().setTimeline(widgetId: widgetId, entries: entries)
                    result(nil)
                }
            case "registerConfig":
                try ensureInitialized(result: result) {
                    guard let config = call.arguments as? [String: Any] else {
                        return badArgs(result, message: "registerConfig requires config")
                    }
                    try self.requireStorage().registerConfig(config)
                    result(nil)
                }
            case "requestPinWidget":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let name = args["name"] as? String else {
                        return badArgs(result, message: "requestPinWidget requires name")
                    }
                    let pinned = try self.requireUpdater().requestPinWidget(
                        name: name,
                        initialData: args["initialData"] as? [String: Any]
                    )
                    result(pinned)
                }
            case "startLiveActivity":
                try ensureInitialized(result: result) {
                    guard let config = call.arguments as? [String: Any] else {
                        return badArgs(result, message: "startLiveActivity requires config")
                    }
                    let activityId = try self.requireLiveActivityManager().start(config: config)
                    result(activityId)
                }
            case "updateLiveActivity":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let activityId = args["activityId"] as? String,
                          let data = args["data"] as? [String: Any] else {
                        return badArgs(result, message: "updateLiveActivity requires activityId and data")
                    }
                    try self.requireLiveActivityManager().update(activityId: activityId, data: data)
                    result(nil)
                }
            case "endLiveActivity":
                try ensureInitialized(result: result) {
                    guard let args = call.arguments as? [String: Any],
                          let activityId = args["activityId"] as? String else {
                        return badArgs(result, message: "endLiveActivity requires activityId")
                    }
                    try self.requireLiveActivityManager().end(
                        activityId: activityId,
                        finalData: args["finalData"] as? [String: Any],
                        dismissalDate: args["dismissalDate"] as? Int
                    )
                    result(nil)
                }
            case "getActiveLiveActivities":
                try ensureInitialized(result: result) {
                    result(self.requireLiveActivityManager().activeActivities())
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch let error as FlowWidgetLiveActivityError {
            if case .unsupported = error {
                unsupported(result, message: error.localizedDescription)
            } else {
                result(FlutterError(code: "live_activity_error", message: error.localizedDescription, details: nil))
            }
        } catch let error as FlowWidgetCodecError {
            badArgs(result, message: error.localizedDescription)
        } catch {
            log("Method \(call.method) failed: \(error.localizedDescription)")
            result(FlutterError(code: "error", message: error.localizedDescription, details: nil))
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

    private func handleInitialize(_ arguments: Any?, result: @escaping FlutterResult) throws {
        let args = arguments as? [String: Any] ?? [:]
        appGroupId = args["appGroupId"] as? String
        let maxCache = (args["imageCacheMaxBytes"] as? NSNumber)?.intValue ?? 20 * 1024 * 1024
        debugLogging = (args["enableDebugLogging"] as? Bool) ?? false

        let suiteStorage = FlowWidgetStorage(suiteName: appGroupId)
        storage = suiteStorage
        let container = appGroupId.flatMap { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: $0) }
        imageStore = FlowWidgetImageStore(containerURL: container, maxCacheBytes: maxCache)
        updater = FlowWidgetUpdater(storage: suiteStorage)
        liveActivityManager = FlowWidgetLiveActivityManager(storage: suiteStorage)
        liveActivityManager?.setEventEmitter { [weak self] event in
            DispatchQueue.main.async {
                self?.eventSink?(event)
            }
        }
        initialized = true
        log("Initialized with appGroupId=\(appGroupId ?? "standard")")
        result(nil)
    }

    private func disposeNative() {
        imageStore?.clear()
        storage = nil
        imageStore = nil
        updater = nil
        liveActivityManager = nil
        initialized = false
    }

    private func ensureInitialized(result: @escaping FlutterResult, block: () throws -> Void) throws {
        guard initialized else {
            result(FlutterError(code: "not_initialized", message: "Call initialize() before other methods", details: nil))
            return
        }
        try block()
    }

    private func badArgs(_ result: @escaping FlutterResult, message: String) {
        result(FlutterError(code: "bad_args", message: message, details: nil))
    }

    private func unsupported(_ result: @escaping FlutterResult, message: String) {
        result(FlutterError(code: "unsupported", message: message, details: nil))
    }

    private func requireStorage() -> FlowWidgetStorage {
        guard let storage else {
            preconditionFailure("Storage not initialized")
        }
        return storage
    }

    private func requireImageStore() -> FlowWidgetImageStore {
        guard let imageStore else {
            preconditionFailure("Image store not initialized")
        }
        return imageStore
    }

    private func requireUpdater() -> FlowWidgetUpdater {
        guard let updater else {
            preconditionFailure("Updater not initialized")
        }
        return updater
    }

    private func requireLiveActivityManager() -> FlowWidgetLiveActivityManager {
        guard let liveActivityManager else {
            preconditionFailure("Live activity manager not initialized")
        }
        return liveActivityManager
    }

    private func log(_ message: String) {
        if debugLogging {
            NSLog("[FlowWidgetPlugin] %@", message)
        }
    }
}
