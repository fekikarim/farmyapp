import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'auth_service.dart';

/// Singleton service that manages the Socket.IO connection to the backend.
/// Connects with the user's JWT token and exposes event registration.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  final Map<String, List<Function(dynamic)>> _listeners = {};

  bool get isConnected => _isConnected;

  /// Connect to the backend Socket.IO server with the current access token.
  Future<void> connect() async {
    if (_socket != null && _isConnected) return;

    final token = await AuthService.getAccessToken();
    if (token == null) {
      debugPrint('[SocketService] No access token — skipping connect');
      return;
    }

    final baseUrl = dotenv.get(
      'API_BASE_URL',
      fallback: 'http://192.168.0.133:3001',
    );

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('[SocketService] Connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('[SocketService] Disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      debugPrint('[SocketService] Connection error: $error');
    });

    // Re-register any previously registered listeners
    _listeners.forEach((event, handlers) {
      for (final handler in handlers) {
        _socket!.on(event, handler);
      }
    });

    _socket!.connect();
  }

  /// Register an event listener. Survives reconnections.
  void on(String event, Function(dynamic) handler) {
    _listeners.putIfAbsent(event, () => []).add(handler);
    _socket?.on(event, handler);
  }

  /// Remove all listeners for a given event.
  void off(String event) {
    _listeners.remove(event);
    _socket?.off(event);
  }

  /// Emit an event.
  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  /// Disconnect and clean up.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _listeners.clear();
    debugPrint('[SocketService] Disconnected and cleaned up');
  }
}
