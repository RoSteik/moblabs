import 'dart:convert';

import 'package:moblabs/lab2/logic/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHolder {
  static late SharedPreferences instance;

  static Future<void> init() async {
    instance = await SharedPreferences.getInstance();
  }
}

abstract class IUserStorageService {
  Future<void> saveUser(User user);

  Future<User?> getUser(String email);
}

class UserStorageService implements IUserStorageService {
  @override
  Future<void> saveUser(User user) async {
    SharedPrefsHolder.instance.setString(user.email, jsonEncode(user.toJson()));
  }

  @override
  Future<User?> getUser(String email) async {
    final userString = SharedPrefsHolder.instance.getString(email);
    if (userString != null) {
      final Map<String, dynamic> userMap =
      jsonDecode(userString) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }
}
