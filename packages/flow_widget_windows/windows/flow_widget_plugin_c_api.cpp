#include "include/flow_widget_windows/flow_widget_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flow_widget_plugin.h"

void FlowWidgetPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flow_widget_windows::FlowWidgetPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
