#include "flow_widget_json.h"

#include <cctype>
#include <limits>
#include <sstream>

namespace flow_widget_windows {
namespace {

class JsonParser {
 public:
  explicit JsonParser(std::string input) : input_(std::move(input)), pos_(0) {}

  std::optional<flutter::EncodableValue> ParseValue() {
    SkipWhitespace();
    if (pos_ >= input_.size()) {
      return std::nullopt;
    }
    const char ch = input_[pos_];
    if (ch == '"') {
      return ParseString();
    }
    if (ch == '{') {
      return ParseObject();
    }
    if (ch == '[') {
      return ParseArray();
    }
    if (ch == 't' || ch == 'f') {
      return ParseBool();
    }
    if (ch == 'n') {
      return ParseNull();
    }
    if (ch == '-' || std::isdigit(static_cast<unsigned char>(ch))) {
      return ParseNumber();
    }
    return std::nullopt;
  }

 private:
  void SkipWhitespace() {
    while (pos_ < input_.size() &&
           std::isspace(static_cast<unsigned char>(input_[pos_]))) {
      ++pos_;
    }
  }

  bool Consume(char expected) {
    SkipWhitespace();
    if (pos_ < input_.size() && input_[pos_] == expected) {
      ++pos_;
      return true;
    }
    return false;
  }

  std::optional<flutter::EncodableValue> ParseString() {
    if (!Consume('"')) {
      return std::nullopt;
    }
    std::ostringstream out;
    while (pos_ < input_.size()) {
      const char ch = input_[pos_++];
      if (ch == '"') {
        return flutter::EncodableValue(out.str());
      }
      if (ch == '\\' && pos_ < input_.size()) {
        const char escaped = input_[pos_++];
        switch (escaped) {
          case '"':
            out << '"';
            break;
          case '\\':
            out << '\\';
            break;
          case 'n':
            out << '\n';
            break;
          case 'r':
            out << '\r';
            break;
          case 't':
            out << '\t';
            break;
          default:
            out << escaped;
            break;
        }
      } else {
        out << ch;
      }
    }
    return std::nullopt;
  }

  std::optional<flutter::EncodableValue> ParseNumber() {
    const size_t start = pos_;
    if (input_[pos_] == '-') {
      ++pos_;
    }
    while (pos_ < input_.size() &&
           std::isdigit(static_cast<unsigned char>(input_[pos_]))) {
      ++pos_;
    }
    if (pos_ < input_.size() && input_[pos_] == '.') {
      ++pos_;
      while (pos_ < input_.size() &&
             std::isdigit(static_cast<unsigned char>(input_[pos_]))) {
        ++pos_;
      }
      const double value = std::stod(input_.substr(start, pos_ - start));
      return flutter::EncodableValue(value);
    }
    const int64_t value = std::stoll(input_.substr(start, pos_ - start));
    if (value >= std::numeric_limits<int32_t>::min() &&
        value <= std::numeric_limits<int32_t>::max()) {
      return flutter::EncodableValue(static_cast<int32_t>(value));
    }
    return flutter::EncodableValue(value);
  }

  std::optional<flutter::EncodableValue> ParseBool() {
    if (input_.compare(pos_, 4, "true") == 0) {
      pos_ += 4;
      return flutter::EncodableValue(true);
    }
    if (input_.compare(pos_, 5, "false") == 0) {
      pos_ += 5;
      return flutter::EncodableValue(false);
    }
    return std::nullopt;
  }

  std::optional<flutter::EncodableValue> ParseNull() {
    if (input_.compare(pos_, 4, "null") == 0) {
      pos_ += 4;
      return flutter::EncodableValue();
    }
    return std::nullopt;
  }

  std::optional<flutter::EncodableValue> ParseArray() {
    if (!Consume('[')) {
      return std::nullopt;
    }
    flutter::EncodableList list;
    SkipWhitespace();
    if (Consume(']')) {
      return flutter::EncodableValue(list);
    }
    while (pos_ < input_.size()) {
      auto value = ParseValue();
      if (!value.has_value()) {
        return std::nullopt;
      }
      if (const auto* bytes = std::get_if<std::vector<uint8_t>>(&value.value())) {
        list.push_back(flutter::EncodableValue(*bytes));
      } else {
        list.push_back(value.value());
      }
      SkipWhitespace();
      if (Consume(']')) {
        return flutter::EncodableValue(list);
      }
      if (!Consume(',')) {
        return std::nullopt;
      }
    }
    return std::nullopt;
  }

