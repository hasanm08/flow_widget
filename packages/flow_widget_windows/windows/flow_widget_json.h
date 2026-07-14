#ifndef FLOW_WIDGET_WINDOWS_FLOW_WIDGET_JSON_H_
#define FLOW_WIDGET_WINDOWS_FLOW_WIDGET_JSON_H_

#include <flutter/encodable_value.h>
#include <optional>
#include <string>

namespace flow_widget_windows {

/// Minimal JSON read/write utilities for flow_widget storage files.
class FlowWidgetJson {
 public:
  static std::string Stringify(const flutter::EncodableValue& value);
  static std::optional<flutter::EncodableValue> Parse(const std::string& json);
};

}  // namespace flow_widget_windows

#endif  // FLOW_WIDGET_WINDOWS_FLOW_WIDGET_JSON_H_
