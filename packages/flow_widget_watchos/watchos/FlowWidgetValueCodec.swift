import Foundation

/// Encodes and decodes flow_widget wire values `{t, v}` for watchOS.
enum FlowWidgetValueCodec {
  static func decode(_ wire: [String: Any]) -> Any? {
    guard let type = wire["t"] as? String else { return nil }
    let value = wire["v"]
    switch type {
    case "s", "j":
      return value as? String
    case "i":
      if let int = value as? Int { return int }
      if let int64 = value as? Int64 { return Int(int64) }
      if let num = value as? NSNumber { return num.intValue }
      return nil
    case "d":
      if let double = value as? Double { return double }
      if let num = value as? NSNumber { return num.doubleValue }
      return nil
    case "b":
      return value as? Bool
    case "dt":
      let millis: Int
      if let int = value as? Int { millis = int }
      else if let int64 = value as? Int64 { millis = Int(int64) }
      else if let num = value as? NSNumber { millis = num.intValue }
      else { return nil }
      return Date(timeIntervalSince1970: TimeInterval(millis) / 1000.0)
    case "bin":
      return value as? Data
    case "m":
      guard let raw = value as? [String: Any] else { return nil }
      return raw.compactMapValues { item -> Any? in
        guard let wire = item as? [String: Any] else { return nil }
        return decode(wire)
      }
    case "l":
      guard let raw = value as? [Any] else { return nil }
      return raw.compactMap { item -> Any? in
        guard let wire = item as? [String: Any] else { return nil }
        return decode(wire)
      }
    default:
      return nil
    }
  }

  static func decodeMap(_ wire: [String: Any]) -> [String: Any] {
    var result: [String: Any] = [:]
    for (key, nested) in wire {
      if let nestedWire = nested as? [String: Any], let decoded = decode(nestedWire) {
        result[key] = decoded
      }
    }
    return result
  }
}
