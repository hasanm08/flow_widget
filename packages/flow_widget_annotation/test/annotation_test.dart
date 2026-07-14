import 'package:flow_widget_annotation/flow_widget_annotation.dart';
import 'package:test/test.dart';

void main() {
  test('annotation defaults', () {
    const annotation = FlowWidgetModel();
    expect(annotation.prefix, isEmpty);
    expect(annotation.storageKey, isNull);
    expect(annotation.generateJson, isTrue);
  });
}
