/// Common platform interface for the [flow_widget](https://pub.dev/packages/flow_widget) plugin.
///
/// This package defines the contract that every federated platform
/// implementation must satisfy. Application code should depend on
/// `package:flow_widget/flow_widget.dart` instead of importing this package
/// directly, unless you are authoring a custom platform implementation.
library;

export 'src/channels/flow_widget_method_channel.dart';
export 'src/events/flow_widget_click_event.dart';
export 'src/events/flow_widget_event.dart';
export 'src/exceptions/flow_widget_exception.dart';
export 'src/flow_widget_platform.dart';
export 'src/models/flow_widget_capabilities.dart';
export 'src/models/flow_widget_config.dart';
export 'src/models/flow_widget_data_entry.dart';
export 'src/models/flow_widget_family.dart';
export 'src/models/flow_widget_id.dart';
export 'src/models/flow_widget_image.dart';
export 'src/models/flow_widget_info.dart';
export 'src/models/flow_widget_options.dart';
export 'src/models/flow_widget_timeline_entry.dart';
export 'src/models/flow_widget_update_request.dart';
export 'src/models/live_activity_config.dart';
export 'src/models/live_activity_state.dart';
export 'src/types/flow_widget_platform_type.dart';
export 'src/types/flow_widget_size.dart';
export 'src/types/flow_widget_value.dart';
