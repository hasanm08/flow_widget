/// macOS WidgetKit templates.
library;

String _toSnakeCase(String name) {
  final buffer = StringBuffer();
  for (var i = 0; i < name.length; i++) {
    final char = name[i];
    if (char == char.toUpperCase() && i > 0) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer.toString();
}

String macosWidgetKitFiles({
  required String widgetName,
  required String appGroupId,
}) {
  return '''
import WidgetKit
import SwiftUI

@main
struct ${widgetName}Bundle: WidgetBundle {
    var body: some Widget {
        ${widgetName}()
    }
}

struct ${widgetName}: Widget {
    let kind: String = "${widgetName}Kind"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ${widgetName}Provider()) { entry in
            ${widgetName}EntryView(entry: entry)
        }
        .configurationDisplayName("$widgetName")
        .description("Powered by flow_widget")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct ${widgetName}Provider: TimelineProvider {
    func placeholder(in context: Context) -> ${widgetName}Entry {
        ${widgetName}Entry(date: Date(), title: "$widgetName", subtitle: "Placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (${widgetName}Entry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<${widgetName}Entry>) -> Void) {
        completion(Timeline(entries: [readEntry()], policy: .atEnd))
    }

    private func readEntry() -> ${widgetName}Entry {
        let storage = UserDefaults(suiteName: "$appGroupId")
        let title = storage?.string(forKey: "${_toSnakeCase(widgetName)}_title") ?? "$widgetName"
        let subtitle = storage?.string(forKey: "${_toSnakeCase(widgetName)}_body") ?? "Updated from Flutter"
        return ${widgetName}Entry(date: Date(), title: title, subtitle: subtitle)
    }
}

struct ${widgetName}Entry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
}

struct ${widgetName}EntryView: View {
    var entry: ${widgetName}Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.title).font(.headline)
            Text(entry.subtitle).font(.caption)
        }
        .padding()
    }
}
''';
}

String macosAppGroupInstructions({required String appGroupId}) {
  return '''
# macOS App Group setup

1. Open macos/Runner.xcworkspace in Xcode.
2. Add App Groups capability to Runner and the widget extension.
3. Enable group: $appGroupId
4. Pass the same group id to FlowWidget.initialize(appGroupId: ...).
''';
}
