#ifndef FLOW_WIDGET_WINDOWS_FLOW_WIDGET_PLUGIN_H_
#define FLOW_WIDGET_WINDOWS_FLOW_WIDGET_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "flow_widget_storage.h"

namespace flow_widget_windows {

class FlowWidgetPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FlowWidgetPlugin();

  virtual ~FlowWidgetPlugin();

  FlowWidgetPlugin(const FlowWidgetPlugin&) = delete;
  FlowWidgetPlugin& operator=(const FlowWidgetPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> event_channel_;
  std::unique_ptr<FlowWidgetStorage> storage_;
  bool initialized_ = false;
};

}  // namespace flow_widget_windows

#endif  // FLOW_WIDGET_WINDOWS_FLOW_WIDGET_PLUGIN_H_
