import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Internet aloqasini kuzatuvchi servis
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _controller = StreamController<bool>.broadcast();

  /// Internet mavjudligi stream'i
  Stream<bool> get onConnectivityChanged => _controller.stream;

  bool _isConnected = true;
  bool _isInitialized = false;

  /// Hozirgi holat
  bool get isConnected => _isConnected;

  /// Servisni ishga tushirish
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Boshlang'ich holatni aniqlash
    await _checkConnectivity();

    // O'zgarishlarni kuzatish
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        final hasConnection = results.any(
          (r) => r != ConnectivityResult.none,
        );

        if (hasConnection) {
          // Haqiqiy internet borligini tekshirish
          final realConnection = await _hasRealInternet();
          _updateStatus(realConnection);
        } else {
          _updateStatus(false);
        }
      },
    );
  }

  /// Haqiqiy internet borligini tekshirish (DNS lookup)
  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnection = results.any(
        (r) => r != ConnectivityResult.none,
      );

      if (hasConnection) {
        final realConnection = await _hasRealInternet();
        _updateStatus(realConnection);
      } else {
        _updateStatus(false);
      }
    } catch (e) {
      debugPrint('ConnectivityService: check error: $e');
      _updateStatus(true); // Xatolikda default connected
    }
  }

  void _updateStatus(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _controller.add(connected);
      debugPrint(
        connected
            ? '🌐 Internet aloqasi tiklandi'
            : '📵 Internet aloqasi uzildi',
      );
    }
  }

  /// Qayta tekshirish
  Future<bool> checkNow() async {
    await _checkConnectivity();
    return _isConnected;
  }

  /// Servisni to'xtatish
  void dispose() {
    _subscription?.cancel();
    _controller.close();
    _isInitialized = false;
  }
}
