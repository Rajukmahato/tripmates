import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart'
    show NetworkInfo;
import 'package:tripmates/core/services/offline/offline_operations_queue.dart';
import 'package:tripmates/features/auth/data/datasources/auth_datasource.dart';
import 'package:tripmates/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:tripmates/features/auth/data/models/auth_api_model.dart';
import 'package:tripmates/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:tripmates/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:tripmates/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/trip/data/datasources/remote/trip_remote_datasource.dart';

/// Provider for connection status service with proper disposal.
final connectionStatusServiceProvider = Provider<ConnectionStatusService>((
  ref,
) {
  final service = ConnectionStatusService(
    networkInfo: ref.read(networkInfoProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for connection status stream.
final connectionStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.read(connectionStatusServiceProvider);
  return service.connectionStream;
});

/// Provider for sync service.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    networkInfo: ref.read(networkInfoProvider),
    operationsQueue: ref.read(offlineOperationsQueueProvider),
    tripRemoteDataSource: ref.read(tripRemoteDatasourceProvider),
    profileRemoteDataSource: ref.read(profileRemoteDataSourceProvider),
    notificationRemoteDataSource: ref.read(
      notificationRemoteDataSourceProvider,
    ),
    chatRemoteDataSource: ref.read(chatRemoteDatasourceProvider),
    authRemoteDataSource: ref.read(authRemoteDatasourceProvider),
  );
});

/// Initializes auto-sync listener once for the app lifecycle.
final autoSyncInitializerProvider = Provider<void>((ref) {
  final syncService = ref.read(syncServiceProvider);
  final connectionService = ref.read(connectionStatusServiceProvider);
  final subscription = syncService.startAutoSync(
    connectionService.connectionStream,
  );
  ref.onDispose(() => subscription.cancel());
});

/// Service to monitor connection status.
class ConnectionStatusService {
  final NetworkInfo networkInfo;
  late final StreamController<bool> _controller;
  Timer? _timer;

  ConnectionStatusService({required this.networkInfo}) {
    _controller = StreamController<bool>.broadcast();
    _startMonitoring();
  }

  Stream<bool> get connectionStream => _controller.stream;

  void _startMonitoring() {
    _checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final isConnected = await networkInfo.isConnected;
    _controller.add(isConnected);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

/// Service to sync offline operations when online.
class SyncService {
  final NetworkInfo networkInfo;
  final OfflineOperationsQueue operationsQueue;
  final ITripRemoteDataSource tripRemoteDataSource;
  final IProfileRemoteDataSource profileRemoteDataSource;
  final NotificationRemoteDataSource notificationRemoteDataSource;
  final IChatRemoteDataSource chatRemoteDataSource;
  final IAuthRemoteDataSource authRemoteDataSource;

  bool _isSyncing = false;

  SyncService({
    required this.networkInfo,
    required this.operationsQueue,
    required this.tripRemoteDataSource,
    required this.profileRemoteDataSource,
    required this.notificationRemoteDataSource,
    required this.chatRemoteDataSource,
    required this.authRemoteDataSource,
  });

  bool get isSyncing => _isSyncing;

  Future<SyncResult> syncPendingOperations() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return SyncResult(success: false, message: 'No internet connection');
    }

    _isSyncing = true;

    try {
      final operations = operationsQueue.getPendingOperations();
      if (operations.isEmpty) {
        _isSyncing = false;
        return SyncResult(success: true, message: 'No operations to sync');
      }

      int successCount = 0;
      int failureCount = 0;
      final errors = <String>[];

      for (final operation in operations) {
        try {
          await operationsQueue.markAsProcessing(operation.id);
          await _processOperation(operation);
          await operationsQueue.markAsCompleted(operation.id);
          successCount++;
        } catch (e) {
          await operationsQueue.markAsFailed(operation.id, e.toString());
          failureCount++;
          errors.add('${operation.feature}: $e');
        }
      }

      _isSyncing = false;

      final message = successCount > 0
          ? 'Synced $successCount operations${failureCount > 0 ? ', $failureCount failed' : ''}'
          : 'All operations failed';

      return SyncResult(
        success: successCount > 0,
        message: message,
        successCount: successCount,
        failureCount: failureCount,
        errors: errors,
      );
    } catch (e) {
      _isSyncing = false;
      return SyncResult(success: false, message: 'Sync error: $e');
    }
  }

