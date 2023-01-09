import 'dart:io';

// singleton for user data (data not in dive logs)
class UserData {
  static final UserData _userData = new UserData._internal();

  String? uid;
  String? email;
  int? numDives;
  int? collectionLength;  // tracks the number of dive logs
  int? numVisible;              // values for log_settings
  List<dynamic>? sectionList;
  Directory? appDir;

  factory UserData() {
    return _userData;
  }

  UserData._internal();
}

final userData = UserData();
