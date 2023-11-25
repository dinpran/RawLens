import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "USERLOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  static saveUserLoggedInStatus(bool isuserloggedin) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(userLoggedInKey, isuserloggedin);
  }

  static saveEmail(String email) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userEmailKey, email);
  }

  static saveUsername(String username) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userNameKey, username);
  }

  static Future<bool?> getUserLoggenInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailKey() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserNamelKey() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }
}
