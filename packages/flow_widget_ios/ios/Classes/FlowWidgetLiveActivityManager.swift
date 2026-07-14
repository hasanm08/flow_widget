import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

@available(iOS 16.1, *)
struct FlowWidgetActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var data: [String: String]
    }

    var attributesType: String
}

final class FlowWidgetLiveActivityManager {
    private let storage: FlowWidgetStorage
    private var eventEmitter: (([String: Any]) -> Void)?

    init(storage: FlowWidgetStorage) {
        self.storage = storage
    }

    func setEventEmitter(_ emitter: @escaping ([String: Any]) -> Void) {
        eventEmitter = emitter
    }

    func start(config: [String: Any]) throws -> String {
        guard #available(iOS 16.1, *) else {
            throw FlowWidgetLiveActivityError.unsupported
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw FlowWidgetLiveActivityError.disabled
        }

        guard let attributesType = config["attributesType"] as? String else {
            throw FlowWidgetLiveActivityError.badArgs("attributesType is required")
        }

        let rawData = config["data"] as? [String: Any] ?? [:]
        let contentStrings = try FlowWidgetValueCodec.contentStateStrings(from: rawData)
        let staleDate = (config["staleDate"] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue / 1000.0) }

        let attributes = FlowWidgetActivityAttributes(attributesType: attributesType)
        let content = ActivityContent(
            state: FlowWidgetActivityAttributes.ContentState(data: contentStrings),
            staleDate: staleDate
        )

        let activity = try Activity<FlowWidgetActivityAttributes>.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )

        let activityId = activity.id
        try storage.storeLiveActivityRecord(
            activityId: activityId,
            attributesType: attributesType,
            data: contentStrings,
            startedAt: Int(Date().timeIntervalSince1970 * 1000),
            staleDate: staleDate.map { Int($0.timeIntervalSince1970 * 1000) }
        )

        emit(phase: "started", activityId: activityId)
        return activityId
    }

    func update(activityId: String, data: [String: Any]) throws {
        guard #available(iOS 16.1, *) else {
            throw FlowWidgetLiveActivityError.unsupported
        }

        let contentStrings = try FlowWidgetValueCodec.contentStateStrings(from: data)
        guard let activity = findActivity(id: activityId) else {
            throw FlowWidgetLiveActivityError.notFound(activityId)
        }

        let content = ActivityContent(
            state: FlowWidgetActivityAttributes.ContentState(data: contentStrings),
            staleDate: nil
        )

        Task {
            await activity.update(content)
        }

        if var record = storage.liveActivityRecord(activityId: activityId) {
            try storage.storeLiveActivityRecord(
                activityId: activityId,
                attributesType: record["attributesType"] as? String ?? "FlowWidgetActivityAttributes",
                data: contentStrings,
                startedAt: record["startedAt"] as? Int ?? Int(Date().timeIntervalSince1970 * 1000),
                staleDate: record["staleDate"] as? Int
            )
        }

        emit(phase: "updated", activityId: activityId)
    }

    func end(activityId: String, finalData: [String: Any]?, dismissalDate: Int?) throws {
        guard #available(iOS 16.1, *) else {
            throw FlowWidgetLiveActivityError.unsupported
        }

        let contentStrings: [String: String]
        if let finalData {
            contentStrings = try FlowWidgetValueCodec.contentStateStrings(from: finalData)
        } else if let record = storage.liveActivityRecord(activityId: activityId),
                  let stored = record["data"] as? [String: String] {
            contentStrings = stored
        } else {
            contentStrings = [:]
        }

        let dismissal = dismissalDate.map { Date(timeIntervalSince1970: Double($0) / 1000.0) }
        let content = ActivityContent(
            state: FlowWidgetActivityAttributes.ContentState(data: contentStrings),
            staleDate: dismissal
        )

        if let activity = findActivity(id: activityId) {
            Task {
                await activity.end(content, dismissalPolicy: .default)
            }
        }

        storage.removeLiveActivityRecord(activityId: activityId)
        emit(phase: "ended", activityId: activityId)
    }

    func activeActivities() -> [[String: Any]] {
        if #available(iOS 16.1, *) {
            let live = Activity<FlowWidgetActivityAttributes>.activities.map { activity -> [String: Any] in
                let record = storage.liveActivityRecord(activityId: activity.id)
                var payload: [String: Any] = [
                    "activityId": activity.id,
                    "attributesType": record?["attributesType"] as? String ?? "FlowWidgetActivityAttributes",
                    "data": FlowWidgetValueCodec.wireMap(from: activity.content.state.data),
                    "startedAt": record?["startedAt"] as? Int ?? Int(Date().timeIntervalSince1970 * 1000),
                ]
                if let staleDate = record?["staleDate"] as? Int {
                    payload["staleDate"] = staleDate
                }
                return payload
            }
            if !live.isEmpty {
                return live
            }
        }

        return storage.allLiveActivityRecords().map { record in
            let data = record["data"] as? [String: String] ?? [:]
            var payload: [String: Any] = [
                "activityId": record["activityId"] as? String ?? "",
                "attributesType": record["attributesType"] as? String ?? "",
                "data": FlowWidgetValueCodec.wireMap(from: data),
                "startedAt": record["startedAt"] as? Int ?? 0,
            ]
            if let staleDate = record["staleDate"] as? Int {
                payload["staleDate"] = staleDate
            }
            return payload
        }
    }

    @available(iOS 16.1, *)
    private func findActivity(id: String) -> Activity<FlowWidgetActivityAttributes>? {
        return Activity<FlowWidgetActivityAttributes>.activities.first { $0.id == id }
    }

    private func emit(phase: String, activityId: String) {
        eventEmitter?([
            "type": "liveActivity",
            "phase": phase,
            "activityId": activityId,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000),
        ])
    }
}

enum FlowWidgetLiveActivityError: Error, LocalizedError {
    case unsupported
    case disabled
    case badArgs(String)
    case notFound(String)

    var errorDescription: String? {
        switch self {
        case .unsupported:
            return "Live Activities require iOS 16.1 or later"
        case .disabled:
            return "Live Activities are disabled on this device"
        case .badArgs(let message):
            return message
        case .notFound(let id):
            return "Live Activity not found: \(id)"
        }
    }
}
