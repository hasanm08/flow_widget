// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "flow_widget_ios",
  platforms: [
    .iOS("14.0")
  ],
  products: [
    .library(name: "flow-widget-ios", targets: ["flow_widget_ios"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "flow_widget_ios",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
