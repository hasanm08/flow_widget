import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'calendar_demo.dart';
import 'checklist_demo.dart';
import 'countdown_demo.dart';
import 'finance_demo.dart';
import 'fitness_demo.dart';
import 'habit_demo.dart';
import 'live_activity_demo.dart';
import 'music_demo.dart';
import 'news_demo.dart';
import 'photo_demo.dart';
import 'weather_demo.dart';

/// Metadata for a single demo screen.
final class DemoEntry {
  /// Creates a demo entry.
  const DemoEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.config,
    required this.buildPage,
  });

  /// Stable id.
  final String id;

  /// Display title.
  final String title;

  /// Short description.
  final String subtitle;

  /// List icon.
  final IconData icon;

  /// Accent color.
  final Color accent;

  /// Native widget registration config.
  final FlowWidgetConfig config;

  /// Builds the demo page.
  final WidgetBuilder buildPage;
}

/// Catalog of all example demos.
abstract final class DemoCatalog {
  /// Every demo entry.
  static final List<DemoEntry> all = [
    DemoEntry(
      id: 'weather',
      title: 'Weather',
      subtitle: 'Timeline forecasts with theme sync',
      icon: Icons.wb_sunny_outlined,
      accent: const Color(0xFF2A9D8F),
      config: const FlowWidgetConfig(
        name: 'WeatherWidget',
        displayName: 'Weather',
        description: 'Current conditions and hourly forecast',
        iosKind: 'WeatherWidget',
        androidProviderFullyQualifiedName:
            'dev.flowwidget.example.weather.WeatherWidgetReceiver',
      ),
      buildPage: (_) => const WeatherDemoPage(),
    ),
    DemoEntry(
      id: 'habit',
      title: 'Habit Tracker',
      subtitle: 'Interactive completion toggles',
      icon: Icons.checklist_rtl,
      accent: const Color(0xFFE76F51),
      config: const FlowWidgetConfig(
        name: 'HabitWidget',
        displayName: 'Habits',
        interactive: true,
        iosKind: 'HabitWidget',
      ),
      buildPage: (_) => const HabitDemoPage(),
    ),
    DemoEntry(
      id: 'calendar',
      title: 'Calendar',
      subtitle: 'Next events with Smart Stack relevance',
      icon: Icons.event_outlined,
      accent: const Color(0xFF457B9D),
      config: const FlowWidgetConfig(
        name: 'CalendarWidget',
        displayName: 'Calendar',
        iosKind: 'CalendarWidget',
      ),
      buildPage: (_) => const CalendarDemoPage(),
    ),
    DemoEntry(
      id: 'fitness',
      title: 'Fitness',
      subtitle: 'Activity rings and weekly goals',
      icon: Icons.directions_run,
      accent: const Color(0xFFE63946),
      config: const FlowWidgetConfig(
        name: 'FitnessWidget',
        displayName: 'Fitness',
        iosKind: 'FitnessWidget',
      ),
      buildPage: (_) => const FitnessDemoPage(),
    ),
    DemoEntry(
      id: 'music',
      title: 'Music Player',
      subtitle: 'Now playing with deep-link actions',
      icon: Icons.library_music_outlined,
      accent: const Color(0xFF7B2CBF),
      config: const FlowWidgetConfig(
        name: 'MusicWidget',
        displayName: 'Now Playing',
        interactive: true,
        iosKind: 'MusicWidget',
      ),
      buildPage: (_) => const MusicDemoPage(),
    ),
    DemoEntry(
      id: 'finance',
      title: 'Finance',
      subtitle: 'Portfolio snapshot dashboard',
      icon: Icons.trending_up,
      accent: const Color(0xFF2D6A4F),
      config: const FlowWidgetConfig(
        name: 'FinanceWidget',
        displayName: 'Finance',
        supportedSizes: [FlowWidgetSize.medium, FlowWidgetSize.large],
        iosKind: 'FinanceWidget',
      ),
      buildPage: (_) => const FinanceDemoPage(),
    ),
    DemoEntry(
      id: 'news',
      title: 'News',
      subtitle: 'Headlines with remote image cache',
      icon: Icons.newspaper_outlined,
      accent: const Color(0xFF264653),
      config: const FlowWidgetConfig(
        name: 'NewsWidget',
        displayName: 'News',
        iosKind: 'NewsWidget',
      ),
      buildPage: (_) => const NewsDemoPage(),
    ),
    DemoEntry(
      id: 'photo',
      title: 'Photo',
      subtitle: 'Local image bytes in a widget',
      icon: Icons.photo_outlined,
      accent: const Color(0xFFBC6C25),
      config: const FlowWidgetConfig(
        name: 'PhotoWidget',
        displayName: 'Photo',
        iosKind: 'PhotoWidget',
      ),
      buildPage: (_) => const PhotoDemoPage(),
    ),
    DemoEntry(
      id: 'countdown',
      title: 'Countdown',
      subtitle: 'Scheduled timeline updates',
      icon: Icons.hourglass_bottom,
      accent: const Color(0xFF9B2226),
      config: const FlowWidgetConfig(
        name: 'CountdownWidget',
        displayName: 'Countdown',
        iosKind: 'CountdownWidget',
      ),
      buildPage: (_) => const CountdownDemoPage(),
    ),
    DemoEntry(
      id: 'checklist',
      title: 'Checklist',
      subtitle: 'Multiple interactive instances',
      icon: Icons.task_alt,
      accent: const Color(0xFF0077B6),
      config: const FlowWidgetConfig(
        name: 'ChecklistWidget',
        displayName: 'Checklist',
        interactive: true,
        configurable: true,
        iosKind: 'ChecklistWidget',
      ),
      buildPage: (_) => const ChecklistDemoPage(),
    ),
    DemoEntry(
      id: 'live',
      title: 'Live Activities',
      subtitle: 'Dynamic Island & Lock Screen',
      icon: Icons.sensors,
      accent: const Color(0xFFFB8500),
      config: const FlowWidgetConfig(
        name: 'DeliveryLiveActivity',
        displayName: 'Delivery',
        family: FlowWidgetFamily.liveActivity,
        iosKind: 'DeliveryLiveActivity',
      ),
      buildPage: (_) => const LiveActivityDemoPage(),
    ),
  ];
}
