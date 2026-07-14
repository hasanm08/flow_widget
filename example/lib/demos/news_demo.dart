import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// News headlines demo with remote image caching.
class NewsDemoPage extends StatefulWidget {
  /// Creates the news demo.
  const NewsDemoPage({super.key});

  @override
  State<NewsDemoPage> createState() => _NewsDemoPageState();
}

class _NewsDemoPageState extends State<NewsDemoPage> {
  String _headline = 'Flutter 3.38 sharpens Impeller performance';
  String _source = 'Flow Daily';
  final String _imageUrl =
      'https://docs.flutter.dev/assets/images/flutter-logo-sharing.png';

  Future<void> _push() async {
    await FlowWidget.saveImage(
      FlowWidgetImage.remote(key: 'news_hero', url: _imageUrl),
    );
    await FlowWidget.saveBatch(
      entries: [
        FlowWidgetDataEntry(
          key: 'news_headline',
          value: FlowWidgetValue.string(_headline),
        ),
        FlowWidgetDataEntry(
          key: 'news_source',
          value: FlowWidgetValue.string(_source),
        ),
        const FlowWidgetDataEntry(
          key: 'news_image_key',
          value: FlowWidgetValue.string('news_hero'),
        ),
      ],
    );
    await FlowWidget.update(name: 'NewsWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'News',
      onPushToWidget: _push,
      children: [
        TextFormField(
          initialValue: _headline,
          decoration: const InputDecoration(labelText: 'Headline'),
          maxLines: 2,
          onChanged: (v) => _headline = v,
        ),
        TextFormField(
          initialValue: _source,
          decoration: const InputDecoration(labelText: 'Source'),
          onChanged: (v) => _source = v,
        ),
      ],
    );
  }
}
