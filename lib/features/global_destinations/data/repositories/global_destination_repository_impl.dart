import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/exceptions.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart'
    as network;
import 'package:tripmates/core/providers/app_providers.dart';
import 'package:tripmates/features/global_destinations/data/datasources/global_destination_remote_datasource.dart';
import 'package:tripmates/features/global_destinations/domain/entities/global_destination_entity.dart';
import 'package:tripmates/features/global_destinations/domain/repositories/global_destination_repository.dart';

/// Provider for global destination repository
final globalDestinationRepositoryProvider =
    Provider<IGlobalDestinationRepository>((ref) {
      final remoteDataSource = ref.read(
        globalDestinationRemoteDataSourceProvider,
      );
      final networkInfo = ref.read(networkInfoProvider);
      return GlobalDestinationRepository(
        remoteDataSource: remoteDataSource,
        networkInfo: networkInfo,
      );
    });

/// Repository implementation for global destinations
class GlobalDestinationRepository implements IGlobalDestinationRepository {
  final IGlobalDestinationRemoteDataSource _remoteDataSource;
  final network.NetworkInfo _networkInfo;

  // In-memory cache for offline browsing during app session
  List<GlobalDestinationEntity>? _allDestinationsCache;
  final Map<String, List<GlobalDestinationEntity>> _searchCache = {};
  final Map<String, GlobalDestinationEntity> _destinationByIdCache = {};

  GlobalDestinationRepository({
    required IGlobalDestinationRemoteDataSource remoteDataSource,
    required network.NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<GlobalDestinationEntity>>> getAllDestinations({
    bool includeInactive = false,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final destinations = await _remoteDataSource.getAllDestinations(
          includeInactive: includeInactive,
        );
        final entities = destinations.map((model) => model.toEntity()).toList();

        // Cache for offline access
        _allDestinationsCache = entities;

        return Right(entities);
      } on ServerException catch (e) {
        // Fallback to cache if available
        if (_allDestinationsCache != null) {
          return Right(_allDestinationsCache!);
        }
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        // Fallback to cache if available
        if (_allDestinationsCache != null) {
          return Right(_allDestinationsCache!);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline: use cache if available
      if (_allDestinationsCache != null) {
        return Right(_allDestinationsCache!);
      }
      return const Left(
        NetworkFailure(
          message: 'No internet connection and no cached destinations',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<GlobalDestinationEntity>>> searchDestinations({
    required String query,
    bool includeInactive = false,
  }) async {
    final isConnected = await _networkInfo.isConnected;
    final cacheKey = '${query}_$includeInactive';

    if (isConnected) {
      try {
        final destinations = await _remoteDataSource.searchDestinations(
          query: query,
          includeInactive: includeInactive,
        );
        final entities = destinations.map((model) => model.toEntity()).toList();

        // Cache search results
        _searchCache[cacheKey] = entities;

        return Right(entities);
      } on ServerException catch (e) {
        // Fallback to cached search results
        if (_searchCache.containsKey(cacheKey)) {
          return Right(_searchCache[cacheKey]!);
        }
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        // Fallback to cached search results
        if (_searchCache.containsKey(cacheKey)) {
          return Right(_searchCache[cacheKey]!);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline: use cached search results if available
      if (_searchCache.containsKey(cacheKey)) {
        return Right(_searchCache[cacheKey]!);
      }
      return const Left(
        NetworkFailure(
          message: 'No internet connection and no cached search results',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, GlobalDestinationEntity>> getDestinationById(
    String id,
  ) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        final destination = await _remoteDataSource.getDestinationById(id);
        final entity = destination.toEntity();

        // Cache individual destination
        _destinationByIdCache[id] = entity;

        return Right(entity);
      } on ServerException catch (e) {
        // Fallback to cached destination
        if (_destinationByIdCache.containsKey(id)) {
          return Right(_destinationByIdCache[id]!);
        }
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        // Fallback to cached destination
        if (_destinationByIdCache.containsKey(id)) {
          return Right(_destinationByIdCache[id]!);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline: use cached destination if available
      if (_destinationByIdCache.containsKey(id)) {
        return Right(_destinationByIdCache[id]!);
      }
      return const Left(
        NetworkFailure(
          message: 'No internet connection and destination not cached',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, GlobalDestinationEntity>> createDestination(
    Map<String, dynamic> data,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final destination = await _remoteDataSource.createDestination(data);
        return Right(destination.toEntity());
      } on ServerException catch (e) {
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, GlobalDestinationEntity>> updateDestination(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final destination = await _remoteDataSource.updateDestination(id, data);
        return Right(destination.toEntity());
      } on ServerException catch (e) {
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDestination(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteDestination(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, GlobalDestinationEntity>> toggleDestinationStatus(
    String id,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final destination = await _remoteDataSource.toggleDestinationStatus(id);
        return Right(destination.toEntity());
      } on ServerException catch (e) {
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDestinationStats() async {
    if (await _networkInfo.isConnected) {
      try {
        final stats = await _remoteDataSource.getDestinationStats();
        return Right(stats);
      } on ServerException catch (e) {
        return Left(ApiFailure(message: e.message));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
