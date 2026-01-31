import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/api/api_client.dart';
import 'package:tripmates/core/api/api_endpoints.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/features/profile/data/models/profile_api_model.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(apiClient: ref.read(apiClientProvider));
});

class ProfileRepository implements IProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String userId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.userProfile}/$userId',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final profile = ProfileApiModel.fromJson(data);
        return Right(profile.toEntity());
      }

      return Left(
        ApiFailure(
          message: response.data['message'] ?? 'Failed to get profile',
        ),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to get profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
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
      // Create form data for multipart request
      final formData = FormData.fromMap({
        if (profile.fullName.isNotEmpty) 'fullName': profile.fullName,
        if (profile.phone != null && profile.phone!.isNotEmpty)
          'phoneNumber': profile.phone,
        if (profile.bio != null && profile.bio!.isNotEmpty) 'bio': profile.bio,
        if (profile.location != null && profile.location!.isNotEmpty)
          'location': profile.location,
      });

      final response = await _apiClient.put(
        '${ApiEndpoints.updateProfile}/${profile.userId}',
        data: formData,
      );

      if (response.data['success'] == true) {
        return const Right(true);
      }

      return Left(
        ApiFailure(
          message: response.data['message'] ?? 'Failed to update profile',
        ),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to update profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccount(String userId) async {
    // TODO: Implement when backend endpoint is available
    return Left(ApiFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(
    File photo,
    String userId,
  ) async {
    try {
      if (userId.isEmpty) {
        return Left(
          ApiFailure(message: 'User id is required to upload profile image'),
        );
      }

      final fileName = photo.path.split('/').last;
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          photo.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.put(
        '${ApiEndpoints.updateProfile}/$userId',
        data: formData,
      );

      // Ensure response data is a JSON map before indexing
      if (response.data is Map && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final profileImagePath = data['profileImagePath'] as String?;

        if (profileImagePath != null && profileImagePath.isNotEmpty) {
          // Resolve the full URL
          if (profileImagePath.startsWith('http')) {
            return Right(profileImagePath);
          }
          final cleaned = profileImagePath.startsWith('/')
              ? profileImagePath.substring(1)
              : profileImagePath;
          return Right('${ApiEndpoints.baseOrigin}/$cleaned');
        }

        return Left(ApiFailure(message: 'No profile image path returned'));
      }

      return Left(
        ApiFailure(
          message: response.data['message'] ?? 'Failed to upload image',
        ),
      );
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to upload image',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
