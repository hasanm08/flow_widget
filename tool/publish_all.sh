#!/usr/bin/env bash
# Publish all flow_widget packages to pub.dev in dependency order.
# Requires: dart pub login (and a network that can reach pub.dev uploads).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

publish() {
  echo ""
  echo "========== Publishing $1 =========="
  (cd "packages/$1" && dart pub publish --force)
}

publish flow_widget_annotation
publish flow_widget_platform_interface

publish flow_widget_android
publish flow_widget_ios
publish flow_widget_macos
publish flow_widget_windows
publish flow_widget_linux
publish flow_widget_wear
publish flow_widget_watchos

publish flow_widget_generator
publish flow_widget_cli

publish flow_widget

echo ""
echo "All packages published."
echo "Main package: https://pub.dev/packages/flow_widget"
