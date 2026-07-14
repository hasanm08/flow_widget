#ifndef FLOW_WIDGET_LINUX_FLOW_WIDGET_STORAGE_H_
#define FLOW_WIDGET_LINUX_FLOW_WIDGET_STORAGE_H_

#include <flutter/encodable_value.h>
#include <filesystem>
#include <optional>
#include <string>

namespace flow_widget_linux {

/// JSON file backed typed storage in $XDG_CONFIG_HOME/flow_widget/.
class FlowWidgetStorage {
 public:
  explicit FlowWidgetStorage(const std::filesystem::path& root_directory);

  bool Load();
  bool Save();

  void SaveData(const std::string& key, const flutter::EncodableMap& wire);
  void SaveBatch(const flutter::EncodableList& entries);
  std::optional<flutter::EncodableMap> GetData(const std::string& key);
  flutter::EncodableMap GetAllData(const std::optional<std::string>& prefix);
  void RemoveData(const std::string& key);
  void ClearData();

  void RegisterConfig(const flutter::EncodableMap& config);
  void SetTimeline(const std::string& name,
                     const std::optional<int64_t>& id,
                     const flutter::EncodableList& entries);
  void SetLastUpdate(int64_t millis);

  std::filesystem::path ImageDirectory() const;
  std::filesystem::path StorageFile() const;

 private:
  std::filesystem::path root_directory_;
  flutter::EncodableMap document_;
};

}  // namespace flow_widget_linux

#endif  // FLOW_WIDGET_LINUX_FLOW_WIDGET_STORAGE_H_
