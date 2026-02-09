import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Image optimization utilities
class ImageOptimizer {
  /// Get optimal image size based on device pixel ratio
  static int getOptimalWidth(BuildContext context, double displayWidth) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return (displayWidth * pixelRatio).round();
  }

  /// Build optimized network image URL with size parameters
  static String getResizedUrl(
    String originalUrl, {
    int? width,
    int? height,
    int quality = 80,
  }) {
    // For Supabase storage
    if (originalUrl.contains('supabase')) {
      final params = <String>[];
      if (width != null) params.add('width=$width');
      if (height != null) params.add('height=$height');
      params.add('quality=$quality');

      final separator = originalUrl.contains('?') ? '&' : '?';
      return '$originalUrl$separator${params.join('&')}';
    }

    return originalUrl;
  }
}

/// List performance optimizer
class ListOptimizer {
  /// Estimate item extent for better list performance
  static double estimateItemExtent(int itemCount) {
    // Return appropriate item height based on content
    return 120.0; // Default product card height
  }

  /// Build optimized ListView
  static Widget buildOptimizedList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    double? itemExtent,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: items.length,
      itemExtent: itemExtent,
      // Optimization flags
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) =>
          itemBuilder(context, items[index], index),
    );
  }

  /// Build optimized GridView
  static Widget buildOptimizedGrid<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      gridDelegate: gridDelegate,
      itemCount: items.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) =>
          itemBuilder(context, items[index], index),
    );
  }
}

/// Debouncer for search and other inputs
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler for scroll and resize events
class Throttler {
  final Duration interval;
  DateTime? _lastRun;

  Throttler({this.interval = const Duration(milliseconds: 100)});

  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      action();
    }
  }
}

/// Lazy loading helper
class LazyLoader<T> {
  T? _value;
  final T Function() _factory;
  bool _isLoaded = false;

  LazyLoader(this._factory);

  T get value {
    if (!_isLoaded) {
      _value = _factory();
      _isLoaded = true;
    }
    return _value as T;
  }

  bool get isLoaded => _isLoaded;

  void reset() {
    _value = null;
    _isLoaded = false;
  }
}

/// Async lazy loader
class AsyncLazyLoader<T> {
  T? _value;
  final Future<T> Function() _factory;
  bool _isLoading = false;
  bool _isLoaded = false;
  Completer<T>? _completer;

  AsyncLazyLoader(this._factory);

  Future<T> get value async {
    if (_isLoaded) return _value as T;

    if (_isLoading) {
      return _completer!.future;
    }

    _isLoading = true;
    _completer = Completer<T>();

    try {
      _value = await _factory();
      _isLoaded = true;
      _completer!.complete(_value);
      return _value as T;
    } catch (e) {
      _completer!.completeError(e);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  bool get isLoaded => _isLoaded;

  void reset() {
    _value = null;
    _isLoaded = false;
    _isLoading = false;
    _completer = null;
  }
}

/// Build optimization mixin
mixin BuildOptimization<T extends StatefulWidget> on State<T> {
  /// Prevent unnecessary rebuilds with mounted check
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Delayed state update to batch multiple changes
  Timer? _batchTimer;

  void batchSetState(VoidCallback fn, {Duration delay = Duration.zero}) {
    _batchTimer?.cancel();
    _batchTimer = Timer(delay, () {
      if (mounted) {
        setState(fn);
      }
    });
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    super.dispose();
  }
}

/// Widget key generator for list items
class KeyGenerator {
  /// Generate stable key for list item
  static Key forItem(String id) => ValueKey(id);

  /// Generate unique key
  static Key unique() => UniqueKey();

  /// Generate object key
  static Key forObject(Object object) => ObjectKey(object);
}

/// Performance tips for development
class PerformanceTips {
  static void printTips() {
    if (!kDebugMode) return;

    debugPrint('''
╔══════════════════════════════════════════════════════════════╗
║                    PERFORMANCE TIPS                           ║
╠══════════════════════════════════════════════════════════════╣
║ 1. Use const constructors where possible                     ║
║ 2. Avoid rebuilding entire lists - use keys                  ║
║ 3. Use RepaintBoundary for complex widgets                   ║
║ 4. Lazy load images with cacheWidth/cacheHeight              ║
║ 5. Use ListView.builder instead of ListView                  ║
║ 6. Avoid opacity widget - use FadeTransition                 ║
║ 7. Profile with Flutter DevTools                             ║
║ 8. Use isolates for heavy computations                       ║
║ 9. Minimize widget tree depth                                ║
║ 10. Cache network responses                                  ║
╚══════════════════════════════════════════════════════════════╝
''');
  }
}
