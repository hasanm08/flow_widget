#ifndef FLOW_WIDGET_LINUX_FLOW_WIDGET_PLUGIN_H_
#define FLOW_WIDGET_LINUX_FLOW_WIDGET_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_linux.h>

#include <memory>

#include "flow_widget_storage.h"

namespace flow_widget_linux {

class FlowWidgetPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarLinux* registrar);

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
};

}  // namespace flow_widget_linux

#endif  // FLOW_WIDGET_LINUX_FLOW_WIDGET_PLUGIN_H_
