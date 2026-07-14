import Foundation

/// App Group backed storage read by watchOS Complication controllers.
public final class FlowWidgetStorage {
  private let defaults: UserDefaults
  private let prefix = "flow_widget."

  public init(appGroupId: String) {
    defaults = UserDefaults(suiteName: appGroupId) ?? .standard
  }

  public func get(key: String) -> [String: Any]? {
    defaults.dictionary(forKey: dataKey(key)) as? [String: Any]
  }

  public func getDecoded(key: String) -> [String: Any] {
    guard let wire = get(key: key) else { return [:] }
    if let nested = wire["t"] as? String, nested == "m",
       let raw = wire["v"] as? [String: Any] {
      return FlowWidgetValueCodec.decodeMap(raw)
    }
    return FlowWidgetValueCodec.decodeMap(wire)
  }

  public func getAll(prefix filterPrefix: String? = nil) -> [String: [String: Any]] {
    var result: [String: [String: Any]] = [:]
    for (fullKey, value) in defaults.dictionaryRepresentation() {
      guard fullKey.hasPrefix(dataPrefix) else { continue }
      let shortKey = String(fullKey.dropFirst(dataPrefix.count))
      if let filterPrefix, !shortKey.hasPrefix(filterPrefix) { continue }
      if let wire = value as? [String: Any] {
        result[shortKey] = wire
      }
    }
    return result
  }

  public func lastUpdateMillis() -> Int {
    defaults.integer(forKey: "\(prefix)last_update")
  }

  private var dataPrefix: String { "\(prefix)data." }

  private func dataKey(_ key: String) -> String {
    "\(dataPrefix)\(key)"
  }
}
