import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mycashbook/db/database.dart'; // Import the database file

class AuthenticationService {
  final HiveDatabaseHelper _databaseHelper;

  AuthenticationService(this._databaseHelper);

  Future<bool> login(String username, String password) async {
    final user = await _databaseHelper
        .getUser(username); // Use _getUser from the database

    if (user != null && BCrypt.checkpw(password, user.password)) {
      // Store the user's token or session information
      // For simplicity, we're using a boolean to track login status
      await _storeUserLoginStatus(true);
      return true; // Login successful
    }

    return false; // Login failed
  }

  Future<void> logout() async {
    // Clear the user's token or session information
    await _storeUserLoginStatus(false);
  }

  Future<void> _storeUserLoginStatus(bool isLoggedIn) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('mycashbook.isLoggedIn', isLoggedIn);
  }

  Future<bool> isUserLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    final isLoggedIn = preferences.getBool('mycashbook.isLoggedIn') ?? false;
    return isLoggedIn;
  }
}
