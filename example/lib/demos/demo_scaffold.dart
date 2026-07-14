import 'package:flutter/material.dart';

/// Shared scaffold for demo pages with a primary action.
class DemoScaffold extends StatelessWidget {
  /// Creates a demo scaffold.
  const DemoScaffold({
    required this.title,
    required this.children,
    required this.onPushToWidget,
    this.secondaryAction,
    super.key,
  });

  /// App bar title.
  final String title;

  /// Body widgets.
  final List<Widget> children;

  /// Pushes state to the home-screen widget.
  final Future<void> Function() onPushToWidget;

  /// Optional secondary button.
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...children,
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await onPushToWidget();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Widget updated')));
              }
            },
            icon: const Icon(Icons.widgets_outlined),
            label: const Text('Push to widget'),
          ),
          if (secondaryAction != null) ...[
            const SizedBox(height: 12),
            secondaryAction!,
          ],
        ],
      ),
    );
  }
}
