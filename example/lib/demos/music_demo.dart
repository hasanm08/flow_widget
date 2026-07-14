import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Music now-playing demo.
class MusicDemoPage extends StatefulWidget {
  /// Creates the music demo.
  const MusicDemoPage({super.key});

  @override
  State<MusicDemoPage> createState() => _MusicDemoPageState();
}

class _MusicDemoPageState extends State<MusicDemoPage> {
  String _title = 'Midnight City';
  String _artist = 'M83';
  bool _playing = true;

  Future<void> _push() async {
    await FlowWidget.saveBatch(
      entries: [
        FlowWidgetDataEntry(
          key: 'music_title',
          value: FlowWidgetValue.string(_title),
        ),
        FlowWidgetDataEntry(
          key: 'music_artist',
          value: FlowWidgetValue.string(_artist),
        ),
        FlowWidgetDataEntry(
          key: 'music_playing',
          value: FlowWidgetValue.boolValue(_playing),
        ),
      ],
    );
    await FlowWidget.update(name: 'MusicWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Music Player',
      onPushToWidget: _push,
      children: [
        TextFormField(
          initialValue: _title,
          decoration: const InputDecoration(labelText: 'Title'),
          onChanged: (v) => _title = v,
        ),
        TextFormField(
          initialValue: _artist,
          decoration: const InputDecoration(labelText: 'Artist'),
          onChanged: (v) => _artist = v,
        ),
        SwitchListTile(
          title: const Text('Playing'),
          value: _playing,
          onChanged: (v) => setState(() => _playing = v),
        ),
      ],
    );
  }
}
