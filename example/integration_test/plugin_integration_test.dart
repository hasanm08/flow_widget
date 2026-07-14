import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flow_widget/flow_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('initialize returns capabilities', (tester) async {
    await FlowWidget.initialize();
    final caps = await FlowWidget.getCapabilities();
    expect(caps, isA<FlowWidgetCapabilities>());
    final platform = await FlowWidget.getPlatformType();
    expect(platform, isA<FlowWidgetPlatformType>());
  });
}
