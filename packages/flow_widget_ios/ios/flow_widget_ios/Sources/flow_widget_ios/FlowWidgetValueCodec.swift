import Flutter
import Foundation

enum FlowWidgetValueCodec {
    private static let typeKey = "t"
    private static let valueKey = "v"

    static func encode(_ wire: [String: Any]) throws -> [String: Any] {
        guard let type = wire[typeKey] as? String else {
            throw FlowWidgetCodecError.missingType
        }
        let value = wire[valueKey]
        return [typeKey: type, valueKey: try encodeValue(type: type, value: value)]
    }

    static func decode(_ wire: [String: Any]) throws -> [String: Any] {
        guard let type = wire[typeKey] as? String else {
            throw FlowWidgetCodecError.missingType
        }
        let value = wire[valueKey]
        return [typeKey: type, valueKey: try decodeValue(type: type, value: value)]
    }

    static func encodeToJsonData(_ wire: [String: Any]) throws -> Data {
        let encoded = try encode(wire)
        return try JSONSerialization.data(withJSONObject: encoded, options: [])
    }

    static func decodeFromJsonData(_ data: Data) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        guard let wire = object as? [String: Any] else {
            throw FlowWidgetCodecError.invalidPayload
        }
        return try decode(wire)
    }

    static func contentStateStrings(from data: [String: Any]) throws -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in data {
            guard let wire = value as? [String: Any] else { continue }
            result[key] = try scalarString(from: wire)
        }
        return result
    }

    static func wireMap(from strings: [String: String]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in strings {
            if let data = value.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data),
               let wire = json as? [String: Any],
               wire[typeKey] != nil {
                result[key] = wire
            } else {
                result[key] = [typeKey: "s", valueKey: value]
            }
        }
        return result
    }

    private static func scalarString(from wire: [String: Any]) throws -> String {
        let encoded = try encode(wire)
        let data = try JSONSerialization.data(withJSONObject: encoded, options: [])
        guard let string = String(data: data, encoding: .utf8) else {
            throw FlowWidgetCodecError.invalidPayload
        }
        return string
    }

    private static func encodeValue(type: String, value: Any?) throws -> Any {
        switch type {
        case "m":
            guard let map = value as? [String: Any] else { return [:] }
            var encoded: [String: Any] = [:]
            for (key, nested) in map {
                guard let wire = nested as? [String: Any] else { continue }
                encoded[key] = try encode(wire)
            }
            return encoded
        case "l":
            guard let list = value as? [Any] else { return [] }
            return try list.map { item -> Any in
                guard let wire = item as? [String: Any] else { return item }
                return try encode(wire)
            }
        case "bin":
            if let data = value as? Data {
                return data.base64EncodedString()
            }
            if let bytes = value as? [Int] {
                let data = Data(bytes.map { UInt8(truncatingIfNeeded: $0) })
                return data.base64EncodedString()
            }
            if let flutterData = value as? FlutterStandardTypedData {
                return flutterData.data.base64EncodedString()
            }
            return ""
        default:
            return value ?? NSNull()
        }
    }

    private static func decodeValue(type: String, value: Any?) throws -> Any {
        switch type {
        case "m":
            guard let map = value as? [String: Any] else { return [:] }
            var decoded: [String: Any] = [:]
            for (key, nested) in map {
                guard let wire = nested as? [String: Any] else { continue }
                decoded[key] = try decode(wire)
            }
            return decoded
        case "l":
            guard let list = value as? [Any] else { return [] }
            return try list.map { item -> Any in
                guard let wire = item as? [String: Any] else { return item }
                return try decode(wire)
            }
        case "bin":
            if let string = value as? String, let data = Data(base64Encoded: string) {
                return FlutterStandardTypedData(bytes: data)
            }
            return FlutterStandardTypedData(bytes: Data())
        default:
            return value ?? NSNull()
        }
    }
}

enum FlowWidgetCodecError: Error, LocalizedError {
    case missingType
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .missingType:
            return "Missing wire type discriminator"
        case .invalidPayload:
            return "Invalid wire payload"
        }
    }
}
