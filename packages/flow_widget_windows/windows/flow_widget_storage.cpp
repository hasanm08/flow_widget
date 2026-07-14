#include "flow_widget_storage.h"

#include "flow_widget_json.h"

#include <fstream>
#include <sstream>

namespace flow_widget_windows {
namespace {

flutter::EncodableMap& MutableSection(flutter::EncodableMap& document,
                                        const char* key) {
  auto it = document.find(flutter::EncodableValue(key));
  if (it == document.end() || !std::holds_alternative<flutter::EncodableMap>(it->second)) {
    document[flutter::EncodableValue(key)] = flutter::EncodableValue(flutter::EncodableMap{});
    it = document.find(flutter::EncodableValue(key));
  }
  return std::get<flutter::EncodableMap>(it->second);
}

const flutter::EncodableMap& ConstSection(const flutter::EncodableMap& document,
                                           const char* key) {
  static const flutter::EncodableMap kEmpty;
  auto it = document.find(flutter::EncodableValue(key));
  if (it == document.end() || !std::holds_alternative<flutter::EncodableMap>(it->second)) {
    return kEmpty;
  }
  return std::get<flutter::EncodableMap>(it->second);
}

}  // namespace

FlowWidgetStorage::FlowWidgetStorage(const std::filesystem::path& root_directory)
    : root_directory_(root_directory) {
  std::filesystem::create_directories(root_directory_);
  std::filesystem::create_directories(ImageDirectory());
  document_ = flutter::EncodableMap{
      {flutter::EncodableValue("data"), flutter::EncodableValue(flutter::EncodableMap{})},
      {flutter::EncodableValue("configs"), flutter::EncodableValue(flutter::EncodableMap{})},
      {flutter::EncodableValue("timelines"), flutter::EncodableValue(flutter::EncodableMap{})},
      {flutter::EncodableValue("last_update"), flutter::EncodableValue(int64_t{0})},
  };
}

bool FlowWidgetStorage::Load() {
  const auto file = StorageFile();
  if (!std::filesystem::exists(file)) {
    return Save();
  }
  std::ifstream input(file);
  if (!input.is_open()) {
    return false;
  }
  std::ostringstream buffer;
  buffer << input.rdbuf();
  const std::string content = buffer.str();
  if (content.empty()) {
    return true;
  }
  auto parsed = FlowWidgetJson::Parse(content);
  if (!parsed.has_value()) {
    return false;
  }
  const auto* map = std::get_if<flutter::EncodableMap>(&parsed.value());
  if (map == nullptr) {
    return false;
  }
  document_ = *map;
  return true;
}

bool FlowWidgetStorage::Save() {
  std::ofstream output(StorageFile(), std::ios::trunc);
  if (!output.is_open()) {
    return false;
  }
  output << FlowWidgetJson::Stringify(flutter::EncodableValue(document_));
  return true;
}

void FlowWidgetStorage::SaveData(const std::string& key,
                                 const flutter::EncodableMap& wire) {
  auto& data = MutableSection(document_, "data");
  data[flutter::EncodableValue(key)] = flutter::EncodableValue(wire);
  Save();
}

void FlowWidgetStorage::SaveBatch(const flutter::EncodableList& entries) {
  for (const auto& entry_value : entries) {
    const auto* entry = std::get_if<flutter::EncodableMap>(&entry_value);
    if (entry == nullptr) {
      continue;
    }
    auto key_it = entry->find(flutter::EncodableValue("key"));
    auto value_it = entry->find(flutter::EncodableValue("value"));
    if (key_it == entry->end() || value_it == entry->end()) {
      continue;
    }
    const auto* key = std::get_if<std::string>(&key_it->second);
    const auto* wire = std::get_if<flutter::EncodableMap>(&value_it->second);
    if (key != nullptr && wire != nullptr) {
      SaveData(*key, *wire);
    }
  }
}

std::optional<flutter::EncodableMap> FlowWidgetStorage::GetData(
    const std::string& key) {
  const auto& data = ConstSection(document_, "data");
  auto it = data.find(flutter::EncodableValue(key));
  if (it == data.end()) {
    return std::nullopt;
  }
  const auto* wire = std::get_if<flutter::EncodableMap>(&it->second);
  if (wire == nullptr) {
    return std::nullopt;
  }
  return *wire;
}

flutter::EncodableMap FlowWidgetStorage::GetAllData(
    const std::optional<std::string>& prefix) {
  const auto& data = ConstSection(document_, "data");
  flutter::EncodableMap result;
  for (const auto& entry : data) {
    const auto* key = std::get_if<std::string>(&entry.first);
    if (key == nullptr) {
      continue;
    }
    if (prefix.has_value() && key->rfind(prefix.value(), 0) != 0) {
      continue;
    }
    result[entry.first] = entry.second;
  }
  return result;
}

void FlowWidgetStorage::RemoveData(const std::string& key) {
  auto& data = MutableSection(document_, "data");
  data.erase(flutter::EncodableValue(key));
  Save();
}

void FlowWidgetStorage::ClearData() {
  document_[flutter::EncodableValue("data")] =
      flutter::EncodableValue(flutter::EncodableMap{});
  Save();
}

void FlowWidgetStorage::RegisterConfig(const flutter::EncodableMap& config) {
  auto& configs = MutableSection(document_, "configs");
  auto name_it = config.find(flutter::EncodableValue("name"));
  const auto* name = std::get_if<std::string>(&name_it->second);
  if (name != nullptr) {
    configs[flutter::EncodableValue(*name)] = flutter::EncodableValue(config);
    Save();
  }
}

void FlowWidgetStorage::SetTimeline(const std::string& name,
                                      const std::optional<int64_t>& id,
                                      const flutter::EncodableList& entries) {
  auto& timelines = MutableSection(document_, "timelines");
  std::string key = name;
  if (id.has_value()) {
    key += "#" + std::to_string(id.value());
  }
  timelines[flutter::EncodableValue(key)] = flutter::EncodableValue(entries);
  Save();
}

void FlowWidgetStorage::SetLastUpdate(int64_t millis) {
  document_[flutter::EncodableValue("last_update")] = flutter::EncodableValue(millis);
  Save();
}

std::filesystem::path FlowWidgetStorage::ImageDirectory() const {
  return root_directory_ / "images";
}

std::filesystem::path FlowWidgetStorage::StorageFile() const {
  return root_directory_ / "storage.json";
}

}  // namespace flow_widget_windows
