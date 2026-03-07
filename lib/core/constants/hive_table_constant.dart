class HiveTableConstant {
  // Private constructor
  HiveTableConstant._();

  // Database name
  static const String dbName = "tripmates_db";

  // Tables -> Box : Index & Names
  static const int authTypeId = 0;
  static const String authBoxName = 'auth_box';

  static const int tripTypeId = 1;
  static const String tripBoxName = 'trip_box';

  static const int destinationTypeId = 2;
  static const String destinationBoxName = 'destination_box';

  static const int categoryTypeId = 3;
  static const String categoryBoxName = 'category_box';

  static const int profileTypeId = 4;
  static const String profileBoxName = 'profile_box';

  static const int notificationTypeId = 5;
  static const String notificationBoxName = 'notification_box';

  static const int chatTypeId = 6;
  static const String chatBoxName = 'chat_box';

  static const int conversationTypeId = 7;
  static const String conversationBoxName = 'conversation_box';

  static const int locationTypeId = 8;
  static const String locationBoxName = 'location_box';

  static const String userBoxName = 'user_box';
}
