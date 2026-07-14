# Troubleshooting

## Widget does not update

- Confirm `FlowWidget.initialize` succeeded
- Verify `registerConfig` provider / kind matches the native target
- On iOS, ensure App Group entitlements match `appGroupId`
- On Android, confirm the receiver is exported and listed in the manifest

## `FlowWidgetNotInitializedException`

Call `initialize` before any other API.

## Live Activities fail

Requires iOS 16.1+, ActivityKit capability, and matching attributes in the extension. On other platforms expect `unsupported`.

## Images missing in widgets

Save via `FlowWidget.saveImage` into the App Group / shared files dir. Remote URLs need network permission in the extension.

## `doctor` reports failures

Run `dart run flow_widget_cli:flow_widget doctor --verbose` and fix the first red item (usually missing dependency or App Group).
