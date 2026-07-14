import Foundation
import FlutterMacOS

/// Encodes and decodes flow_widget wire values `{t, v}`.
enum FlowWidgetValueCodec {
  static func encode(_ value: Any) -> [String: Any] {
    switch value {
    case let string as String:
      return ["t": "s", "v": string]
    case let int as Int:
      return ["t": "i", "v": int]
    case let int64 as Int64:
      return ["t": "i", "v": Int(int64)]
    case let double as Double:
      return ["t": "d", "v": double]
    case let float as Float:
      return ["t": "d", "v": Double(float)]
    case let bool as Bool:
      return ["t": "b", "v": bool]
    case let date as Date:
      return ["t": "dt", "v": Int(date.timeIntervalSince1970 * 1000)]
    case let data as Data:
      return ["t": "bin", "v": FlutterStandardTypedData(bytes: data)]
    case let map as [String: Any]:
      var encoded: [String: Any] = [:]
      for (key, nested) in map {
        encoded[key] = encode(nested)
      }
      return ["t": "m", "v": encoded]
    case let list as [Any]:
      return ["t": "l", "v": list.map { encode($0) }]
    case let wire as [String: Any] where wire["t"] != nil:
      return wire
    default:
      return ["t": "s", "v": String(describing: value)]
    }
  }

  static func decode(_ wire: [String: Any]) -> Any? {
    guard let type = wire["t"] as? String else { return nil }
    let value = wire["v"]
    switch type {
    case "s":
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
      if let int = value as? Int {
        millis = int
      } else if let int64 = value as? Int64 {
        millis = Int(int64)
      } else if let num = value as? NSNumber {
        millis = num.intValue
      } else {
        return nil
      }
      return Date(timeIntervalSince1970: TimeInterval(millis) / 1000.0)
    case "j":
      return value as? String
    case "bin":
      if let typed = value as? FlutterStandardTypedData {
        return typed.data
      }
      if let data = value as? Data {
        return data
      }
      return nil
    case "m":
      guard let raw = value as? [String: Any] else { return nil }
      var decoded: [String: Any] = [:]
      for (key, nested) in raw {
        if let nestedWire = nested as? [String: Any], let decodedValue = decode(nestedWire) {
          decoded[key] = decodedValue
        }
      }
      return decoded
    case "l":
      guard let raw = value as? [Any] else { return nil }
      return raw.compactMap { item -> Any? in
        guard let itemWire = item as? [String: Any] else { return nil }
        return decode(itemWire)
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

  static func encodeMap(_ map: [String: Any]) -> [String: Any] {
    var result: [String: Any] = [:]
    for (key, value) in map {
      result[key] = encode(value)
    }
    return result
  }
}
