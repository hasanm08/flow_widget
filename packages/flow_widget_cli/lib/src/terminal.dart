/// ANSI terminal helpers for the flow_widget CLI.
library;

import 'dart:io';

class Terminal {
  Terminal({this.verbose = false});

  final bool verbose;

  static const _reset = '\x1B[0m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _cyan = '\x1B[36m';
  static const _dim = '\x1B[2m';

  bool get _supportsColor =>
      stdout.hasTerminal && !Platform.environment.containsKey('NO_COLOR');

  String _paint(String text, String color) =>
      _supportsColor ? '$color$text$_reset' : text;

  void info(String message) => stdout.writeln(message);

  void success(String message) => stdout.writeln(_paint('✓ $message', _green));

  void warn(String message) => stdout.writeln(_paint('! $message', _yellow));

  void error(String message) => stderr.writeln(_paint('✗ $message', _red));

  void heading(String message) => stdout.writeln(_paint(message, _cyan));

  void dim(String message) => stdout.writeln(_paint(message, _dim));

  void checklist({required bool ok, required String message}) {
    if (ok) {
      success(message);
    } else {
      error(message);
    }
  }

  void verboseLog(String message) {
    if (verbose) {
      dim('[verbose] $message');
    }
  }
}
