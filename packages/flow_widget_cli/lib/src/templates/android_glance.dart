/// Android Glance App Widget templates.
library;

import 'package:flow_widget_cli/src/validation/name_sanitizer.dart';

String androidGlanceProvider({
  required String applicationId,
  required String widgetName,
  required String packageName,
}) {
  final keyPrefix = widgetNameToSnakeCase(widgetName);

  return '''
package $packageName

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.text.Text
import dev.flowwidget.android.FlowWidgetStorage

class ${widgetName}Receiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = ${widgetName}Widget()
}

class ${widgetName}Widget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: androidx.glance.appwidget.GlanceId) {
        val storage = FlowWidgetStorage.create(context, "flow_widget")
        val title = readString(storage, "${keyPrefix}_title", "$widgetName")
        val body = readString(storage, "${keyPrefix}_body", "Updated from Flutter")

        provideContent {
            Text(text = "\$title\\n\$body")
        }
    }

    private fun readString(storage: FlowWidgetStorage, key: String, default: String): String {
        val wire = storage.getData(key) ?: return default
        return wire["v"] as? String ?: default
    }
}
''';
}

String androidWidgetInfoXml({
  required String widgetName,
  required String providerClass,
}) {
  final snake = widgetNameToSnakeCase(widgetName);
  return '''
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="110dp"
    android:minHeight="40dp"
    android:updatePeriodMillis="0"
    android:initialLayout="@layout/${snake}_widget_placeholder"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:description="@string/${snake}_widget_description" />
''';
}

String androidWidgetPlaceholderLayout({required String widgetName}) {
  final snake = widgetNameToSnakeCase(widgetName);
  return '''
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:padding="8dp">

    <TextView
        android:id="@+id/${snake}_placeholder"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:gravity="center"
        android:text="@string/${snake}_widget_description" />
</FrameLayout>
''';
}

String androidManifestSnippet({
  required String widgetName,
  required String providerClass,
}) {
  final snake = widgetNameToSnakeCase(widgetName);
  return '''
<!-- Add inside <application> for $widgetName -->
<receiver
    android:name="$providerClass"
    android:exported="true"
    android:label="$widgetName">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/${snake}_widget_info" />
</receiver>
''';
}

String androidStringsSnippet({required String widgetName}) {
  final snake = widgetNameToSnakeCase(widgetName);
  return '''
<string name="${snake}_widget_description">$widgetName home screen widget</string>
''';
}

String androidGradleDependencies() {
  return '''
// Add to android/app/build.gradle dependencies block:
implementation "androidx.glance:glance-appwidget:1.1.1"
''';
}
