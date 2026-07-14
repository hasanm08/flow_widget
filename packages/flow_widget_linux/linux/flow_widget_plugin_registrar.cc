#include "include/flow_widget_linux/flow_widget_plugin.h"

#include <flutter/plugin_registrar_linux.h>

#include <memory>

#include "flow_widget_plugin.h"

namespace {

class FlowWidgetLinuxPluginRegistrar {
 public:
  explicit FlowWidgetLinuxPluginRegistrar(FlPluginRegistrar* registrar)
      : registrar_(registrar) {}

  void Register() {
    flow_widget_linux::FlowWidgetPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
            ->GetRegistrar<flutter::PluginRegistrarLinux>(registrar_));
  }

 private:
  FlPluginRegistrar* registrar_;
};

}  // namespace

void flow_widget_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlowWidgetLinuxPluginRegistrar(registrar).Register();
}
