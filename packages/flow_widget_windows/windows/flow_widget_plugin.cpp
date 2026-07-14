#include "flow_widget_plugin.h"

#include <windows.h>

#include <chrono>
#include <fstream>

namespace flow_widget_windows {
namespace {

constexpr char kChannelName[] = "dev.flow_widget/methods";
constexpr char kEventChannelName[] = "dev.flow_widget/events";

flutter::EncodableMap Capabilities() {
  return flutter::EncodableMap{
      {flutter::EncodableValue("homeWidgets"), flutter::EncodableValue(false)},
      {flutter::EncodableValue("backgroundUpdates"), flutter::EncodableValue(true)},
      {flutter::EncodableValue("multipleInstances"), flutter::EncodableValue(false)},
      {flutter::EncodableValue("liveActivities"), flutter::EncodableValue(false)},
      {flutter::EncodableValue("wearTiles"), flutter::EncodableValue(false)},
      {flutter::EncodableValue("complications"), flutter::EncodableValue(false)},
      {flutter::EncodableValue("appGroups"), flutter::EncodableValue(false)},
  };
}

int64_t CurrentMillis() {
  return std::chrono::duration_cast<std::chrono::milliseconds>(
             std::chrono::system_clock::now().time_since_epoch())
      .count();
}

std::filesystem::path AppDataDirectory() {
  wchar_t* app_data = nullptr;
  size_t length = 0;
  _wdupenv_s(&app_data, &length, L"APPDATA");
  std::filesystem::path root;
  if (app_data != nullptr) {
    root = std::filesystem::path(app_data) / "flow_widget";
    free(app_data);
  } else {
    root = std::filesystem::temp_directory_path() / "flow_widget";
  }
  return root;
}

const flutter::EncodableMap* ArgsMap(const flutter::MethodCall<flutter::EncodableValue>& call) {
  return std::get_if<flutter::EncodableMap>(call.arguments());
}

std::string ReadString(const flutter::EncodableMap& map, const char* key) {
  auto it = map.find(flutter::EncodableValue(key));
  if (it == map.end()) {
    return {};
  }
  const auto* value = std::get_if<std::string>(&it->second);
  return value != nullptr ? *value : std::string{};
}

}  // namespace

void FlowWidgetPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<FlowWidgetPlugin>();
  plugin->channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), kChannelName,
      &flutter::StandardMethodCodec::GetInstance());
  plugin->channel_->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  plugin->event_channel_ = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
      registrar->messenger(), kEventChannelName,
      &flutter::StandardMethodCodec::GetInstance());
  auto event_handler = std::make_unique<flutter::StreamHandlerFunctions<>>(
      [](const flutter::EncodableValue* arguments,
         std::unique_ptr<flutter::EventSink<>>&& events)
          -> std::unique_ptr<flutter::StreamHandlerError<>> { return nullptr; },
      [](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<flutter::StreamHandlerError<>> { return nullptr; });
  plugin->event_channel_->SetStreamHandler(std::move(event_handler));

  registrar->AddPlugin(std::move(plugin));
}

FlowWidgetPlugin::FlowWidgetPlugin() = default;

FlowWidgetPlugin::~FlowWidgetPlugin() = default;

void FlowWidgetPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto& method = method_call.method_name();

  if (method == "initialize") {
    storage_ = std::make_unique<FlowWidgetStorage>(AppDataDirectory());
    storage_->Load();
    initialized_ = true;
    result->Success();
    return;
  }

  if (method == "dispose") {
    initialized_ = false;
    storage_.reset();
    result->Success();
    return;
  }

  if (method == "getCapabilities") {
    result->Success(flutter::EncodableValue(Capabilities()));
    return;
  }

  if (method == "getPlatformType") {
    result->Success(flutter::EncodableValue("windows"));
    return;
  }

  if (method == "getInstalledWidgets" || method == "getActiveLiveActivities") {
    result->Success(flutter::EncodableValue(flutter::EncodableList{}));
    return;
  }

  if (!storage_) {
    result->Error("not_initialized", "Call initialize() first.");
    return;
  }

  const auto* args = ArgsMap(method_call);

  if (method == "saveData") {
    if (args == nullptr) {
      result->Error("bad_args", "saveData requires arguments.");
      return;
    }
    const std::string key = ReadString(*args, "key");
    auto value_it = args->find(flutter::EncodableValue("value"));
    const auto* wire = value_it != args->end()
                           ? std::get_if<flutter::EncodableMap>(&value_it->second)
                           : nullptr;
    if (key.empty() || wire == nullptr) {
      result->Error("bad_args", "saveData requires key and value.");
      return;
    }
    storage_->SaveData(key, *wire);
    result->Success();
    return;
  }

  if (method == "saveBatch") {
    if (args == nullptr) {
      result->Error("bad_args", "saveBatch requires arguments.");
      return;
    }
    auto entries_it = args->find(flutter::EncodableValue("entries"));
    const auto* entries = entries_it != args->end()
                              ? std::get_if<flutter::EncodableList>(&entries_it->second)
                              : nullptr;
    if (entries == nullptr) {
      result->Error("bad_args", "saveBatch requires entries.");
      return;
    }
    storage_->SaveBatch(*entries);
    result->Success();
    return;
  }

  if (method == "getData") {
    if (args == nullptr) {
      result->Error("bad_args", "getData requires arguments.");
      return;
    }
    const std::string key = ReadString(*args, "key");
    auto wire = storage_->GetData(key);
    if (!wire.has_value()) {
      result->Success();
      return;
    }
    result->Success(flutter::EncodableValue(wire.value()));
    return;
  }

  if (method == "getAllData") {
    std::optional<std::string> prefix;
    if (args != nullptr) {
      const std::string value = ReadString(*args, "prefix");
      if (!value.empty()) {
        prefix = value;
      }
    }
    result->Success(flutter::EncodableValue(storage_->GetAllData(prefix)));
    return;
  }

  if (method == "removeData") {
    if (args == nullptr) {
      result->Error("bad_args", "removeData requires arguments.");
      return;
    }
    storage_->RemoveData(ReadString(*args, "key"));
    result->Success();
    return;
  }

  if (method == "clearData") {
    storage_->ClearData();
    result->Success();
    return;
  }

  if (method == "saveImage") {
    if (args == nullptr) {
      result->Error("bad_args", "saveImage requires arguments.");
      return;
    }
    const std::string key = ReadString(*args, "key");
    auto bytes_it = args->find(flutter::EncodableValue("bytes"));
    const auto* bytes = bytes_it != args->end()
                            ? std::get_if<std::vector<uint8_t>>(&bytes_it->second)
                            : nullptr;
    if (key.empty() || bytes == nullptr) {
      result->Error("bad_args", "saveImage requires key and bytes.");
      return;
    }
    const std::string mime = ReadString(*args, "mimeType");
    const std::string ext = mime.find("jpeg") != std::string::npos ? "jpg" : "png";
    const auto path = storage_->ImageDirectory() / (key + "." + ext);
    std::ofstream output(path, std::ios::binary | std::ios::trunc);
    output.write(reinterpret_cast<const char*>(bytes->data()),
                 static_cast<std::streamsize>(bytes->size()));
    result->Success(flutter::EncodableValue(path.string()));
    return;
  }

  if (method == "removeImage") {
    if (args == nullptr) {
      result->Error("bad_args", "removeImage requires arguments.");
      return;
    }
    const std::string key = ReadString(*args, "key");
    for (const auto& ext : {"png", "jpg", "webp", "gif"}) {
      const auto path = storage_->ImageDirectory() / (key + "." + ext);
      if (std::filesystem::exists(path)) {
        std::filesystem::remove(path);
      }
    }
    result->Success();
    return;
  }

  if (method == "update" || method == "updateMany" || method == "updateAll") {
    if (method == "update" && args != nullptr) {
      auto data_it = args->find(flutter::EncodableValue("data"));
      const auto* data = data_it != args->end()
                             ? std::get_if<flutter::EncodableMap>(&data_it->second)
                             : nullptr;
      if (data != nullptr) {
        for (const auto& entry : *data) {
          const auto* key = std::get_if<std::string>(&entry.first);
          const auto* wire = std::get_if<flutter::EncodableMap>(&entry.second);
          if (key != nullptr && wire != nullptr) {
            storage_->SaveData(*key, *wire);
          }
        }
      }
    }
    if (method == "updateMany" && args != nullptr) {
      auto requests_it = args->find(flutter::EncodableValue("requests"));
      const auto* requests = requests_it != args->end()
                                 ? std::get_if<flutter::EncodableList>(&requests_it->second)
                                 : nullptr;
      if (requests != nullptr) {
        for (const auto& request_value : *requests) {
          const auto* request = std::get_if<flutter::EncodableMap>(&request_value);
          if (request == nullptr) {
            continue;
          }
          auto data_it = request->find(flutter::EncodableValue("data"));
          const auto* data = data_it != request->end()
                                 ? std::get_if<flutter::EncodableMap>(&data_it->second)
                                 : nullptr;
          if (data != nullptr) {
            for (const auto& entry : *data) {
              const auto* key = std::get_if<std::string>(&entry.first);
              const auto* wire = std::get_if<flutter::EncodableMap>(&entry.second);
              if (key != nullptr && wire != nullptr) {
                storage_->SaveData(*key, *wire);
              }
            }
          }
        }
      }
    }
    storage_->SetLastUpdate(CurrentMillis());
    result->Success();
    return;
  }

  if (method == "setTimeline") {
    if (args == nullptr) {
      result->Error("bad_args", "setTimeline requires arguments.");
      return;
    }
    auto widget_it = args->find(flutter::EncodableValue("widgetId"));
    auto entries_it = args->find(flutter::EncodableValue("entries"));
    const auto* widget = widget_it != args->end()
                             ? std::get_if<flutter::EncodableMap>(&widget_it->second)
                             : nullptr;
    const auto* entries = entries_it != args->end()
                              ? std::get_if<flutter::EncodableList>(&entries_it->second)
                              : nullptr;
    if (widget == nullptr || entries == nullptr) {
      result->Error("bad_args", "setTimeline requires widgetId and entries.");
      return;
    }
    const std::string name = ReadString(*widget, "name");
    std::optional<int64_t> id;
    auto id_it = widget->find(flutter::EncodableValue("id"));
    if (id_it != widget->end()) {
      if (const auto* integer = std::get_if<int32_t>(&id_it->second)) {
        id = *integer;
      } else if (const auto* int64 = std::get_if<int64_t>(&id_it->second)) {
        id = *int64;
      }
    }
    storage_->SetTimeline(name, id, *entries);
    storage_->SetLastUpdate(CurrentMillis());
    result->Success();
    return;
  }

  if (method == "registerConfig") {
    if (args == nullptr) {
      result->Error("bad_args", "registerConfig requires arguments.");
      return;
    }
    storage_->RegisterConfig(*args);
    result->Success();
    return;
  }

  if (method == "requestPinWidget") {
    result->Success(flutter::EncodableValue(false));
    return;
  }

  if (method == "startLiveActivity" || method == "updateLiveActivity" ||
      method == "endLiveActivity") {
    result->Error("unsupported", "Live Activities are not available on Windows.");
    return;
  }

  result->NotImplemented();
}

}  // namespace flow_widget_windows
