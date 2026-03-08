import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/profile/data/models/profile_hive_model.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';

abstract class IProfileLocalDataSource {
  Future<void> cacheProfile(ProfileEntity profile);
  Future<ProfileEntity?> getCachedProfile(String userId);
  Future<void> clearCache();
  Future<void> clearProfileCache(String userId);
}

class ProfileLocalDataSource implements IProfileLocalDataSource {
  final Box<ProfileHiveModel> _profileBox;

  ProfileLocalDataSource()
    : _profileBox = Hive.box<ProfileHiveModel>(
        HiveTableConstant.profileBoxName,
      );

  @override
  Future<void> cacheProfile(ProfileEntity profile) async {
    try {
      if (profile.userId == null || profile.userId!.isEmpty) {
        print('⚠️ [ProfileLocalDS] Cannot cache profile without userId');
        return;
      }

      final hiveModel = ProfileHiveModel.fromEntity(profile);
      await _profileBox.put(profile.userId, hiveModel);
      print('💾 [ProfileLocalDS] Cached profile: ${profile.userId}');
    } catch (e) {
      print('❌ [ProfileLocalDS] Error caching profile: $e');
      rethrow;
    }
  }

  @override
  Future<ProfileEntity?> getCachedProfile(String userId) async {
    try {
      final hiveModel = _profileBox.get(userId);
      if (hiveModel != null) {
        print('✅ [ProfileLocalDS] Found cached profile: $userId');
        return hiveModel.toEntity();
      }
      print('📂 [ProfileLocalDS] No cached profile found for: $userId');
      return null;
    } catch (e) {
      print('❌ [ProfileLocalDS] Error getting cached profile: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _profileBox.clear();
      print('🗑️ [ProfileLocalDS] Cleared all profile cache');
    } catch (e) {
      print('❌ [ProfileLocalDS] Error clearing cache: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearProfileCache(String userId) async {
    try {
      await _profileBox.delete(userId);
      print('🗑️ [ProfileLocalDS] Cleared profile cache for: $userId');
    } catch (e) {
      print('❌ [ProfileLocalDS] Error clearing profile cache: $e');
      rethrow;
    }
  }
}
