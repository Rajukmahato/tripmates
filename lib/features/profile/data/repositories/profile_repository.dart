import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/services/connectivity/network_info.dart';
import 'package:tripmates/core/services/offline/offline_operations_queue.dart';
import 'package:tripmates/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:tripmates/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/profile/domain/repositories/profile_repository.dart';

final profileLocalDataSourceProvider = Provider<IProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource();
});

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
    localDataSource: ref.read(profileLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    operationsQueue: ref.read(offlineOperationsQueueProvider),
  );
});

class ProfileRepository implements IProfileRepository {
  final IProfileRemoteDataSource _remoteDataSource;
  final IProfileLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final OfflineOperationsQueue _operationsQueue;

  ProfileRepository({
    required IProfileRemoteDataSource remoteDataSource,
    required IProfileLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required OfflineOperationsQueue operationsQueue,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _operationsQueue = operationsQueue;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String userId) async {
    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      // Try to fetch from remote
      final remoteResult = await _remoteDataSource.getProfile(userId);

      return remoteResult.fold(
        (failure) async {
          // Remote failed, fallback to cache
          print('⚠️ [ProfileRepo] Remote failed, trying cache...');
          final cachedProfile = await _localDataSource.getCachedProfile(userId);
          if (cachedProfile != null) {
            print('✅ [ProfileRepo] Using cached profile');
            return Right(cachedProfile);
          }
          return Left(failure);
        },
        (profile) async {
          // Remote succeeded, cache it
          await _localDataSource.cacheProfile(profile);
          return Right(profile);
        },
      );
    } else {
      // Offline, use cache only
      print('📵 [ProfileRepo] Offline, using cache for profile');
      final cachedProfile = await _localDataSource.getCachedProfile(userId);
      if (cachedProfile != null) {
        return Right(cachedProfile);
      }
      return Left(
        NetworkFailure(message: 'No internet connection and no cached data'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> updateProfile(ProfileEntity profile) async {
    try {
      if (profile.userId == null || profile.userId!.isEmpty) {
        return Left(
          ApiFailure(message: 'User id is required to update profile'),
        );
      }

      // Check network connectivity
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        // Online: update remote and cache
        final remoteResult = await _remoteDataSource.updateProfile(profile);

        return remoteResult.fold((failure) => Left(failure), (success) async {
          // Update succeeded, cache the updated profile
          await _localDataSource.cacheProfile(profile);
          return const Right(true);
        });
      } else {
        // Offline: queue operation and cache locally
        print('📵 [ProfileRepo] Offline, queueing profile update');

        await _operationsQueue.queueOperation(
          id: 'profile_update_${profile.userId}_${DateTime.now().millisecondsSinceEpoch}',
          feature: 'profile',
          type: OperationType.update,
          data: {
            'userId': profile.userId,
            'fullName': profile.fullName,
            'email': profile.email,
            'phone': profile.phone,
            'bio': profile.bio,
            'location': profile.location,
            'profilePicture': profile.profilePicture,
          },
        );

        // Update local cache
        await _localDataSource.cacheProfile(profile);

        print('✅ [ProfileRepo] Profile update queued and cached locally');
        return const Right(true);
      }
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccount(String userId) async {
    // Account deletion is not implemented in the backend yet for safety reasons.
    // This feature requires:
    // 1. Backend endpoint: DELETE /api/users/:userId
    // 2. Proper authentication and authorization checks
    // 3. Data cascade deletion or anonymization strategy
    // 4. User confirmation flow in the UI
    //
    // When implementing, ensure:
    // - User must be authenticated and can only delete their own account
    // - All user data (trips, reviews, messages) must be handled appropriately
    // - Consider GDPR compliance for data deletion
    return const Left(
      ApiFailure(
        message:
            'Account deletion is not available at this time. '
            'Please contact support for assistance.',
      ),
    );
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(
    File photo,
    String userId,
  ) async {
    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;

    if (!isConnected) {
      return Left(
        NetworkFailure(message: 'Cannot upload profile picture while offline'),
      );
    }

    // Delegate to remote data source
    return await _remoteDataSource.uploadProfilePicture(photo, userId);
  }
}
