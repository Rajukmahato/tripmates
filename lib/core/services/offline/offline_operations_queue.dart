import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for offline operations queue service
final offlineOperationsQueueProvider = Provider<OfflineOperationsQueue>((ref) {
  return OfflineOperationsQueue();
});

/// Enum for operation types
enum OperationType { create, update, delete }

/// Enum for operation status
enum OperationStatus { pending, processing, completed, failed }

/// Model for queued operations
class QueuedOperation {
  final String id;
  final String feature; // 'trip', 'profile', 'chat', etc.
  final OperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  OperationStatus status;
  String? errorMessage;
  int retryCount;

  QueuedOperation({
    required this.id,
    required this.feature,
    required this.type,
    required this.data,
    required this.timestamp,
    this.status = OperationStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feature': feature,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
      'retryCount': retryCount,
    };
  }

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      feature: json['feature'] as String,
      type: OperationType.values.firstWhere((e) => e.name == json['type']),
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: OperationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OperationStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// Offline operations queue service
class OfflineOperationsQueue {
  static const String _boxName = 'offline_operations_queue';
  static const int maxRetries = 3;

  Box get _box => Hive.box(_boxName);

  /// Queue an operation for later sync
  Future<void> queueOperation({
    required String id,
    required String feature,
    required OperationType type,
    required Map<String, dynamic> data,
  }) async {
    final operation = QueuedOperation(
      id: id,
      feature: feature,
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    await _box.put(operation.id, json.encode(operation.toJson()));
    print('🔄 [OfflineQueue] Queued $feature ${type.name} operation: $id');
  }

  /// Get all pending operations
  List<QueuedOperation> getPendingOperations() {
    final operations = <QueuedOperation>[];

    for (var key in _box.keys) {
      try {
        final jsonString = _box.get(key) as String;
        final operation = QueuedOperation.fromJson(
          json.decode(jsonString) as Map<String, dynamic>,
        );

        if (operation.status == OperationStatus.pending ||
            (operation.status == OperationStatus.failed &&
                operation.retryCount < maxRetries)) {
          operations.add(operation);
        }
      } catch (e) {
        print('❌ [OfflineQueue] Error parsing operation $key: $e');
      }
    }

    // Sort by timestamp (oldest first)
    operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return operations;
  }

  /// Get operations by feature
  List<QueuedOperation> getOperationsByFeature(String feature) {
    return getPendingOperations().where((op) => op.feature == feature).toList();
  }

  /// Mark operation as processing
  Future<void> markAsProcessing(String operationId) async {
    try {
      final jsonString = _box.get(operationId) as String?;
      if (jsonString != null) {
        final operation = QueuedOperation.fromJson(
          json.decode(jsonString) as Map<String, dynamic>,
        );
        operation.status = OperationStatus.processing;
        await _box.put(operationId, json.encode(operation.toJson()));
      }
    } catch (e) {
      print('❌ [OfflineQueue] Error marking as processing: $e');
    }
  }

  /// Mark operation as completed and remove from queue
  Future<void> markAsCompleted(String operationId) async {
    await _box.delete(operationId);
    print('✅ [OfflineQueue] Completed operation: $operationId');
  }

  /// Mark operation as failed
  Future<void> markAsFailed(String operationId, String errorMessage) async {
    try {
      final jsonString = _box.get(operationId) as String?;
      if (jsonString != null) {
        final operation = QueuedOperation.fromJson(
          json.decode(jsonString) as Map<String, dynamic>,
        );
        operation.status = OperationStatus.failed;
        operation.errorMessage = errorMessage;
        operation.retryCount++;

        if (operation.retryCount >= maxRetries) {
          print(
            '❌ [OfflineQueue] Max retries reached for $operationId, removing',
          );
          await _box.delete(operationId);
        } else {
          await _box.put(operationId, json.encode(operation.toJson()));
          print(
            '⚠️ [OfflineQueue] Failed operation $operationId (retry ${operation.retryCount}/$maxRetries)',
          );
        }
      }
    } catch (e) {
      print('❌ [OfflineQueue] Error marking as failed: $e');
    }
  }

  /// Get count of pending operations
  int getPendingCount() {
    return getPendingOperations().length;
  }

  /// Clear all operations (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
    print('🗑️ [OfflineQueue] Cleared all operations');
  }

  /// Clear operations by feature
  Future<void> clearByFeature(String feature) async {
    final operations = getOperationsByFeature(feature);
    for (var op in operations) {
      await _box.delete(op.id);
    }
    print('🗑️ [OfflineQueue] Cleared $feature operations');
  }
}
