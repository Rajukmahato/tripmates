import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart'
    show NetworkInfo;
import 'package:tripmates/core/services/offline/offline_operations_queue.dart';
import 'package:tripmates/core/services/time/server_time_service.dart';
import 'package:tripmates/features/trip/data/datasources/local/trip_local_datasource.dart';
import 'package:tripmates/features/trip/data/datasources/remote/trip_remote_datasource.dart';
import 'package:tripmates/features/trip/data/datasources/trip_datasource.dart';
import 'package:tripmates/features/trip/data/models/trip_hive_model.dart';
import 'package:tripmates/features/trip/domain/entities/trip_entity.dart';
import 'package:tripmates/features/trip/domain/entities/itinerary_item_entity.dart';
import 'package:tripmates/features/trip/domain/entities/checklist_item_entity.dart';
import 'package:tripmates/features/trip/domain/repositories/trip_repository.dart';

final tripRepositoryProvider = Provider<ITripRepository>((ref) {
  final tripLocalDatasource = ref.read(tripLocalDatasourceProvider);
  final tripRemoteDatasource = ref.read(tripRemoteDatasourceProvider);
  final serverTimeService = ref.read(serverTimeServiceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final operationsQueue = ref.read(offlineOperationsQueueProvider);

  return TripRepository(
    tripLocalDatasource: tripLocalDatasource,
    tripRemoteDatasource: tripRemoteDatasource,
    serverTimeService: serverTimeService,
    networkInfo: networkInfo,
    operationsQueue: operationsQueue,
  );
});

class TripRepository implements ITripRepository {
  final ITripDataSource _tripLocalDataSource;
  final ITripRemoteDataSource _tripRemoteDataSource;
  final ServerTimeService _serverTimeService;
  final NetworkInfo _networkInfo;
  final OfflineOperationsQueue _operationsQueue;

  TripRepository({
    required ITripDataSource tripLocalDatasource,
    required ITripRemoteDataSource tripRemoteDatasource,
    required ServerTimeService serverTimeService,
    required NetworkInfo networkInfo,
    required OfflineOperationsQueue operationsQueue,
  }) : _tripLocalDataSource = tripLocalDatasource,
       _tripRemoteDataSource = tripRemoteDatasource,
       _serverTimeService = serverTimeService,
       _networkInfo = networkInfo,
       _operationsQueue = operationsQueue;

  String _mapTravelTypeForApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return 'leisure';

    switch (normalized) {
      case 'adventure':
      case 'leisure':
      case 'business':
      case 'backpacking':
      case 'cultural':
        return normalized;
      case 'solo':
      case 'hiking':
      case 'trek':
      case 'trekking':
        return 'adventure';
      case 'family':
        return 'cultural';
      case 'group':
      case 'friends':
      case 'couple':
      default:
        return 'leisure';
    }
  }

  String _mapStatusForApi(TripStatus status) {
    switch (status) {
      case TripStatus.planned:
      case TripStatus.ongoing:
        return 'open';
      case TripStatus.completed:
        return 'completed';
    }
  }

  int _resolveGroupSize(TripEntity trip) {
    return trip.groupSizeMax ?? trip.groupSizeMin ?? 1;
  }

  @override
  Future<Either<Failure, bool>> createTrip(TripEntity trip) async {
    print('🟠 [TripRepository] createTrip called');
    print('   Trip: ${trip.tripName}');

    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;

    // Convert entity to JSON for API
    final tripData = {
      'tripName': trip.tripName,
      'destination': trip.destination,
      'startDate': trip.startDate.toIso8601String(),
      'endDate': trip.endDate.toIso8601String(),
      if (trip.description != null) 'description': trip.description,
      if (trip.category != null) 'category': trip.category,
      if (trip.media != null) 'media': trip.media,
      if (trip.mediaType != null) 'mediaType': trip.mediaType,
      'status': _mapStatusForApi(trip.status),
      if (trip.budget != null) 'budget': trip.budget,
      'travelType': _mapTravelTypeForApi(trip.travelType),
      'groupSize': _resolveGroupSize(trip),
    };

    if (isConnected) {
      // Online: create on remote
      try {
        print('🟠 [TripRepository] Calling remote datasource with data:');
        print('   $tripData');
        print('   Image path: ${trip.media}');

        final apiModel = await _tripRemoteDataSource.createTrip(
          tripData: tripData,
          imagePaths: trip.media != null ? [trip.media!] : null,
        );

        print('✅ [TripRepository] Remote API call SUCCESS');
        print('   Returned trip ID: ${apiModel.id}');

        // Save to local cache
        try {
          final localModel = TripHiveModel.fromEntity(apiModel.toEntity());
          await _tripLocalDataSource.createTrip(localModel);
          print('✅ [TripRepository] Saved to local cache');
        } catch (e) {
          log('Failed to save to local cache: $e');
        }

        return const Right(true);
      } on ServerException catch (e) {
        print('❌ [TripRepository] ServerException: ${e.message}');
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        print('❌ [TripRepository] Generic error: $e');
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline: save locally and queue
      print('📵 [TripRepository] Offline, queueing trip creation');

      try {
        // Create a trip model for local storage with a generated local ID.
        final localModel = TripHiveModel.fromEntity(trip);
        await _tripLocalDataSource.createTrip(localModel);

        final localTripId =
            localModel.tripId ??
            DateTime.now().millisecondsSinceEpoch.toString();

        // Queue operation for later sync
        await _operationsQueue.queueOperation(
          id: 'trip_create_$localTripId',
          feature: 'trip',
          type: OperationType.create,
          data: {
            'action': 'create_trip',
            'tripData': tripData,
            if (trip.media != null) 'imagePaths': [trip.media],
          },
        );

        print('✅ [TripRepository] Trip queued and cached locally');
        return const Right(true);
      } catch (e) {
        print('❌ [TripRepository] Failed to queue trip: $e');
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTrip(String tripId) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      try {
        await _operationsQueue.queueOperation(
          id: 'trip_delete_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'trip',
          type: OperationType.delete,
          data: {'action': 'delete_trip', 'tripId': tripId},
        );
        await _tripLocalDataSource.deleteTrip(tripId);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      // Delete from remote
      await _tripRemoteDataSource.deleteTrip(tripId);

      // Delete from local cache
      try {
        await _tripLocalDataSource.deleteTrip(tripId);
      } catch (e) {
        // Don't fail if local delete fails
        log('Failed to delete from local cache: $e');
      }

      return const Right(true);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getAllTrips() async {
    // Check network connectivity first
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      // Online: try remote first
      try {
        final response = await _tripRemoteDataSource.getAllTrips(limit: 200);
        log('getAllTrips: Received ${response.data.length} trips from API');
        final entities = response.data
            .map((model) => model.toEntity())
            .toList();

        // Sync server time from API response
        try {
          if (response.data.isNotEmpty) {
            final serverTimestamp = response.data
                .map((model) => model.updatedAt ?? model.createdAt)
                .whereType<DateTime>()
                .fold<DateTime?>(
                  null,
                  (prev, current) =>
                      prev == null || current.isAfter(prev) ? current : prev,
                );

            if (serverTimestamp != null) {
              _serverTimeService.syncWithServerTime(serverTimestamp);
            }
          }
        } catch (e) {
          log('Failed to sync server time: $e');
        }

        log(
          'getAllTrips: Converted to entities: ${entities.map((e) => {"name": e.tripName, "budget": e.budget, "members": e.groupSizeMax, "rating": e.averageRating}).toList()}',
        );

        // Update local cache in background
        _updateLocalCache(entities);

        return Right(entities);
      } on ServerException catch (e) {
        // Remote failed, try cache fallback
        print('⚠️ [TripRepo] Remote failed, trying cache...');
        try {
          final models = await _tripLocalDataSource.getAllTrips();
          final entities = models.map((model) => model.toEntity()).toList();
          print('✅ [TripRepo] Using cached trips (${entities.length})');
          return Right(entities);
        } catch (localError) {
          return Left(ApiFailure(message: e.message));
        }
      } catch (e) {
        // Try cache fallback for any error
        print('⚠️ [TripRepo] Error: $e, trying cache...');
        try {
          final models = await _tripLocalDataSource.getAllTrips();
          final entities = models.map((model) => model.toEntity()).toList();
          return Right(entities);
        } catch (localError) {
          return Left(ApiFailure(message: e.toString()));
        }
      }
    } else {
      // Offline: use cache directly
      print('📵 [TripRepo] Offline, using cached trips');
      try {
        final models = await _tripLocalDataSource.getAllTrips();
        final entities = models.map((model) => model.toEntity()).toList();
        print('✅ [TripRepo] Loaded ${entities.length} trips from cache');
        return Right(entities);
      } catch (e) {
        return Left(
          NetworkFailure(message: 'No internet connection and no cached data'),
        );
      }
    }
  }

  @override
  Future<Either<Failure, TripEntity>> getTripById(String tripId) async {
    // Check network connectivity first
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      // Online: try remote first
      try {
        final apiModel = await _tripRemoteDataSource.getTripById(tripId);
        final entity = apiModel.toEntity();

        // Sync server time from API response
        final serverTimestamp = apiModel.updatedAt ?? apiModel.createdAt;
        if (serverTimestamp != null) {
          _serverTimeService.syncWithServerTime(serverTimestamp);
        }

        // Update local cache
        try {
          final localModel = TripHiveModel.fromEntity(entity);
          await _tripLocalDataSource.updateTrip(localModel);
        } catch (e) {
          log('Failed to update local cache: $e');
        }

        return Right(entity);
      } on ServerException catch (e) {
        // Remote failed, try cache fallback
        print('⚠️ [TripRepo] Remote failed, trying cache for trip: $tripId');
        try {
          final model = await _tripLocalDataSource.getTripById(tripId);
          if (model != null) {
            print('✅ [TripRepo] Using cached trip');
            return Right(model.toEntity());
          }
          return Left(ApiFailure(message: e.message));
        } catch (localError) {
          return Left(ApiFailure(message: e.message));
        }
      } catch (e) {
        // Try cache fallback for any error
        print('⚠️ [TripRepo] Error: $e, trying cache for trip: $tripId');
        try {
          final model = await _tripLocalDataSource.getTripById(tripId);
          if (model != null) {
            return Right(model.toEntity());
          }
          return Left(ApiFailure(message: e.toString()));
        } catch (localError) {
          return Left(ApiFailure(message: e.toString()));
        }
      }
    } else {
      // Offline: use cache directly
      print('📵 [TripRepo] Offline, using cached trip: $tripId');
      try {
        final model = await _tripLocalDataSource.getTripById(tripId);
        if (model != null) {
          return Right(model.toEntity());
        }
        return Left(
          NetworkFailure(message: 'No internet connection and trip not cached'),
        );
      } catch (e) {
        return Left(
          NetworkFailure(message: 'No internet connection and no cached data'),
        );
      }
    }
  }

  @override
  Future<Either<Failure, bool>> updateTrip(TripEntity trip) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      try {
        if (trip.tripId == null) {
          return const Left(ApiFailure(message: 'Trip ID is required'));
        }

        final tripData = {
          'tripName': trip.tripName,
          'destination': trip.destination,
          'startDate': trip.startDate.toIso8601String(),
          'endDate': trip.endDate.toIso8601String(),
          if (trip.description != null) 'description': trip.description,
          if (trip.category != null) 'category': trip.category,
          if (trip.media != null) 'media': trip.media,
          if (trip.mediaType != null) 'mediaType': trip.mediaType,
          'status': _mapStatusForApi(trip.status),
          if (trip.budget != null) 'budget': trip.budget,
          'travelType': _mapTravelTypeForApi(trip.travelType),
          'groupSize': _resolveGroupSize(trip),
        };

        await _operationsQueue.queueOperation(
          id: 'trip_update_${trip.tripId}_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'trip',
          type: OperationType.update,
          data: {
            'action': 'update_trip',
            'tripId': trip.tripId,
            'tripData': tripData,
            if (trip.media != null) 'imagePaths': [trip.media],
          },
        );

        final localModel = TripHiveModel.fromEntity(trip);
        await _tripLocalDataSource.updateTrip(localModel);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      if (trip.tripId == null) {
        return const Left(ApiFailure(message: 'Trip ID is required'));
      }

      // Convert entity to JSON for API
      final tripData = {
        'tripName': trip.tripName,
        'destination': trip.destination,
        'startDate': trip.startDate.toIso8601String(),
        'endDate': trip.endDate.toIso8601String(),
        if (trip.description != null) 'description': trip.description,
        if (trip.category != null) 'category': trip.category,
        if (trip.media != null) 'media': trip.media,
        if (trip.mediaType != null) 'mediaType': trip.mediaType,
        'status': _mapStatusForApi(trip.status),
        // Required backend fields
        if (trip.budget != null) 'budget': trip.budget,
        'travelType': _mapTravelTypeForApi(trip.travelType),
        'groupSize': _resolveGroupSize(trip),
      };

      // Call remote API with image upload if media is provided
      final apiModel = await _tripRemoteDataSource.updateTrip(
        tripId: trip.tripId!,
        tripData: tripData,
        imagePaths: trip.media != null ? [trip.media!] : null,
      );

      // Update local cache
      try {
        final localModel = TripHiveModel.fromEntity(apiModel.toEntity());
        await _tripLocalDataSource.updateTrip(localModel);
      } catch (e) {
        log('Failed to update local cache: $e');
      }

      return const Right(true);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getTripsByUser(
    String userId,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await _tripRemoteDataSource.getTripsByCreator(
          userId: userId,
          limit: 50,
        );
        final entities = response.data
            .map((model) => model.toEntity())
            .toList();

        if (response.data.isNotEmpty) {
          final serverTimestamp = response.data
              .map((model) => model.updatedAt ?? model.createdAt)
              .whereType<DateTime>()
              .fold<DateTime?>(
                null,
                (prev, current) =>
                    prev == null || current.isAfter(prev) ? current : prev,
              );

          if (serverTimestamp != null) {
            _serverTimeService.syncWithServerTime(serverTimestamp);
          }
        }

        _updateLocalCache(entities);
        return Right(entities);
      } on ServerException catch (e) {
        final fallback = await _getCachedTripsByUser(userId);
        return fallback ?? Left(ApiFailure(message: e.message));
      } catch (e) {
        final fallback = await _getCachedTripsByUser(userId);
        return fallback ?? Left(ApiFailure(message: e.toString()));
      }
    }

    final fallback = await _getCachedTripsByUser(userId);
    return fallback ??
        const Left(
          NetworkFailure(message: 'No internet connection and no cached trips'),
        );
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getJoinedTrips(
    String userId,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await _tripRemoteDataSource.getJoinedTrips(
          userId: userId,
          limit: 50,
        );
        final entities = response.data
            .map((model) => model.toEntity())
            .toList();

        if (response.data.isNotEmpty) {
          final serverTimestamp = response.data
              .map((model) => model.updatedAt ?? model.createdAt)
              .whereType<DateTime>()
              .fold<DateTime?>(
                null,
                (prev, current) =>
                    prev == null || current.isAfter(prev) ? current : prev,
              );

          if (serverTimestamp != null) {
            _serverTimeService.syncWithServerTime(serverTimestamp);
          }
        }

        _updateLocalCache(entities);
        return Right(entities);
      } on ServerException catch (e) {
        final fallback = await _getCachedJoinedTrips(userId);
        return fallback ?? Left(ApiFailure(message: e.message));
      } catch (e) {
        final fallback = await _getCachedJoinedTrips(userId);
        return fallback ?? Left(ApiFailure(message: e.toString()));
      }
    }

    final fallback = await _getCachedJoinedTrips(userId);
    return fallback ??
        const Left(
          NetworkFailure(message: 'No internet connection and no cached trips'),
        );
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getPlannedTrips() async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await _tripRemoteDataSource.searchTrips(limit: 50);
        final entities = response.data
            .where((model) => model.status == 'planned')
            .map((model) => model.toEntity())
            .toList();

        if (response.data.isNotEmpty) {
          final serverTimestamp = response.data
              .map((model) => model.updatedAt ?? model.createdAt)
              .whereType<DateTime>()
              .fold<DateTime?>(
                null,
                (prev, current) =>
                    prev == null || current.isAfter(prev) ? current : prev,
              );

          if (serverTimestamp != null) {
            _serverTimeService.syncWithServerTime(serverTimestamp);
          }
        }

        _updateLocalCache(entities);
        return Right(entities);
      } on ServerException catch (e) {
        final fallback = await _getCachedTripsByStatus(TripStatus.planned);
        return fallback ?? Left(ApiFailure(message: e.message));
      } catch (e) {
        final fallback = await _getCachedTripsByStatus(TripStatus.planned);
        return fallback ?? Left(ApiFailure(message: e.toString()));
      }
    }

    final fallback = await _getCachedTripsByStatus(TripStatus.planned);
    return fallback ??
        const Left(
          NetworkFailure(message: 'No internet connection and no cached trips'),
        );
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getCompletedTrips() async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await _tripRemoteDataSource.searchTrips(limit: 50);
        final entities = response.data
            .where((model) => model.status == 'completed')
            .map((model) => model.toEntity())
            .toList();

        _updateLocalCache(entities);
        return Right(entities);
      } on ServerException catch (e) {
        final fallback = await _getCachedTripsByStatus(TripStatus.completed);
        return fallback ?? Left(ApiFailure(message: e.message));
      } catch (e) {
        final fallback = await _getCachedTripsByStatus(TripStatus.completed);
        return fallback ?? Left(ApiFailure(message: e.toString()));
      }
    }

    final fallback = await _getCachedTripsByStatus(TripStatus.completed);
    return fallback ??
        const Left(
          NetworkFailure(message: 'No internet connection and no cached trips'),
        );
  }

  @override
  Future<Either<Failure, List<TripEntity>>> getTripsByCategory(
    String categoryId,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await _tripRemoteDataSource.getAllTrips(limit: 200);
        final entities = response.data
            .where((model) => model.category == categoryId)
            .map((model) => model.toEntity())
            .toList();

        _updateLocalCache(entities);
        return Right(entities);
      } on ServerException catch (e) {
        final fallback = await _getCachedTripsByCategory(categoryId);
        return fallback ?? Left(ApiFailure(message: e.message));
      } catch (e) {
        final fallback = await _getCachedTripsByCategory(categoryId);
        return fallback ?? Left(ApiFailure(message: e.toString()));
      }
    }

    final fallback = await _getCachedTripsByCategory(categoryId);
    return fallback ??
        const Left(
          NetworkFailure(message: 'No internet connection and no cached trips'),
        );
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(photo) async {
    // Photo upload is handled directly in createTrip/updateTrip
    // Return the local path for now
    return Right(photo.path);
  }

  @override
  Future<Either<Failure, String>> uploadVideo(video) async {
    // Video upload is handled directly in createTrip/updateTrip
    // Return the local path for now
    return Right(video.path);
  }

  @override
  Future<Either<Failure, bool>> sendJoinRequest({
    required String tripId,
    required String userId,
    String? message,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      try {
        await _operationsQueue.queueOperation(
          id: 'trip_join_${tripId}_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'trip',
          type: OperationType.create,
          data: {
            'action': 'join_request',
            'tripId': tripId,
            'userId': userId,
            if (message != null && message.isNotEmpty) 'message': message,
          },
        );
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      await _tripRemoteDataSource.sendJoinRequest(
        tripId: tripId,
        userId: userId,
        message: message,
      );
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<TripEntity>>?> _getCachedTripsByUser(
    String userId,
  ) async {
    try {
      final models = await _tripLocalDataSource.getMyTrips(userId);
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (_) {
      return null;
    }
  }

  Future<Either<Failure, List<TripEntity>>?> _getCachedJoinedTrips(
    String userId,
  ) async {
    try {
      final models = await _tripLocalDataSource.getAllTrips();
      final entities = models.map((model) => model.toEntity()).toList();

      final joinedFromMembers = entities
          .where(
            (trip) =>
                trip.members?.any((member) => member.userId == userId) ?? false,
          )
          .toList();
      if (joinedFromMembers.isNotEmpty) {
        return Right(joinedFromMembers);
      }

      // Fallback approximation for legacy cached trips without members data.
      return Right(entities.where((trip) => trip.createdBy != userId).toList());
    } catch (_) {
      return null;
    }
  }

  Future<Either<Failure, List<TripEntity>>?> _getCachedTripsByStatus(
    TripStatus status,
  ) async {
    try {
      final models = await _tripLocalDataSource.getAllTrips();
      final entities = models
          .map((model) => model.toEntity())
          .where((trip) => trip.status == status)
          .toList();
      return Right(entities);
    } catch (_) {
      return null;
    }
  }

  Future<Either<Failure, List<TripEntity>>?> _getCachedTripsByCategory(
    String categoryId,
  ) async {
    try {
      final models = await _tripLocalDataSource.getAllTrips();
      final entities = models
          .map((model) => model.toEntity())
          .where((trip) => trip.category == categoryId)
          .toList();
      return Right(entities);
    } catch (_) {
      return null;
    }
  }

  /// Helper method to update local cache in background
  Future<void> _updateLocalCache(List<TripEntity> entities) async {
    try {
      for (final entity in entities) {
        final localModel = TripHiveModel.fromEntity(entity);
        // Check if exists, then update or create
        final existing = await _tripLocalDataSource.getTripById(
          entity.tripId ?? '',
        );
        if (existing != null) {
          await _tripLocalDataSource.updateTrip(localModel);
        } else {
          await _tripLocalDataSource.createTrip(localModel);
        }
      }
    } catch (e) {
      log('Failed to update local cache: $e');
    }
  }

  @override
  Future<Either<Failure, List<ItineraryItemEntity>>> getItinerary(
    String tripId,
  ) async {
    try {
      final itineraryData = await _tripRemoteDataSource.getItinerary(tripId);

      final itineraryList = itineraryData.map((item) {
        return ItineraryItemEntity(
          id: item['_id'] as String? ?? item['id'] as String? ?? '',
          day: item['day'] as int? ?? 1,
          date: DateTime.parse(item['date'] as String),
          title: item['title'] as String,
          description: item['description'] as String?,
          location: item['location'] as String?,
          activities: item['activities'] != null
              ? List<String>.from(item['activities'] as List)
              : null,
          elevation: item['elevation'] != null
              ? (item['elevation'] as num).toDouble()
              : null,
          startTime: item['startTime'] != null
              ? DateTime.parse(item['startTime'] as String)
              : null,
          endTime: item['endTime'] != null
              ? DateTime.parse(item['endTime'] as String)
              : null,
          notes: item['notes'] as String?,
          isCompleted: item['isCompleted'] as bool? ?? false,
        );
      }).toList();

      return Right(itineraryList);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      log('getItinerary: Unexpected error - $e');
      return Left(ApiFailure(message: 'Failed to load itinerary'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateItinerary({
    required String tripId,
    required List<Map<String, dynamic>> itinerary,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      try {
        await _operationsQueue.queueOperation(
          id: 'trip_itinerary_${tripId}_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'trip',
          type: OperationType.update,
          data: {
            'action': 'update_itinerary',
            'tripId': tripId,
            'itinerary': itinerary,
          },
        );
        return const Right(true);
      } catch (e) {
        return Left(
          ApiFailure(message: 'Failed to queue itinerary update: $e'),
        );
      }
    }

    try {
      await _tripRemoteDataSource.updateItinerary(
        tripId: tripId,
        itinerary: itinerary,
      );
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      log('updateItinerary: Unexpected error - $e');
      return Left(ApiFailure(message: 'Failed to update itinerary'));
    }
  }

  @override
  Future<Either<Failure, List<ChecklistItemEntity>>> getChecklist(
    String tripId,
  ) async {
    try {
      log('getChecklist: Fetching checklist for trip $tripId');
      final checklistData = await _tripRemoteDataSource.getChecklist(tripId);

      final checklist = checklistData.map((item) {
        // Parse category from string
        ChecklistCategory category = ChecklistCategory.preparation;
        if (item['category'] != null) {
          try {
            category = ChecklistCategory.values.firstWhere(
              (e) => e.name == item['category'],
              orElse: () => ChecklistCategory.preparation,
            );
          } catch (e) {
            category = ChecklistCategory.preparation;
          }
        }

        // Parse priority from string
        ChecklistPriority? priority;
        if (item['priority'] != null) {
          try {
            priority = ChecklistPriority.values.firstWhere(
              (e) => e.name == item['priority'],
            );
          } catch (e) {
            priority = null;
          }
        }

        return ChecklistItemEntity(
          id: item['_id'] as String? ?? item['id'] as String? ?? '',
          category: category,
          title: item['title'] as String? ?? '',
          isCompleted: item['isCompleted'] as bool? ?? false,
          priority: priority,
          completedAt: item['completedAt'] != null
              ? DateTime.tryParse(item['completedAt'] as String)
              : null,
          completedBy: item['completedBy'] as String?,
          createdAt: item['createdAt'] != null
              ? DateTime.tryParse(item['createdAt'] as String)
              : null,
        );
      }).toList();

      log('getChecklist: Successfully fetched ${checklist.length} items');
      return Right(checklist);
    } on ServerException catch (e) {
      log('getChecklist: Server error - ${e.message}');
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      log('getChecklist: Unexpected error - $e');
      return Left(ApiFailure(message: 'Failed to load checklist'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateChecklist({
    required String tripId,
    required List<Map<String, dynamic>> checklist,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      try {
        await _operationsQueue.queueOperation(
          id: 'trip_checklist_${tripId}_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'trip',
          type: OperationType.update,
          data: {
            'action': 'update_checklist',
            'tripId': tripId,
            'checklist': checklist,
          },
        );
        return const Right(true);
      } catch (e) {
        return Left(
          ApiFailure(message: 'Failed to queue checklist update: $e'),
        );
      }
    }

    try {
      await _tripRemoteDataSource.updateChecklist(
        tripId: tripId,
        checklist: checklist,
      );
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ApiFailure(message: e.message));
    } catch (e) {
      log('updateChecklist: Unexpected error - $e');
      return Left(ApiFailure(message: 'Failed to update checklist'));
    }
  }
}
