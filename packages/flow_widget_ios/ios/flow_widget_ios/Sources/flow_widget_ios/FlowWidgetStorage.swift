import Foundation

final class FlowWidgetStorage {
    private let defaults: UserDefaults
    private let dataPrefix = "flow_widget.data."
    private let configPrefix = "flow_widget.config."
    private let timelinePrefix = "flow_widget.timeline."
    private let metadataPrefix = "flow_widget.meta."

    init(suiteName: String?) {
        if let suiteName, let shared = UserDefaults(suiteName: suiteName) {
            defaults = shared
        } else {
            defaults = .standard
        }
    }

    func saveData(key: String, wire: [String: Any], groupId: String? = nil) throws {
        let storageKey = dataPrefix + Self.scopedKey(groupId: groupId, key: key)
        let data = try FlowWidgetValueCodec.encodeToJsonData(wire)
        defaults.set(data, forKey: storageKey)
    }

    func saveBatch(entries: [[String: Any]], groupId: String? = nil) throws {
        for entry in entries {
            guard let key = entry["key"] as? String,
                  let wire = entry["value"] as? [String: Any] else { continue }
            try saveData(key: key, wire: wire, groupId: groupId)
        }
    }

    func getData(key: String, groupId: String? = nil) throws -> [String: Any]? {
        let storageKey = dataPrefix + Self.scopedKey(groupId: groupId, key: key)
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try FlowWidgetValueCodec.decodeFromJsonData(data)
    }

    func getAllData(prefix: String? = nil, groupId: String? = nil) throws -> [String: [String: Any]] {
        let groupPrefix: String
        if let groupId, !groupId.isEmpty {
            groupPrefix = dataPrefix + "\(groupId)::"
        } else {
            groupPrefix = dataPrefix
        }
        let keyPrefix = prefix.map { groupPrefix + $0 } ?? groupPrefix

        var result: [String: [String: Any]] = [:]
        for (storageKey, value) in defaults.dictionaryRepresentation() {
            guard storageKey.hasPrefix(keyPrefix), let data = value as? Data else { continue }
            let logicalKey = String(storageKey.dropFirst(groupPrefix.count))
            result[logicalKey] = try FlowWidgetValueCodec.decodeFromJsonData(data)
        }
        return result
    }

    func removeData(key: String, groupId: String? = nil) {
        let storageKey = dataPrefix + Self.scopedKey(groupId: groupId, key: key)
        defaults.removeObject(forKey: storageKey)
    }

    func clearData(groupId: String? = nil) {
        let prefix: String
        if let groupId, !groupId.isEmpty {
            prefix = dataPrefix + "\(groupId)::"
        } else {
            prefix = dataPrefix
        }
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }

    func registerConfig(_ config: [String: Any]) throws {
        guard let name = config["name"] as? String else { return }
        let data = try JSONSerialization.data(withJSONObject: config, options: [])
        defaults.set(data, forKey: configPrefix + name)
    }

    func registeredConfig(name: String) -> [String: Any]? {
        guard let data = defaults.data(forKey: configPrefix + name),
              let object = try? JSONSerialization.jsonObject(with: data),
              let config = object as? [String: Any] else {
            return nil
        }
        return config
    }

    func allRegisteredConfigs() -> [String: [String: Any]] {
        var result: [String: [String: Any]] = [:]
        for (key, value) in defaults.dictionaryRepresentation() {
            guard key.hasPrefix(configPrefix),
                  let data = value as? Data,
                  let object = try? JSONSerialization.jsonObject(with: data),
                  let config = object as? [String: Any],
                  let name = config["name"] as? String else { continue }
            result[name] = config
        }
        return result
    }

    func setTimeline(widgetId: [String: Any], entries: [[String: Any]]) throws {
        guard let name = widgetId["name"] as? String else { return }
        let id = widgetId["id"] as? Int
        let key = timelinePrefix + timelineKey(name: name, id: id)
        let data = try JSONSerialization.data(withJSONObject: entries, options: [])
        defaults.set(data, forKey: key)
    }

    func timeline(name: String, id: Int?) -> [[String: Any]] {
        let key = timelinePrefix + timelineKey(name: name, id: id)
        guard let data = defaults.data(forKey: key),
              let entries = try? JSONSerialization.jsonObject(with: data),
              let array = entries as? [[String: Any]] else {
            return []
        }
        return array
    }

    func setMetadata(key: String, value: String) {
        defaults.set(value, forKey: metadataPrefix + key)
    }

    func metadata(key: String) -> String? {
        defaults.string(forKey: metadataPrefix + key)
    }

    func storeLiveActivityRecord(
        activityId: String,
        attributesType: String,
        data: [String: String],
        startedAt: Int,
        staleDate: Int?
    ) throws {
        var record: [String: Any] = [
            "activityId": activityId,
            "attributesType": attributesType,
            "data": data,
            "startedAt": startedAt,
        ]
        if let staleDate {
            record["staleDate"] = staleDate
        }
        let encoded = try JSONSerialization.data(withJSONObject: record, options: [])
        defaults.set(encoded, forKey: liveActivityKey(activityId))
    }

    func liveActivityRecord(activityId: String) -> [String: Any]? {
        guard let data = defaults.data(forKey: liveActivityKey(activityId)),
              let record = try? JSONSerialization.jsonObject(with: data),
              let map = record as? [String: Any] else {
            return nil
        }
        return map
    }

    func removeLiveActivityRecord(activityId: String) {
        defaults.removeObject(forKey: liveActivityKey(activityId))
    }

    func allLiveActivityRecords() -> [[String: Any]] {
        var records: [[String: Any]] = []
        for (key, value) in defaults.dictionaryRepresentation() {
            guard key.hasPrefix(liveActivityPrefix),
                  let data = value as? Data,
                  let record = try? JSONSerialization.jsonObject(with: data),
                  let map = record as? [String: Any] else { continue }
            records.append(map)
        }
        return records
    }

    private static func scopedKey(groupId: String?, key: String) -> String {
        if let groupId, !groupId.isEmpty {
            return "\(groupId)::\(key)"
        }
        return key
    }

    private func timelineKey(name: String, id: Int?) -> String {
        if let id {
            return "\(name)#\(id)"
        }
        return name
    }

    private let liveActivityPrefix = "flow_widget.live_activity."
    private func liveActivityKey(_ activityId: String) -> String {
        liveActivityPrefix + activityId
    }
}
