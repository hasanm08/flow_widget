# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-14

Initial pub.dev release of the federated `flow_widget` packages.

### Added

- Federated plugin architecture with dedicated platform packages
- Typed Dart API: `initialize`, `saveData`, `save` / `saveBatch`, `update`, `updateAll`, `onClicked`
- Compact `{t,v}` wire codec for `FlowWidgetValue` (string, int, double, bool, DateTime, JSON, bytes, map, list)
- Android App Widgets + Glance support, pin widget, shared preferences storage, image store
- iOS WidgetKit timelines, App Groups, Live Activities / Dynamic Island bridge
- macOS WidgetKit integration
- Windows and Linux storage bridges with documented OS limitations
- Wear OS Tiles companion package
- watchOS Complications Swift helpers + Dart bridge
- `flow_widget_cli` (`create`, `configure`, `generate`, `doctor`, `preview`, `clean`, `validate`)
- `@FlowWidgetModel` annotations + `flow_widget_generator` for `build_runner`
- Example app covering weather, habits, calendar, fitness, music, finance, news, photo, countdown, checklist, Live Activities
- Strict analysis options, unit tests, and GitHub Actions CI