  std::optional<flutter::EncodableValue> ParseObject() {
    if (!Consume('{')) {
      return std::nullopt;
    }
    flutter::EncodableMap map;
    SkipWhitespace();
    if (Consume('}')) {
      return flutter::EncodableValue(map);
    }
    while (pos_ < input_.size()) {
      auto key_value = ParseString();
      if (!key_value.has_value()) {
        return std::nullopt;
      }
      const auto* key = std::get_if<std::string>(&key_value.value());
      if (key == nullptr || !Consume(':')) {
        return std::nullopt;
      }
      auto value = ParseValue();
      if (!value.has_value()) {
        return std::nullopt;
      }
      map[flutter::EncodableValue(*key)] = value.value();
      SkipWhitespace();
      if (Consume('}')) {
        return flutter::EncodableValue(map);
      }
      if (!Consume(',')) {
        return std::nullopt;
      }
    }
    return std::nullopt;
  }

  std::string input_;
  size_t pos_;
};

std::string EscapeJson(const std::string& input) {
  std::ostringstream out;
  for (char ch : input) {
    switch (ch) {
      case '"':
        out << "\\\"";
        break;
      case '\\':
        out << "\\\\";
        break;
      case '\n':
        out << "\\n";
        break;
      case '\r':
        out << "\\r";
        break;
      case '\t':
        out << "\\t";
        break;
      default:
        out << ch;
        break;
    }
  }
  return out.str();
}

std::string StringifyValue(const flutter::EncodableValue& value) {
  if (const auto* str = std::get_if<std::string>(&value)) {
    return "\"" + EscapeJson(*str) + "\"";
  }
  if (const auto* integer = std::get_if<int32_t>(&value)) {
    return std::to_string(*integer);
  }
  if (const auto* int64 = std::get_if<int64_t>(&value)) {
    return std::to_string(*int64);
  }
  if (const auto* dbl = std::get_if<double>(&value)) {
    return std::to_string(*dbl);
  }
  if (const auto* boolean = std::get_if<bool>(&value)) {
    return *boolean ? "true" : "false";
  }
  if (value == flutter::EncodableValue()) {
    return "null";
  }
  if (const auto* bytes = std::get_if<std::vector<uint8_t>>(&value)) {
    std::ostringstream out;
    out << "[";
    bool first = true;
    for (uint8_t byte : *bytes) {
      if (!first) {
        out << ",";
      }
      first = false;
      out << static_cast<int>(byte);
    }
    out << "]";
    return out.str();
  }
  if (const auto* map = std::get_if<flutter::EncodableMap>(&value)) {
    std::ostringstream out;
    out << "{";
    bool first = true;
    for (const auto& entry : *map) {
      const auto* key = std::get_if<std::string>(&entry.first);
      if (key == nullptr) {
        continue;
      }
      if (!first) {
        out << ",";
      }
      first = false;
      out << "\"" << EscapeJson(*key) << "\":" << StringifyValue(entry.second);
    }
    out << "}";
    return out.str();
  }
  if (const auto* list = std::get_if<flutter::EncodableList>(&value)) {
    std::ostringstream out;
    out << "[";
    bool first = true;
    for (const auto& item : *list) {
      if (!first) {
        out << ",";
      }
      first = false;
      out << StringifyValue(item);
    }
    out << "]";
    return out.str();
  }
  return "null";
}

flutter::EncodableList NormalizeByteArrays(const flutter::EncodableList& list) {
  flutter::EncodableList normalized;
  bool all_ints = !list.empty();
  for (const auto& item : list) {
    if (!std::holds_alternative<int32_t>(item) && !std::holds_alternative<int64_t>(item)) {
      all_ints = false;
      break;
    }
  }
  if (all_ints) {
    std::vector<uint8_t> bytes;
    bytes.reserve(list.size());
    for (const auto& item : list) {
      if (const auto* integer = std::get_if<int32_t>(&item)) {
        bytes.push_back(static_cast<uint8_t>(*integer));
      } else if (const auto* int64 = std::get_if<int64_t>(&item)) {
        bytes.push_back(static_cast<uint8_t>(*int64));
      }
    }
    normalized.push_back(flutter::EncodableValue(bytes));
    return normalized;
  }
  return list;
}

}  // namespace

std::string FlowWidgetJson::Stringify(const flutter::EncodableValue& value) {
  return StringifyValue(value);
}

std::optional<flutter::EncodableValue> FlowWidgetJson::Parse(
    const std::string& json) {
  JsonParser parser(json);
  return parser.ParseValue();
}

}  // namespace flow_widget_windows
