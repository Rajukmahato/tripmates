import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tripmates/core/config/app_config.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/core/services/storage/token_service.dart';
import 'package:tripmates/core/providers/app_providers.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final sessionService = ref.read(userSessionServiceProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return SocketService(
    sessionService: sessionService,
    tokenService: tokenService,
  );
});

class SocketService {
  final UserSessionService _sessionService;
  final TokenService _tokenService;
  io.Socket? _socket;
  bool _isConnected = false;

  SocketService({
    required UserSessionService sessionService,
    required TokenService tokenService,
  }) : _sessionService = sessionService,
       _tokenService = tokenService;

  bool get isConnected => _isConnected;
  io.Socket? get socket => _socket;

  /// Initialize and connect to Socket.io server
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      log('Socket already connected');
      return;
    }

    final userId = _sessionService.getCurrentUserId();
    final token = await _tokenService.getToken();

    if (userId == null || token == null) {
      log('Cannot connect socket: user not authenticated or token missing');
      return;
    }

    try {
      _socket = io.io(
        AppConfig.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(AppConfig.socketReconnectionAttempts)
            .setReconnectionDelay(AppConfig.socketReconnectionDelay)
            .setAuth({'token': token, 'userId': userId})
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        log('Socket connected: ${_socket!.id}');
        _emitUserOnline();
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        log('Socket disconnected');
      });

      _socket!.onConnectError((error) {
        log('Socket connection error: $error');
      });

      _socket!.onError((error) {
        log('Socket error: $error');
      });

      _socket!.connect();
    } catch (e) {
      log('Failed to initialize socket: $e');
    }
  }

  /// Disconnect from Socket.io server
  void disconnect() {
    if (_socket != null) {
      _emitUserOffline();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      log('Socket disconnected and disposed');
    }
  }

  /// Emit user online status
  void _emitUserOnline() {
    final userId = _sessionService.getUserId();
    if (userId != null) {
      emit('user:online', {'userId': userId});
    }
  }

  /// Emit user offline status
  void _emitUserOffline() {
    final userId = _sessionService.getUserId();
    if (userId != null) {
      emit('user:offline', {'userId': userId});
    }
  }

  /// Send a message via socket
  void sendMessage({
    required String conversationId,
    required String content,
    List<String>? imageUrls,
    String? replyToId,
  }) {
    final userId = _sessionService.getUserId();
    final userName = _sessionService.getUserFullName();

    if (userId == null) return;

    emit('message:send', {
      'conversationId': conversationId,
      'senderId': userId,
      'senderName': userName,
      'content': content,
      'imageUrls': imageUrls,
      'replyToMessageId': replyToId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send typing indicator
  void sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) {
    final userId = _sessionService.getUserId();
    if (userId == null) return;

    emit('typing', {
      'conversationId': conversationId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  /// Mark message as read
  void markMessageRead({
    required String conversationId,
    required String messageId,
  }) {
    final userId = _sessionService.getUserId();
    if (userId == null) return;

    emit('message:read', {
      'conversationId': conversationId,
      'messageId': messageId,
      'userId': userId,
    });
  }

  /// Join a conversation room
  void joinConversation(String conversationId) {
    emit('conversation:join', {'conversationId': conversationId});
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    emit('conversation:leave', {'conversationId': conversationId});
  }

  /// Listen for new messages
  void onNewMessage(void Function(Map<String, dynamic>) callback) {
    on('message:new', (data) => callback(data as Map<String, dynamic>));
  }

  /// Listen for typing indicators
  void onTypingIndicator(void Function(Map<String, dynamic>) callback) {
    on('typing', (data) => callback(data as Map<String, dynamic>));
  }

  /// Listen for message read receipts
  void onMessageRead(void Function(Map<String, dynamic>) callback) {
    on('message:read', (data) => callback(data as Map<String, dynamic>));
  }

  /// Listen for user online status
  void onUserOnline(void Function(Map<String, dynamic>) callback) {
    on('user:online', (data) => callback(data as Map<String, dynamic>));
  }

  /// Listen for user offline status
  void onUserOffline(void Function(Map<String, dynamic>) callback) {
    on('user:offline', (data) => callback(data as Map<String, dynamic>));
  }

  // ============ Location Sharing Methods ============

  /// Emit start location sharing event
  void emitStartLocationSharing({
    required String tripId,
    required double latitude,
    required double longitude,
  }) {
    final userId = _sessionService.getUserId();
    final userName = _sessionService.getUserFullName();

    if (userId == null) return;

    emit('location:start', {
      'tripId': tripId,
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Emit update location event
  void emitUpdateLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) {
    final userId = _sessionService.getUserId();
    final userName = _sessionService.getUserFullName();

    if (userId == null) return;

    emit('location:update', {
      'tripId': tripId,
      'userId': userId,
      'userName': userName,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Emit stop location sharing event
  void emitStopLocationSharing({required String tripId}) {
    final userId = _sessionService.getUserId();

    if (userId == null) return;

    emit('location:stop', {
      'tripId': tripId,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Listen for location updates from other users
  void onLocationUpdate(void Function(Map<String, dynamic>) callback) {
    on('location:update', (data) => callback(data as Map<String, dynamic>));
  }

  /// Listen for location sharing start
  void onLocationStart(void Function(Map<String, dynamic>) callback) {
    on('location:start', (data) => callback(data as Map<String, dynamic>));
  }

  /// Listen for location sharing stop
  void onLocationStop(void Function(Map<String, dynamic>) callback) {
    on('location:stop', (data) => callback(data as Map<String, dynamic>));
  }

  /// Join a trip's location room
  void joinTripLocationRoom(String tripId) {
    emit('location:join', {'tripId': tripId});
  }

  /// Leave a trip's location room
  void leaveTripLocationRoom(String tripId) {
    emit('location:leave', {'tripId': tripId});
  }

  // ============ Generic Socket Methods ============

  /// Generic emit method
  void emit(String event, [dynamic data]) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      log('Emitted: $event with data: $data');
    } else {
      log('Cannot emit $event: socket not connected');
    }
  }

  /// Generic listener method
  void on(String event, void Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
      log('Listening on: $event');
    }
  }

  /// Remove listener
  void off(String event) {
    if (_socket != null) {
      _socket!.off(event);
      log('Removed listener: $event');
    }
  }

  /// Remove all listeners for an event
  void offAll() {
    if (_socket != null) {
      _socket!.clearListeners();
      log('Cleared all socket listeners');
    }
  }
}
