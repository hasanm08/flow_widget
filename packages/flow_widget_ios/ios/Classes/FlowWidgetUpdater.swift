import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

final class FlowWidgetUpdater {
    private let storage: FlowWidgetStorage

    init(storage: FlowWidgetStorage) {
        self.storage = storage
    }

    func update(request: [String: Any]) throws {
        try applyRequestData(request)
        reload(
            name: request["name"] as? String,
            reloadTimeline: request["reloadTimeline"] as? Bool ?? true
        )
    }

    func updateMany(requests: [[String: Any]]) throws {
        for request in requests {
            try applyRequestData(request)
            reload(
                name: request["name"] as? String,
                reloadTimeline: request["reloadTimeline"] as? Bool ?? true
            )
        }
    }

    func updateAll() {
        let configs = storage.allRegisteredConfigs()
        for name in configs.keys {
            reload(name: name, reloadTimeline: true)
        }
    }

    func setTimeline(widgetId: [String: Any], entries: [[String: Any]]) throws {
        try storage.setTimeline(widgetId: widgetId, entries: entries)
        reload(name: widgetId["name"] as? String, reloadTimeline: true)
    }

    func getInstalledWidgets() -> [[String: Any]] {
        // WidgetKit does not expose installed widget instances to the host app.
        return []
    }

    func requestPinWidget(name: String, initialData: [String: Any]?) throws -> Bool {
        guard storage.registeredConfig(name: name) != nil else {
            throw FlowWidgetUpdaterError.missingConfig(name)
        }

        if let initialData {
            for (key, value) in initialData {
                guard let wire = value as? [String: Any] else { continue }
                try storage.saveData(key: key, wire: wire)
            }
        }

        reload(name: name, reloadTimeline: true)
        // iOS has no pin API equivalent to Android; opening the gallery is app-specific.
        return false
    }

    private func applyRequestData(_ request: [String: Any]) throws {
        guard let data = request["data"] as? [String: Any] else { return }
        for (key, value) in data {
            guard let wire = value as? [String: Any] else { continue }
            try storage.saveData(key: key, wire: wire)
        }
    }

    private func reload(name: String?, reloadTimeline: Bool) {
        guard reloadTimeline, let name else { return }
        guard let config = storage.registeredConfig(name: name),
              let kind = config["iosKind"] as? String else {
            if #available(iOS 14.0, *) {
                reloadAllTimelines()
            }
            return
        }
        if #available(iOS 14.0, *) {
            reloadTimelines(ofKind: kind)
        }
    }

    @available(iOS 14.0, *)
    private func reloadTimelines(ofKind kind: String) {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
        #endif
    }

    @available(iOS 14.0, *)
    private func reloadAllTimelines() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

enum FlowWidgetUpdaterError: Error, LocalizedError {
    case missingConfig(String)

    var errorDescription: String? {
        switch self {
        case .missingConfig(let name):
            return "No config registered for widget '\(name)'"
        }
    }
}
