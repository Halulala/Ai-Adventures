import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  ConnectivityService() {
    // Ascolta i cambiamenti di connettività: ora ricevi una List<ConnectivityResult>
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Controlla se in qualche risultato c'è connessione mobile o wifi
      final connected = results.any((result) => _isConnected(result));
      _connectionController.add(connected);
    });

    // Verifica iniziale della connessione (checkConnectivity() ritorna List<ConnectivityResult>)
    _checkInitialConnection();
  }

  Stream<bool> get connectionStream => _connectionController.stream;

  void _checkInitialConnection() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    final connected = results.any((result) => _isConnected(result));
    _connectionController.add(connected);
  }

  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;
  }

  void dispose() {
    _connectionController.close();
  }
}
