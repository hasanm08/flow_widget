/// iOS WidgetKit templates.
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

String iosWidgetKitFiles({
  required String widgetName,
  required String appGroupId,
  required String bundleIdentifier,
}) {
  return iosWidgetBundle(
    widgetName: widgetName,
    bundleIdentifier: bundleIdentifier,
  );
}

String iosWidgetBundle({
  required String widgetName,
  required String bundleIdentifier,
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
''';
}

String iosWidget({required String widgetName, required String appGroupId}) {
  return '''
import WidgetKit
import SwiftUI

struct ${widgetName}: Widget {
    let kind: String = "${widgetName}Kind"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ${widgetName}Provider()) { entry in
            ${widgetName}EntryView(entry: entry)
        }
        .configurationDisplayName("$widgetName")
        .description("Powered by flow_widget")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
''';
}

String iosWidgetProvider({
  required String widgetName,
  required String appGroupId,
}) {
  return '''
import WidgetKit

struct ${widgetName}Provider: TimelineProvider {
    func placeholder(in context: Context) -> ${widgetName}Entry {
        ${widgetName}Entry(date: Date(), title: "$widgetName", subtitle: "Placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (${widgetName}Entry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<${widgetName}Entry>) -> Void) {
        let entry = readEntry()
        completion(Timeline(entries: [entry], policy: .atEnd))
    }

    private func readEntry() -> ${widgetName}Entry {
        let storage = UserDefaults(suiteName: "$appGroupId")
        let title = storage?.string(forKey: "${_toSnakeCase(widgetName)}_title") ?? "$widgetName"
        let subtitle = storage?.string(forKey: "${_toSnakeCase(widgetName)}_body") ?? "Updated from Flutter"
        return ${widgetName}Entry(date: Date(), title: title, subtitle: subtitle)
    }
}
''';
}

String iosWidgetEntry({required String widgetName}) {
  return '''
import WidgetKit

struct ${widgetName}Entry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
}
''';
}

String iosWidgetEntryView({required String widgetName}) {
  return '''
import SwiftUI
import WidgetKit

struct ${widgetName}EntryView: View {
    var entry: ${widgetName}Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title).font(.headline)
            Text(entry.subtitle).font(.caption)
        }
        .padding()
    }
}
''';
}

String iosAppGroupInstructions({
  required String appGroupId,
  required String bundleIdentifier,
  required String widgetName,
}) {
  return '''
# iOS App Group setup for flow_widget

1. Open ios/Runner.xcworkspace in Xcode.
2. Select the Runner target → Signing & Capabilities → + Capability → App Groups.
3. Add group: $appGroupId
4. Repeat for the ${bundleIdentifier}.${widgetName}WidgetExtension target after creating it.
5. Ensure both targets share the same App Group.

Widget extension bundle id suggestion:
  ${bundleIdentifier}.${widgetName}WidgetExtension
''';
}

String iosEntitlementsSnippet({required String appGroupId}) {
  return '''
<key>com.apple.security.application-groups</key>
<array>
    <string>$appGroupId</string>
</array>
''';
}
