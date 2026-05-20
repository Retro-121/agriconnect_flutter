import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void _init() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Check if any result is NOT 'none'
      final bool online = results.any((result) => result != ConnectivityResult.none);
      if (_isOnline != online) {
        _isOnline = online;
        notifyListeners();
      }
    });
    
    // Initial check
    _connectivity.checkConnectivity().then((results) {
      final bool online = results.any((result) => result != ConnectivityResult.none);
      _isOnline = online;
      notifyListeners();
    });
  }
}
