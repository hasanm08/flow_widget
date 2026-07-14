cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "flow_widget_linux")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "flow_widget_linux_plugin")

list(APPEND PLUGIN_SOURCES
  "flow_widget_plugin.cc"
  "flow_widget_plugin_registrar.cc"
  "flow_widget_storage.cpp"
  "flow_widget_value_codec.cpp"
  "flow_widget_json.cpp"
)

add_library(${PLUGIN_NAME} SHARED
  ${PLUGIN_SOURCES}
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

set(flow_widget_linux_bundled_libraries
  ""
  PARENT_SCOPE
)
