import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "USERLOGGEDINKEY";
  static String userApiKey = "USERAPIKEY";
  static String userRole = "USERROLE";
  static String userTheme = "USERROLE";

  static saveUserLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(userLoggedInKey, isLoggedIn);
  }

  static saveUserApiKey(String apiToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userApiKey, apiToken);
  }

  static Future<bool> getUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(userLoggedInKey) == true) {
      return true;
    } else {
      return false;
    }
  }

  static Future<String> getUserApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(userApiKey) == null) {
      return '';
    }
    return prefs.getString(userApiKey).toString();
  }

  static Future<int> getUserThemeKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(userTheme) == null) {
      return -1;
    }
    return prefs.getInt(userTheme)!;
  }

  static saveUserThemeindex(int themeIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(userTheme, themeIndex);
  }
}
