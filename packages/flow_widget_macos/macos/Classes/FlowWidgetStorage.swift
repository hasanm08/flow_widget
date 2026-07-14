import Foundation

/// App Group backed typed key/value storage for macOS widgets.
final class FlowWidgetStorage {
  private let defaults: UserDefaults
  private let prefix: String

  init(appGroupId: String?, prefix: String = "flow_widget.") {
    self.prefix = prefix
    if let appGroupId, let suite = UserDefaults(suiteName: appGroupId) {
      defaults = suite
    } else {
      defaults = .standard
    }
  }

  func save(key: String, wire: [String: Any]) {
    defaults.set(wire, forKey: storageKey(key))
  }

  func saveBatch(entries: [[String: Any]]) {
    for entry in entries {
      guard let key = entry["key"] as? String,
            let value = entry["value"] as? [String: Any] else { continue }
      save(key: key, wire: value)
    }
  }

  func get(key: String) -> [String: Any]? {
    defaults.dictionary(forKey: storageKey(key)) as? [String: Any]
  }

  func getAll(prefix filterPrefix: String?) -> [String: [String: Any]] {
    let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
    var result: [String: [String: Any]] = [:]
    for fullKey in keys {
      let shortKey = String(fullKey.dropFirst(prefix.count))
      if let filterPrefix, !shortKey.hasPrefix(filterPrefix) { continue }
      if let wire = defaults.dictionary(forKey: fullKey) as? [String: Any] {
        result[shortKey] = wire
      }
    }
    return result
  }

  func remove(key: String) {
    defaults.removeObject(forKey: storageKey(key))
  }

  func clear() {
    let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
    for key in keys {
      defaults.removeObject(forKey: key)
    }
  }

  func registerConfig(_ config: [String: Any]) {
    guard let name = config["name"] as? String else { return }
    var configs = defaults.dictionary(forKey: "\(prefix)configs") as? [String: Any] ?? [:]
    configs[name] = config
    defaults.set(configs, forKey: "\(prefix)configs")
  }

  func config(for name: String) -> [String: Any]? {
    let configs = defaults.dictionary(forKey: "\(prefix)configs") as? [String: Any]
    return configs?[name] as? [String: Any]
  }

  func macosKind(for name: String) -> String? {
    config(for: name)?["macosKind"] as? String
  }

  func setTimeline(widgetName: String, widgetId: Int?, entries: [[String: Any]]) {
    let key = timelineKey(name: widgetName, id: widgetId)
    defaults.set(entries, forKey: key)
  }

  func getTimeline(widgetName: String, widgetId: Int?) -> [[String: Any]]? {
    defaults.array(forKey: timelineKey(name: widgetName, id: widgetId)) as? [[String: Any]]
  }

  func setLastUpdate(millis: Int) {
    defaults.set(millis, forKey: "\(prefix)last_update")
  }

  private func storageKey(_ key: String) -> String {
    "\(prefix)data.\(key)"
  }

  private func timelineKey(name: String, id: Int?) -> String {
    if let id {
      return "\(prefix)timeline.\(name)#\(id)"
    }
    return "\(prefix)timeline.\(name)"
  }
}
