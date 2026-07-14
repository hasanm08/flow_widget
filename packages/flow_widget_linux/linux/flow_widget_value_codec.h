#ifndef FLOW_WIDGET_WINDOWS_FLOW_WIDGET_VALUE_CODEC_H_
#define FLOW_WIDGET_WINDOWS_FLOW_WIDGET_VALUE_CODEC_H_

#include <flutter/encodable_value.h>
#include <optional>
#include <string>
#include <vector>

namespace flow_widget_linux {

/// Encodes and decodes flow_widget wire values `{t, v}`.
class FlowWidgetValueCodec {
 public:
  static flutter::EncodableValue Encode(const flutter::EncodableValue& value);
  static std::optional<flutter::EncodableValue> Decode(
      const flutter::EncodableValue& wire);
  static flutter::EncodableMap EncodeMap(const flutter::EncodableMap& map);
  static flutter::EncodableMap DecodeMap(const flutter::EncodableMap& wire);
};

}  // namespace flow_widget_linux

#endif  // FLOW_WIDGET_WINDOWS_FLOW_WIDGET_VALUE_CODEC_H_
