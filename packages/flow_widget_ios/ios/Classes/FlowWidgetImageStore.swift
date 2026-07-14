import Flutter
import Foundation

final class FlowWidgetImageStore {
    private let directory: URL
    private let maxCacheBytes: Int
    private let fileManager = FileManager.default

    init(containerURL: URL?, maxCacheBytes: Int) {
        let base = containerURL ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        directory = base.appendingPathComponent("flow_widget_images", isDirectory: true)
        self.maxCacheBytes = maxCacheBytes
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func saveImage(args: [String: Any]) throws -> String {
        guard let key = args["key"] as? String else {
            throw FlowWidgetImageError.missingKey
        }
        let mimeType = (args["mimeType"] as? String) ?? "image/png"
        let fileURL = directory.appendingPathComponent(sanitized(key: key) + extensionFor(mimeType: mimeType))

        if let bytes = args["bytes"] {
            let data = try dataFrom(bytes: bytes)
            try enforceCacheLimit(incoming: data.count)
            try data.write(to: fileURL, options: .atomic)
            return fileURL.path
        }

        guard let urlString = args["url"] as? String, let url = URL(string: urlString) else {
            throw FlowWidgetImageError.missingPayload
        }

        let semaphore = DispatchSemaphore(value: 0)
        var downloaded = Data()
        var requestError: Error?

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                requestError = error
            } else if let data {
                downloaded = data
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        if let requestError {
            throw requestError
        }

        try enforceCacheLimit(incoming: downloaded.count)
        try downloaded.write(to: fileURL, options: .atomic)
        return fileURL.path
    }

    func removeImage(key: String) {
        let prefix = sanitized(key: key)
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return
        }
        for file in files where file.lastPathComponent.hasPrefix(prefix) {
            try? fileManager.removeItem(at: file)
        }
    }

    func clear() {
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return
        }
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }

    private func enforceCacheLimit(incoming: Int) throws {
        guard let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        ) else { return }

        var total = incoming
        var descriptors: [(url: URL, size: Int, date: Date)] = []
        for file in files {
            let values = try file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            let size = values.fileSize ?? 0
            total += size
            descriptors.append((file, size, values.contentModificationDate ?? .distantPast))
        }

        guard total > maxCacheBytes else { return }

        for entry in descriptors.sorted(by: { $0.date < $1.date }) {
            if total <= maxCacheBytes { break }
            try? fileManager.removeItem(at: entry.url)
            total -= entry.size
        }
    }

    private func dataFrom(bytes: Any) throws -> Data {
        if let data = bytes as? Data {
            return data
        }
        if let typed = bytes as? FlutterStandardTypedData {
            return typed.data
        }
        if let array = bytes as? [Int] {
            return Data(array.map { UInt8(truncatingIfNeeded: $0) })
        }
        throw FlowWidgetImageError.invalidBytes
    }

    private func sanitized(key: String) -> String {
        key.replacingOccurrences(of: "[^a-zA-Z0-9._-]", with: "_", options: .regularExpression)
    }

    private func extensionFor(mimeType: String) -> String {
        switch mimeType.lowercased() {
        case "image/jpeg", "image/jpg":
            return ".jpg"
        case "image/webp":
            return ".webp"
        case "image/gif":
            return ".gif"
        default:
            return ".png"
        }
    }
}

enum FlowWidgetImageError: Error, LocalizedError {
    case missingKey
    case missingPayload
    case invalidBytes

    var errorDescription: String? {
        switch self {
        case .missingKey:
            return "saveImage requires key"
        case .missingPayload:
            return "saveImage requires bytes or url"
        case .invalidBytes:
            return "Invalid image byte payload"
        }
    }
}
