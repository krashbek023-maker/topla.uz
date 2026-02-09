import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utility
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, List<Duration>> _measurements = {};
  final Map<String, Stopwatch> _activeTimers = {};
  bool isEnabled = kDebugMode;

  /// Start timing an operation
  void startTimer(String operation) {
    if (!isEnabled) return;

    _activeTimers[operation] = Stopwatch()..start();
  }

  /// Stop timing and record measurement
  Duration? stopTimer(String operation) {
    if (!isEnabled) return null;

    final stopwatch = _activeTimers.remove(operation);
    if (stopwatch == null) return null;

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    _measurements.putIfAbsent(operation, () => []);
    _measurements[operation]!.add(duration);

    // Keep only last 100 measurements
    if (_measurements[operation]!.length > 100) {
      _measurements[operation]!.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('⏱️ [$operation] ${duration.inMilliseconds}ms');
    }

    return duration;
  }

  /// Measure async operation
  Future<T> measure<T>(String operation, Future<T> Function() fn) async {
    startTimer(operation);
    try {
      return await fn();
    } finally {
      stopTimer(operation);
    }
  }

  /// Measure sync operation
  T measureSync<T>(String operation, T Function() fn) {
    startTimer(operation);
    try {
      return fn();
    } finally {
      stopTimer(operation);
    }
  }

  /// Get average duration for operation
  Duration? getAverage(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return null;

    final total = measurements.fold<int>(
      0,
      (sum, d) => sum + d.inMicroseconds,
    );
    return Duration(microseconds: total ~/ measurements.length);
  }

  /// Get all statistics
  Map<String, PerformanceStats> getStats() {
    return _measurements.map((key, values) {
      final sorted = List<Duration>.from(values)..sort();
      final total = values.fold<int>(0, (sum, d) => sum + d.inMicroseconds);

      return MapEntry(
        key,
        PerformanceStats(
          count: values.length,
          average: Duration(microseconds: total ~/ values.length),
          min: sorted.first,
          max: sorted.last,
          median: sorted[sorted.length ~/ 2],
        ),
      );
    });
  }

  /// Clear all measurements
  void clear() {
    _measurements.clear();
    _activeTimers.clear();
  }

  /// Print all stats to console
  void printStats() {
    if (!kDebugMode) return;

    debugPrint('\n📊 Performance Stats:');
    debugPrint('=' * 60);

    final stats = getStats();
    for (final entry in stats.entries) {
      debugPrint('${entry.key}:');
      debugPrint('  Count: ${entry.value.count}');
      debugPrint('  Average: ${entry.value.average.inMilliseconds}ms');
      debugPrint('  Min: ${entry.value.min.inMilliseconds}ms');
      debugPrint('  Max: ${entry.value.max.inMilliseconds}ms');
      debugPrint('  Median: ${entry.value.median.inMilliseconds}ms');
      debugPrint('-' * 40);
    }
  }
}

/// Performance statistics
class PerformanceStats {
  final int count;
  final Duration average;
  final Duration min;
  final Duration max;
  final Duration median;

  PerformanceStats({
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.median,
  });
}

/// Frame rate monitor
class FrameRateMonitor {
  static final FrameRateMonitor _instance = FrameRateMonitor._internal();
  factory FrameRateMonitor() => _instance;
  FrameRateMonitor._internal();

  final List<Duration> _frameTimes = [];
  Stopwatch? _frameStopwatch;
  bool _isMonitoring = false;

  /// Start monitoring frame rate
  void start() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _frameTimes.clear();

    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;

    if (_frameStopwatch != null) {
      _frameTimes.add(_frameStopwatch!.elapsed);

      // Keep only last 120 frames (2 seconds at 60fps)
      if (_frameTimes.length > 120) {
        _frameTimes.removeAt(0);
      }
    }

    _frameStopwatch = Stopwatch()..start();
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  /// Stop monitoring
  void stop() {
    _isMonitoring = false;
    _frameStopwatch = null;
  }

  /// Get current FPS
  double get fps {
    if (_frameTimes.isEmpty) return 0;

    final avgFrameTime = _frameTimes.fold<int>(
          0,
          (sum, d) => sum + d.inMicroseconds,
        ) /
        _frameTimes.length;

    if (avgFrameTime == 0) return 0;
    return 1000000 / avgFrameTime; // Convert to FPS
  }

  /// Get dropped frame count (frames > 16.67ms)
  int get droppedFrames {
    return _frameTimes.where((d) => d.inMilliseconds > 17).length;
  }

  /// Get frame time percentiles
  Map<String, Duration> getPercentiles() {
    if (_frameTimes.isEmpty) return {};

    final sorted = List<Duration>.from(_frameTimes)..sort();
    return {
      'p50': sorted[(sorted.length * 0.5).floor()],
      'p90': sorted[(sorted.length * 0.9).floor()],
      'p95': sorted[(sorted.length * 0.95).floor()],
      'p99': sorted[(sorted.length * 0.99).floor()],
    };
  }
}

/// Memory usage monitor (debug only)
class MemoryMonitor {
  static void printUsage() {
    if (!kDebugMode) return;

    // Note: This is limited in Dart/Flutter
    // For real memory profiling, use DevTools
    debugPrint('💾 Memory usage info available in Flutter DevTools');
  }
}

/// Performance operations constants
class PerformanceOps {
  static const String apiCall = 'api_call';
  static const String imageLoad = 'image_load';
  static const String listBuild = 'list_build';
  static const String navigation = 'navigation';
  static const String cacheRead = 'cache_read';
  static const String cacheWrite = 'cache_write';
  static const String dbQuery = 'db_query';
  static const String jsonParse = 'json_parse';
  static const String widgetBuild = 'widget_build';
  static const String animation = 'animation';
}
