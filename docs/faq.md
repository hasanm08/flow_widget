# FAQ

**Does flow_widget render Flutter widgets on the home screen?**  
No. OS widgets are native (RemoteViews / Glance / SwiftUI). Flutter writes data and triggers reloads; native UI reads shared storage.

**Can I use it with Flutter flavors?**  
Yes. Point `androidProviderFullyQualifiedName` / App Group ids per flavor.

**Why does tapping my Android Glance widget open `/CALLBACK` (“Page not found”)?**  
That path is **not** from `flow_widget`. AndroidX Glance injects a unique
`/CALLBACK?…` URI onto `actionStartActivity` Intents that have no `data`.
Flutter deep linking then treats it as a route. Use
`FlowWidgetLaunch.activityIntent(...)` (sets a real URI) and extend
`FlowWidgetFlutterActivity` so leftover CALLBACK URIs are rewritten. See
[Platform setup](platform_setup.md#glance-clicks-and-flutter-deep-linking-callback).

**Is Windows Widgets supported?**  
Only through documented storage/update hooks unless Microsoft exposes a stable public API your app can legally use. See `flow_widget_windows` README.

**How do I test without a device?**  
Use the fake `FlowWidgetPlatform` pattern from unit tests, plus `flow_widget_cli doctor` for project wiring.
