#include "flow_widget_value_codec.h"

#include <variant>

namespace flow_widget_windows {

namespace {

bool IsWireMap(const flutter::EncodableValue& value) {
  const auto* map = std::get_if<flutter::EncodableMap>(&value);
  return map != nullptr && map->count(flutter::EncodableValue("t")) > 0;
}

}  // namespace

flutter::EncodableValue FlowWidgetValueCodec::Encode(
    const flutter::EncodableValue& value) {
  if (IsWireMap(value)) {
    return value;
  }
  if (const auto* str = std::get_if<std::string>(&value)) {
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("s")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(*str)},
    });
  }
  if (const auto* integer = std::get_if<int32_t>(&value)) {
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("i")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(*integer)},
    });
  }
  if (const auto* int64 = std::get_if<int64_t>(&value)) {
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("i")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(*int64)},
    });
  }
  if (const auto* dbl = std::get_if<double>(&value)) {
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("d")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(*dbl)},
    });
  }
  if (const auto* boolean = std::get_if<bool>(&value)) {
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("b")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(*boolean)},
    });
  }
  if (const auto* bytes = std::get_if<std::vector<uint8_t>>(&value)) {
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("bin")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(*bytes)},
    });
  }
  if (const auto* map = std::get_if<flutter::EncodableMap>(&value)) {
    flutter::EncodableMap encoded;
    for (const auto& entry : *map) {
      const auto* key = std::get_if<std::string>(&entry.first);
      if (key != nullptr) {
        encoded[flutter::EncodableValue(*key)] = Encode(entry.second);
      }
    }
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("m")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(encoded)},
    });
  }
  if (const auto* list = std::get_if<flutter::EncodableList>(&value)) {
    flutter::EncodableList encoded;
    for (const auto& item : *list) {
      encoded.push_back(Encode(item));
    }
    return flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("t"), flutter::EncodableValue("l")},
        {flutter::EncodableValue("v"), flutter::EncodableValue(encoded)},
    });
  }
  return flutter::EncodableValue(flutter::EncodableMap{
      {flutter::EncodableValue("t"), flutter::EncodableValue("s")},
      {flutter::EncodableValue("v"), flutter::EncodableValue("")},
  });
}

std::optional<flutter::EncodableValue> FlowWidgetValueCodec::Decode(
    const flutter::EncodableValue& wire) {
  const auto* map = std::get_if<flutter::EncodableMap>(&wire);
  if (map == nullptr) {
    return std::nullopt;
  }
  auto type_it = map->find(flutter::EncodableValue("t"));
  auto value_it = map->find(flutter::EncodableValue("v"));
  if (type_it == map->end() || value_it == map->end()) {
    return std::nullopt;
  }
  const auto* type = std::get_if<std::string>(&type_it->second);
  if (type == nullptr) {
    return std::nullopt;
  }
  const auto& encoded = value_it->second;
  if (*type == "s" || *type == "j") {
    if (const auto* str = std::get_if<std::string>(&encoded)) {
      return flutter::EncodableValue(*str);
    }
  } else if (*type == "i") {
    if (const auto* integer = std::get_if<int32_t>(&encoded)) {
      return flutter::EncodableValue(*integer);
    }
    if (const auto* int64 = std::get_if<int64_t>(&encoded)) {
      return flutter::EncodableValue(*int64);
    }
  } else if (*type == "d") {
    if (const auto* dbl = std::get_if<double>(&encoded)) {
      return flutter::EncodableValue(*dbl);
    }
  } else if (*type == "b") {
    if (const auto* boolean = std::get_if<bool>(&encoded)) {
      return flutter::EncodableValue(*boolean);
    }
  } else if (*type == "bin") {
    if (const auto* bytes = std::get_if<std::vector<uint8_t>>(&encoded)) {
      return flutter::EncodableValue(*bytes);
    }
  } else if (*type == "m") {
    if (const auto* nested = std::get_if<flutter::EncodableMap>(&encoded)) {
      return flutter::EncodableValue(DecodeMap(*nested));
    }
  } else if (*type == "l") {
    if (const auto* list = std::get_if<flutter::EncodableList>(&encoded)) {
      flutter::EncodableList decoded;
      for (const auto& item : *list) {
        auto value = Decode(item);
        if (value.has_value()) {
          decoded.push_back(value.value());
        }
      }
      return flutter::EncodableValue(decoded);
    }
  }
  return std::nullopt;
}

flutter::EncodableMap FlowWidgetValueCodec::EncodeMap(
    const flutter::EncodableMap& map) {
  flutter::EncodableMap result;
  for (const auto& entry : map) {
    const auto* key = std::get_if<std::string>(&entry.first);
    if (key != nullptr) {
      result[flutter::EncodableValue(*key)] = Encode(entry.second);
    }
  }
  return result;
}

flutter::EncodableMap FlowWidgetValueCodec::DecodeMap(
    const flutter::EncodableMap& wire) {
  flutter::EncodableMap result;
  for (const auto& entry : wire) {
    const auto* key = std::get_if<std::string>(&entry.first);
    if (key != nullptr) {
      auto decoded = Decode(entry.second);
      if (decoded.has_value()) {
        result[flutter::EncodableValue(*key)] = decoded.value();
      }
    }
  }
  return result;
}

}  // namespace flow_widget_windows
