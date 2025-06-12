import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final connected = results.any((result) => _isConnected(result));
      _connectionController.add(connected);
    });

    _checkInitialConnection();
  }

  Stream<bool> get connectionStream => _connectionController.stream;

  void _checkInitialConnection() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    final connected = results.any((result) => _isConnected(result));
    _connectionController.add(connected);
  }

  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi;
  }

  void dispose() {
    _connectionController.close();
  }
}
