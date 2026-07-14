import 'package:build/build.dart';
import 'package:flow_widget_generator/src/flow_widget_model_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Creates the flow_widget build_runner builder.
Builder flowWidgetBuilder(BuilderOptions options) =>
    SharedPartBuilder([FlowWidgetModelGenerator()], 'flow_widget');
