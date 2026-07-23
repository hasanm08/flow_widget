# Best practices

1. **Initialize early** — before `runApp`, after `WidgetsFlutterBinding.ensureInitialized()`.
2. **Register configs** — call `registerConfig` for each family so native updaters know provider / kind names.
3. **Namespace keys** — use prefixes (`weather_`, `user_`) or `@FlowWidgetModel(prefix: ...)`.
4. **Handle clicks once** — subscribe to `FlowWidget.onClicked` at the app root.
5. **Check capabilities** — gate Live Activities / pin / tiles with `getCapabilities()`.
6. **Treat widgets as eventually consistent** — OS refresh budgets vary; design UI for stale states.
7. **Document App Groups** — iOS/macOS widgets cannot see standard `UserDefaults`.
8. **Match Android prefs names** — `androidNamedSharedPreferences` (default
   `flutter_flow_widget`) must equal the name passed to
   `FlowWidgetStorage.create` in Kotlin. `appGroupId` is not used on Android.
9. **Glance clicks need a real Intent URI** — never rely on bare
   `actionStartActivity<MainActivity>(...)` without `Intent.data`; Glance
   injects `/CALLBACK` and Flutter deep linking will route to it. Use
   `FlowWidgetLaunch` + `FlowWidgetFlutterActivity`.
10. **Keep extension code thin** — native widgets read shared storage; business logic stays in Flutter / isolates.
