import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String isLogin = "isLogin";
  static const String isToken = "isToken";
  static const String isName = "isName";

  // SAVE DATA

  static Future<void> saveLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(isLogin, value);
  }

  static Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(isToken, value);
  }

  static Future<void> saveName(String value) async {
    // <-- tambahkan
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(isName, value);
  }

  // GET DATA

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLogin);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isToken);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isName);
  }

  // REMOVE DATA

  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isLogin);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isToken);
  }

  static Future<void> removeName() async {
    // <-- tambahkan
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isName);
  }
}