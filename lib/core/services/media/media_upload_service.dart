import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/core/error/failures.dart';
import 'package:tripmates/core/api/api_client.dart';

final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MediaUploadService(apiClient: apiClient);
});

class MediaUploadService {
  final ApiClient _apiClient;

  MediaUploadService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Upload a single image and return the URL
  Future<Either<Failure, String>> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        '/api/upload/image',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final imageUrl = response.data['url'] as String?;
        if (imageUrl != null) {
          return Right(imageUrl);
        } else {
          return Left(ApiFailure(message: 'No URL returned from server'));
        }
      } else {
        return Left(
          ApiFailure(message: 'Upload failed: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.message ?? 'Upload failed'));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  /// Upload multiple images and return list of URLs
  Future<Either<Failure, List<String>>> uploadImages(
    List<File> imageFiles,
  ) async {
    try {
      final List<String> uploadedUrls = [];

      for (final imageFile in imageFiles) {
        final result = await uploadImage(imageFile);

        result.fold(
          (failure) => throw Exception(failure.message),
          (url) => uploadedUrls.add(url),
        );
      }

      return Right(uploadedUrls);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to upload images: $e'));
    }
  }

  /// Upload image with progress callback
  Future<Either<Failure, String>> uploadImageWithProgress(
    File imageFile, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiClient.post(
        '/api/upload/image',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final imageUrl = response.data['url'] as String?;
        if (imageUrl != null) {
          return Right(imageUrl);
        } else {
          return Left(ApiFailure(message: 'No URL returned from server'));
        }
      } else {
        return Left(
          ApiFailure(message: 'Upload failed: ${response.statusMessage}'),
        );
      }
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.message ?? 'Upload failed'));
    } catch (e) {
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }
}
