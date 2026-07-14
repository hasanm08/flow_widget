import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demos/demo_catalog.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlowWidget.initialize(
    options: const FlowWidgetOptions(
      enableDebugLogging: true,
      appGroupId: 'group.dev.flowwidget.example',
      useGlance: true,
    ),
  );

  for (final demo in DemoCatalog.all) {
    await FlowWidget.registerConfig(demo.config);
  }

  runApp(const FlowWidgetExampleApp());
}

/// Example application showcasing flow_widget integrations.
class FlowWidgetExampleApp extends StatelessWidget {
  /// Creates the example app.
  const FlowWidgetExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flow_widget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  StreamSubscription<FlowWidgetClickEvent>? _clickSub;
  String? _lastClick;
  FlowWidgetCapabilities? _capabilities;
  List<FlowWidgetInfo> _installed = const [];

  @override
  void initState() {
    super.initState();
    _clickSub = FlowWidget.onClicked.listen((event) {
      setState(() {
        _lastClick =
            '${event.widgetId.name} · ${event.action ?? event.uri ?? 'tap'}';
      });
    });
    unawaited(_loadMeta());
  }

  Future<void> _loadMeta() async {
    final caps = await FlowWidget.getCapabilities();
    final installed = await FlowWidget.getInstalledWidgets();
    if (!mounted) return;
    setState(() {
      _capabilities = caps;
      _installed = installed;
    });
  }

  @override
  void dispose() {
    unawaited(_clickSub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('flow_widget'),
            actions: [
              IconButton(
                tooltip: 'Update all widgets',
                onPressed: () async {
                  await FlowWidget.updateAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All widgets refreshed')),
                    );
                  }
                },
                icon: const Icon(Icons.sync),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'One Dart API for home widgets, Live Activities, '
                'Wear tiles, and more.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (_lastClick != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _InfoBanner(
                  icon: Icons.touch_app_outlined,
                  label: 'Last click: $_lastClick',
                ),
              ),
            ),
          if (_capabilities != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _CapabilitiesStrip(capabilities: _capabilities!),
              ),
            ),
          if (_installed.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${_installed.length} installed instance'
                  '${_installed.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.separated(
              itemCount: DemoCatalog.all.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final demo = DemoCatalog.all[index];
                return _DemoTile(
                  demo: demo,
                  onOpen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => demo.buildPage(context),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.demo, required this.onOpen});

  final DemoEntry demo;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: demo.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(demo.icon, color: demo.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(demo.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      demo.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilitiesStrip extends StatelessWidget {
  const _CapabilitiesStrip({required this.capabilities});

  final FlowWidgetCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    final flags = <String, bool>{
      'Home': capabilities.homeWidgets,
      'Lock': capabilities.lockScreenWidgets,
      'Interactive': capabilities.interactiveWidgets,
      'Timeline': capabilities.timelineProviders,
      'Live': capabilities.liveActivities,
      'Island': capabilities.dynamicIsland,
      'Pin': capabilities.pinWidget,
      'Tiles': capabilities.wearTiles,
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in flags.entries)
          Chip(
            visualDensity: VisualDensity.compact,
            avatar: Icon(
              e.value ? Icons.check_circle : Icons.cancel_outlined,
              size: 16,
            ),
            label: Text(e.key),
          ),
      ],
    );
  }
}
