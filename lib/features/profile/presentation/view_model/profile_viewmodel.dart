import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';
import '../state/profile_state.dart';
import '../../../../core/services/storage/user_session_service.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final UserSessionService _userSessionService;
  late final GetProfileUsecase _getProfileUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final UploadProfilePictureUsecase _uploadProfilePictureUsecase;

  @override
  ProfileState build() {
    _userSessionService = ref.read(userSessionServiceProvider);
    _getProfileUsecase = ref.read(getProfileUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _uploadProfilePictureUsecase = ref.read(
      uploadProfilePictureUsecaseProvider,
    );
    return const ProfileState();
  }

  Future<void> getProfile(String userId) async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _getProfileUsecase(GetProfileParams(userId: userId));

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) {
        // Update local session storage
        _userSessionService.saveUserSession(
          userId: profile.userId ?? '',
          email: profile.email,
          fullName: profile.fullName,
          username: _userSessionService.getCurrentUserUsername() ?? '',
          phoneNumber: profile.phone,
          profilePicture: profile.profilePicture,
        );

        state = state.copyWith(status: ProfileStatus.loaded, profile: profile);
      },
    );
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    state = state.copyWith(status: ProfileStatus.updating, isUpdating: true);

    final result = await _updateProfileUsecase(
      UpdateProfileParams(profile: profile),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
        isUpdating: false,
      ),
      (success) async {
        // Update local session storage
        await _userSessionService.saveUserSession(
          userId: profile.userId ?? '',
          email: profile.email,
          fullName: profile.fullName,
          username: _userSessionService.getCurrentUserUsername() ?? '',
          phoneNumber: profile.phone,
          profilePicture: profile.profilePicture,
        );

        state = state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
          isUpdating: false,
        );
      },
    );
  }

  Future<void> uploadProfilePicture(File photo) async {
    final userId = _userSessionService.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Unable to find current user id',
      );
      return;
    }

    final result = await _uploadProfilePictureUsecase(
      UploadProfilePictureParams(photo: photo, userId: userId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ),
      (imageUrl) {
        // Update profile with new image URL
        final currentProfile = state.profile;
        if (currentProfile != null) {
          final updatedProfile = ProfileEntity(
            userId: currentProfile.userId,
            fullName: currentProfile.fullName,
            email: currentProfile.email,
            phone: currentProfile.phone,
            profilePicture: imageUrl,
            bio: currentProfile.bio,
            location: currentProfile.location,
            totalTrips: currentProfile.totalTrips,
            completedTrips: currentProfile.completedTrips,
            createdAt: currentProfile.createdAt,
            updatedAt: currentProfile.updatedAt,
          );

          state = state.copyWith(profile: updatedProfile);
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(status: ProfileStatus.loaded, errorMessage: null);
  }
}
