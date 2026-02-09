import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Internet aloqasini kuzatuvchi provider
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  bool _isConnected = true;
  bool _wasDisconnected = false;

  ConnectivityProvider(this._service) {
    _isConnected = _service.isConnected;
    _subscription = _service.onConnectivityChanged.listen(_onStatusChanged);
  }

  bool get isConnected => _isConnected;
  bool get wasDisconnected => _wasDisconnected;

  void _onStatusChanged(bool connected) {
    if (_isConnected != connected) {
      if (!connected) {
        _wasDisconnected = true;
      }
      _isConnected = connected;
      notifyListeners();
    }
  }

  /// Qayta tekshirish
  Future<void> checkNow() async {
    await _service.checkNow();
  }

  /// wasDisconnected flag'ini tozalash
  void clearDisconnectedFlag() {
    _wasDisconnected = false;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
