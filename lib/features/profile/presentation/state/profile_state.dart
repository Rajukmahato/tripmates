import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, loaded, updating, success, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;
  final bool isUpdating;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.isUpdating = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
    bool? isUpdating,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, isUpdating];
}
