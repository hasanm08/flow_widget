/// flow_widget.yaml default template helpers.
library;

Map<String, Object?> defaultFlowWidgetConfig({
  required String widgetName,
  required List<String> platforms,
  String? appGroupId,
  String prefix = '',
}) {
  return {
    'appGroupId': appGroupId ?? 'group.com.example.flowwidget',
    'platforms': platforms,
    'widgets': [
      {
        'name': widgetName,
        if (prefix.isNotEmpty) 'prefix': prefix,
        'platforms': platforms,
      },
    ],
  };
}
