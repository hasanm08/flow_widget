import Foundation

/// Persists widget image bytes inside the App Group container.
final class FlowWidgetImageStore {
  private let directory: URL

  init(appGroupId: String?) {
    if let appGroupId,
       let container = FileManager.default.containerURL(
         forSecurityApplicationGroupIdentifier: appGroupId
       ) {
      directory = container.appendingPathComponent("flow_widget_images", isDirectory: true)
    } else {
      let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
      directory = base.appendingPathComponent("flow_widget_images", isDirectory: true)
    }
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  }

  func save(key: String, bytes: Data, mimeType: String) throws -> String {
    let ext = fileExtension(for: mimeType)
    let fileURL = directory.appendingPathComponent("\(key).\(ext)")
    try bytes.write(to: fileURL, options: .atomic)
    return fileURL.path
  }

  func remove(key: String) {
    guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
      return
    }
    for file in files where file.deletingPathExtension().lastPathComponent == key {
      try? FileManager.default.removeItem(at: file)
    }
  }

  private func fileExtension(for mimeType: String) -> String {
    switch mimeType.lowercased() {
    case "image/jpeg", "image/jpg":
      return "jpg"
    case "image/webp":
      return "webp"
    case "image/gif":
      return "gif"
    default:
      return "png"
    }
  }
}
