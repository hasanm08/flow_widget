# flow_widget_android

Android federated implementation for [flow_widget](https://github.com/hasanm08/flow_widget).

## Features

- SharedPreferences-backed typed storage with the flow_widget wire codec
- AppWidget / Glance refresh via registered provider class names
- Image persistence under `filesDir/flow_widget_images/`
- Pin-widget requests via `AppWidgetManager.requestPinAppWidget` (API 26+)
- Live Activities are not supported on Android (methods return `unsupported`)

## Usage

Add `flow_widget` to your app; this package is pulled in automatically as the
default Android implementation.

Register widget providers in your host app manifest and call
`FlowWidget.registerConfig` with `androidProviderFullyQualifiedName` so the
plugin can refresh instances.

## Channel contract

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`
