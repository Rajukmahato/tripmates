import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tripmates/core/constants/hive_table_constant.dart';
import 'package:tripmates/features/auth/data/models/auth_hive_model.dart';
import 'package:tripmates/features/category/data/models/category_hive_model.dart';
import 'package:tripmates/features/trip/data/models/trip_hive_model.dart';
import 'package:tripmates/features/destination/data/models/destination_hive_model.dart';
import 'package:tripmates/features/profile/data/models/profile_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    // register adapter
    _registerAdapter();
    await _openBoxes();
    // insert dummy data
    await insertCategoryDummyData();
  }

  Future<void> insertCategoryDummyData() async {
    final categoryBox = Hive.box<CategoryHiveModel>(
      HiveTableConstant.categoryBoxName,
    );

    if (categoryBox.isNotEmpty) {
      return;
    }

    final dummyCategories = [
      CategoryHiveModel(
        categoryName: 'Mountains',
        description: 'Mountain treks and hill stations',
        icon: '⛰️',
        type: 'mountains',
      ),
      CategoryHiveModel(
        categoryName: 'City Tour',
        description: 'Urban exploration and city sightseeing',
        icon: '🏙️',
        type: 'cityTour',
      ),
      CategoryHiveModel(
        categoryName: 'Adventure',
        description: 'Thrilling adventures and extreme sports',
        icon: '🎢',
        type: 'adventure',
      ),
      CategoryHiveModel(
        categoryName: 'Religious',
        description: 'Pilgrimage and spiritual journeys',
        icon: '🕉️',
        type: 'religious',
      ),
      CategoryHiveModel(
        categoryName: 'Road Trip',
        description: 'Long drives and road adventures',
        icon: '🚗',
        type: 'roadTrip',
      ),
      CategoryHiveModel(
        categoryName: 'Nature',
        description: 'Wildlife and natural wonders',
        icon: '🌿',
        type: 'nature',
      ),
      CategoryHiveModel(
        categoryName: 'Beach',
        description: 'Coastal and beach destinations',
        icon: '🏖️',
        type: 'beach',
      ),
      CategoryHiveModel(
        categoryName: 'Cultural',
        description: 'Cultural heritage and historical sites',
        icon: '🏛️',
        type: 'cultural',
      ),
    ];

    for (var category in dummyCategories) {
      await categoryBox.put(category.categoryId, category);
    }
  }

  // Adapter register
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.tripTypeId)) {
      Hive.registerAdapter(TripHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.destinationTypeId)) {
      Hive.registerAdapter(DestinationHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.categoryTypeId)) {
      Hive.registerAdapter(CategoryHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.profileTypeId)) {
      Hive.registerAdapter(ProfileHiveModelAdapter());
    }
  }

  // box open
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authBoxName);
    await Hive.openBox<TripHiveModel>(HiveTableConstant.tripBoxName);
    await Hive.openBox<DestinationHiveModel>(
      HiveTableConstant.destinationBoxName,
    );
    await Hive.openBox<CategoryHiveModel>(HiveTableConstant.categoryBoxName);
    await Hive.openBox<ProfileHiveModel>(HiveTableConstant.profileBoxName);
    await Hive.openBox(HiveTableConstant.userBoxName);
  }

  // box close
  Future<void> _close() async {
    await Hive.close();
  }

  // ======================= Auth Queries =========================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authBoxName);

  // Register user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.authId, user);
    return user;
  }

  // Login - find user by email and password
  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  // ======================= Trip Queries =========================

  Box<TripHiveModel> get _tripBox =>
      Hive.box<TripHiveModel>(HiveTableConstant.tripBoxName);

  Future<TripHiveModel> createTrip(TripHiveModel trip) async {
    await _tripBox.put(trip.tripId, trip);
    return trip;
  }

  List<TripHiveModel> getAllTrips() {
    return _tripBox.values.toList();
  }

  TripHiveModel? getTripById(String tripId) {
    return _tripBox.get(tripId);
  }

  List<TripHiveModel> getTripsByUser(String userId) {
    return _tripBox.values.where((trip) => trip.createdBy == userId).toList();
  }

  List<TripHiveModel> getPlannedTrips() {
    return _tripBox.values.where((trip) => trip.status == 'planned').toList();
  }

  List<TripHiveModel> getCompletedTrips() {
    return _tripBox.values.where((trip) => trip.status == 'completed').toList();
  }

  List<TripHiveModel> getTripsByCategory(String categoryId) {
    return _tripBox.values
        .where((trip) => trip.category == categoryId)
        .toList();
  }

  Future<bool> updateTrip(TripHiveModel trip) async {
    if (_tripBox.containsKey(trip.tripId)) {
      await _tripBox.put(trip.tripId, trip);
      return true;
    }
    return false;
  }

  Future<void> deleteTrip(String tripId) async {
    await _tripBox.delete(tripId);
  }

  // ======================= Destination Queries =========================

  Box<DestinationHiveModel> get _destinationBox =>
      Hive.box<DestinationHiveModel>(HiveTableConstant.destinationBoxName);

  Future<DestinationHiveModel> createDestination(
    DestinationHiveModel destination,
  ) async {
    await _destinationBox.put(destination.destinationId, destination);
    return destination;
  }

  List<DestinationHiveModel> getAllDestinations() {
    return _destinationBox.values.toList();
  }

  DestinationHiveModel? getDestinationById(String destinationId) {
    return _destinationBox.get(destinationId);
  }

  List<DestinationHiveModel> getDestinationsByTrip(String tripId) {
    return _destinationBox.values
        .where((dest) => dest.tripId == tripId)
        .toList();
  }

  List<DestinationHiveModel> getDestinationsByUser(String userId) {
    return _destinationBox.values
        .where((dest) => dest.createdBy == userId)
        .toList();
  }

  List<DestinationHiveModel> getDestinationsByCategory(String categoryId) {
    return _destinationBox.values
        .where((dest) => dest.category == categoryId)
        .toList();
  }

  Future<bool> updateDestination(DestinationHiveModel destination) async {
    if (_destinationBox.containsKey(destination.destinationId)) {
      await _destinationBox.put(destination.destinationId, destination);
      return true;
    }
    return false;
  }

  Future<void> deleteDestination(String destinationId) async {
    await _destinationBox.delete(destinationId);
  }

  // ======================= Category Queries =========================

  Box<CategoryHiveModel> get _categoryBox =>
      Hive.box<CategoryHiveModel>(HiveTableConstant.categoryBoxName);

  Future<CategoryHiveModel> createCategory(CategoryHiveModel category) async {
    await _categoryBox.put(category.categoryId, category);
    return category;
  }

  List<CategoryHiveModel> getAllCategories() {
    return _categoryBox.values.toList();
  }

  CategoryHiveModel? getCategoryById(String categoryId) {
    return _categoryBox.get(categoryId);
  }

  Future<bool> updateCategory(CategoryHiveModel category) async {
    if (_categoryBox.containsKey(category.categoryId)) {
      await _categoryBox.put(category.categoryId, category);
      return true;
    }
    return false;
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryBox.delete(categoryId);
  }
}
