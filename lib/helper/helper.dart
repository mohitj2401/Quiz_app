import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "USERLOGGEDINKEY";
  static String userApiKey = "USERAPIKEY";
  static String userRole = "USERROLE";

  static saveUserLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(userLoggedInKey, isLoggedIn);
  }

  static saveUserApiKey(String api_token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userApiKey, api_token);
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
}
