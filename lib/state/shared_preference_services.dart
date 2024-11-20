import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _loggedInKey = 'isLoggedIn';

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
    print("Logged in state set to: $value");
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    print("Retrieved logged in state: $isLoggedIn");
    return isLoggedIn;
  }
}