  StreamSubscription<bool> startAutoSync(Stream<bool> connectionStream) {
    bool wasOffline = false;

    // Ensure queued operations are flushed on app start when already online.
    unawaited(_syncIfOnline());

    return connectionStream.listen((isOnline) async {
      if (isOnline && wasOffline) {
        await Future.delayed(const Duration(seconds: 2));
        await syncPendingOperations();
      }
      wasOffline = !isOnline;
    });
  }

  Future<void> _syncIfOnline() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected || operationsQueue.getPendingCount() == 0) {
      return;
    }
    await syncPendingOperations();
  }

  Future<void> _processOperation(QueuedOperation operation) async {
    switch (operation.feature) {
      case 'auth':
        await _processAuthOperation(operation);
        return;
      case 'trip':
        await _processTripOperation(operation);
        return;
      case 'profile':
        await _processProfileOperation(operation);
        return;
      case 'notification':
        await _processNotificationOperation(operation);
        return;
      case 'chat':
        await _processChatOperation(operation);
        return;
      default:
        throw UnsupportedError(
          'Unsupported feature for sync: ${operation.feature}',
        );
    }
  }

  Future<void> _processTripOperation(QueuedOperation operation) async {
    final action = operation.data['action']?.toString();

    if (operation.type == OperationType.create) {
      final payload = operation.data['tripData'];
      final tripData = payload is Map
          ? Map<String, dynamic>.from(payload)
          : Map<String, dynamic>.from(operation.data);
      final imagePathsRaw = operation.data['imagePaths'];
      final imagePaths = imagePathsRaw is List
          ? imagePathsRaw.map((item) => item.toString()).toList()
          : null;

      await tripRemoteDataSource.createTrip(
        tripData: tripData,
        imagePaths: imagePaths,
      );
      return;
    }

    if (action == 'update_trip' && operation.type == OperationType.update) {
      final tripId = operation.data['tripId'] as String?;
      final tripData = operation.data['tripData'] as Map?;
      if (tripId == null || tripData == null) {
        throw StateError('Invalid trip update payload');
      }

      final imagePathsRaw = operation.data['imagePaths'];
      final imagePaths = imagePathsRaw is List
          ? imagePathsRaw.map((item) => item.toString()).toList()
          : null;

      await tripRemoteDataSource.updateTrip(
        tripId: tripId,
        tripData: Map<String, dynamic>.from(tripData),
        imagePaths: imagePaths,
      );
      return;
    }

    if (action == 'delete_trip' && operation.type == OperationType.delete) {
      final tripId = operation.data['tripId'] as String?;
      if (tripId == null) {
        throw StateError('Invalid trip delete payload');
      }
      await tripRemoteDataSource.deleteTrip(tripId);
      return;
    }

    if (action == 'update_itinerary' &&
        operation.type == OperationType.update) {
      final tripId = operation.data['tripId'] as String?;
      final itinerary = operation.data['itinerary'] as List?;
      if (tripId == null || itinerary == null) {
        throw StateError('Invalid itinerary payload');
      }
      await tripRemoteDataSource.updateItinerary(
        tripId: tripId,
        itinerary: itinerary
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
      return;
    }

    if (action == 'update_checklist' &&
        operation.type == OperationType.update) {
      final tripId = operation.data['tripId'] as String?;
      final checklist = operation.data['checklist'] as List?;
      if (tripId == null || checklist == null) {
        throw StateError('Invalid checklist payload');
      }
      await tripRemoteDataSource.updateChecklist(
        tripId: tripId,
        checklist: checklist
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
      return;
    }

    if (action == 'join_request' && operation.type == OperationType.create) {
      final tripId = operation.data['tripId'] as String?;
      final userId = operation.data['userId'] as String?;
      if (tripId == null || userId == null) {
        throw StateError('Invalid join request payload');
      }
      await tripRemoteDataSource.sendJoinRequest(
        tripId: tripId,
        userId: userId,
        message: operation.data['message'] as String?,
      );
      return;
    }

    throw UnsupportedError(
      'Unsupported trip operation payload: ${operation.data}',
    );
  }

  Future<void> _processProfileOperation(QueuedOperation operation) async {
    if (operation.type != OperationType.update) {
      throw UnsupportedError(
        'Unsupported profile operation type: ${operation.type.name}',
      );
    }

    final userId = operation.data['userId'] as String?;
    final fullName = operation.data['fullName'] as String?;
    final email = operation.data['email'] as String?;

    if (userId == null || fullName == null || email == null) {
      throw StateError('Invalid profile payload');
    }

    final profile = ProfileEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phone: operation.data['phone'] as String?,
      profilePicture: operation.data['profilePicture'] as String?,
      bio: operation.data['bio'] as String?,
      location: operation.data['location'] as String?,
      totalTrips: (operation.data['totalTrips'] as int?) ?? 0,
      completedTrips: (operation.data['completedTrips'] as int?) ?? 0,
    );

    final result = await profileRemoteDataSource.updateProfile(profile);
    result.fold(
      (failure) => throw StateError('Profile sync failed: ${failure.message}'),
      (_) => null,
    );
  }

  Future<void> _processNotificationOperation(QueuedOperation operation) async {
    final action = operation.data['action']?.toString();

    if (action == 'mark_as_read') {
      final notificationId = operation.data['notificationId'] as String?;
      if (notificationId == null) {
        throw StateError('Invalid notification mark_as_read payload');
      }
      await notificationRemoteDataSource.markAsRead(notificationId);
      return;
    }

    if (action == 'mark_all_as_read') {
      await notificationRemoteDataSource.markAllAsRead();
      return;
    }

    if (action == 'delete_notification') {
      final notificationId = operation.data['notificationId'] as String?;
      if (notificationId == null) {
        throw StateError('Invalid notification delete payload');
      }
      await notificationRemoteDataSource.deleteNotification(notificationId);
      return;
    }

    if (action == 'delete_all_notifications') {
      await notificationRemoteDataSource.deleteAllNotifications();
      return;
    }

    throw UnsupportedError(
      'Unsupported notification operation payload: ${operation.data}',
    );
  }

  Future<void> _processChatOperation(QueuedOperation operation) async {
    final action = operation.data['action']?.toString();

    if (action == 'send_message' && operation.type == OperationType.create) {
      final conversationId = operation.data['conversationId'] as String?;
      final senderId = operation.data['senderId'] as String?;
      final senderName = operation.data['senderName'] as String?;
      final content = operation.data['content'] as String?;

      if (conversationId == null ||
          senderId == null ||
          senderName == null ||
          content == null) {
        throw StateError('Invalid chat send_message payload');
      }

      final imageUrlsRaw = operation.data['imageUrls'];
      final imageUrls = imageUrlsRaw is List
          ? imageUrlsRaw.map((item) => item.toString()).toList()
          : null;

      await chatRemoteDataSource.sendMessage(
        conversationId,
        senderId,
        senderName,
        content,
        imageUrls: imageUrls,
        replyToMessageId: operation.data['replyToMessageId'] as String?,
      );
      return;
    }

    throw UnsupportedError(
      'Unsupported chat operation payload: ${operation.data}',
    );
  }

  Future<void> _processAuthOperation(QueuedOperation operation) async {
    final action = operation.data['action']?.toString();

    switch (action) {
      case 'register':
        final fullName = operation.data['fullName'] as String?;
        final email = operation.data['email'] as String?;
        final phoneNumber = operation.data['phoneNumber'] as String?;
        final username = operation.data['username'] as String?;
        final password = operation.data['password'] as String?;
        final batchId = operation.data['batchId'] as String?;
        final profilePicture = operation.data['profilePicture'] as String?;

        if (email == null || password == null || fullName == null) {
          throw StateError(
            'Invalid register operation: missing required fields',
          );
        }

        await authRemoteDataSource.register(
          AuthApiModel(
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber ?? '',
            username: username ?? '',
            password: password,
            batchId: batchId,
            profilePicture: profilePicture,
          ),
        );
        return;

      case 'forgot_password':
        final email = operation.data['email'] as String?;
        final platform = operation.data['platform'] as String?;

        if (email == null) {
          throw StateError('Invalid forgot_password operation: missing email');
        }

        await authRemoteDataSource.forgotPassword(email, platform: platform);
        return;

      default:
        throw UnsupportedError('Unsupported auth action: $action');
    }
  }
}

/// Result of sync operation.
class SyncResult {
  final bool success;
  final String message;
  final int successCount;
  final int failureCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    this.successCount = 0,
    this.failureCount = 0,
    this.errors = const [],
  });
}
