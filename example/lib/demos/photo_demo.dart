import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Photo widget demo using generated image bytes.
class PhotoDemoPage extends StatefulWidget {
  /// Creates the photo demo.
  const PhotoDemoPage({super.key});

  @override
  State<PhotoDemoPage> createState() => _PhotoDemoPageState();
}

class _PhotoDemoPageState extends State<PhotoDemoPage> {
  String _caption = 'Golden hour';

  Future<Uint8List> _renderSwatch() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(200, 200);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        const [Color(0xFFBC6C25), Color(0xFFFFE8D6)],
      );
    canvas.drawRect(Offset.zero & size, paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(200, 200);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  Future<void> _push() async {
    final bytes = await _renderSwatch();
    await FlowWidget.saveImage(
      FlowWidgetImage.bytes(key: 'photo_main', bytes: bytes),
    );
    await FlowWidget.saveData(key: 'photo_caption', value: _caption);
    await FlowWidget.update(name: 'PhotoWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Photo',
      onPushToWidget: _push,
      children: [
        TextFormField(
          initialValue: _caption,
          decoration: const InputDecoration(labelText: 'Caption'),
          onChanged: (v) => _caption = v,
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFBC6C25), Color(0xFFFFE8D6)],
            ),
          ),
        ),
      ],
    );
  }
}
