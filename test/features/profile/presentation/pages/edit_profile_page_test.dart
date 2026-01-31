import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripmates/core/services/storage/user_session_service.dart';
import 'package:tripmates/features/profile/domain/entities/profile_entity.dart';
import 'package:tripmates/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:tripmates/features/profile/presentation/state/profile_state.dart';
import 'package:tripmates/features/profile/presentation/view_model/profile_viewmodel.dart';

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // Return empty 1x1 PNG for image assets
    if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
      // Minimal valid PNG (1x1 transparent pixel)
      final List<int> pngBytes = [
        137, 80, 78, 71, 13, 10, 26, 10, // PNG signature
        0, 0, 0, 13, 73, 72, 68, 82, // IHDR chunk
        0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, // 1x1 RGBA
        31, 21, 196, 137, // IHDR CRC
        0, 0, 0, 10, 73, 68, 65, 84, // IDAT chunk
        8, 215, 99, 248, 15, 0, 0, 1, 0, 1, // compressed data
        91, 3, 12, 45, // IDAT CRC
        0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130, // IEND chunk
      ];
      return ByteData.view(Uint8List.fromList(pngBytes).buffer);
    }

    // Return properly encoded empty manifest for AssetManifest.bin
    if (key == 'AssetManifest.bin') {
      const codec = StandardMessageCodec();
      final encoded = codec.encodeMessage(<String, Object>{})!;
      return encoded;
    }

    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    // Return empty JSON for AssetManifest.json
    if (key == 'AssetManifest.json') {
      return '{}';
    }
    return '';
  }
}

class _TestProfileViewModel extends ProfileViewModel {
  @override
  ProfileState build() => const ProfileState();

  @override
  Future<void> getProfile(String userId) async {}

  @override
  Future<void> updateProfile(ProfileEntity profile) async {}

  @override
  Future<void> uploadProfilePicture(File photo) async {}
}

void main() {
  testWidgets('edit profile page renders basic UI', (tester) async {
    // Arrange
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          profileViewModelProvider.overrideWith(_TestProfileViewModel.new),
        ],
        child: DefaultAssetBundle(
          bundle: _TestAssetBundle(),
          child: const MaterialApp(home: EditProfilePage()),
        ),
      ),
    );

    // Act
    await tester.pump();

    // Assert
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
