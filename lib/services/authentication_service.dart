import 'package:bcrypt/bcrypt.dart';
import 'package:mycashbook/models/user.dart';
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
      await _storeUserLoginStatus(true, user.username);
      return true; // Login successful
    }

    return false; // Login failed
  }

  // get the current user
  Future<User?> getCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final isLoggedIn = preferences.getBool('mycashbook.isLoggedIn') ?? false;
    if (isLoggedIn) {
      final username = preferences.getString('mycashbook.username') ?? '';
      final user = await _databaseHelper.getUser(username);
      return user;
    }
    return null;
  }

  Future<bool> checkUserPassword(String username, String password) async {
    final user = await _databaseHelper.getUser(username);
    if (user != null && BCrypt.checkpw(password, user.password)) {
      return true;
    }
    return false;
  }

  Future<bool> changePassword(String username, String password) async {
    final String passwordHashed = BCrypt.hashpw(password, BCrypt.gensalt());
    if (await _databaseHelper.updateUserPassword(username, passwordHashed)) {
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    // Clear the user's token or session information
    await _storeUserLoginStatus(false, '');
  }

  Future<void> _storeUserLoginStatus(bool isLoggedIn, String username) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('mycashbook.isLoggedIn', isLoggedIn);
    if (isLoggedIn) {
      await preferences.setString('mycashbook.username', username);
    }
  }

  Future<bool> isUserLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    final isLoggedIn = preferences.getBool('mycashbook.isLoggedIn') ?? false;
    return isLoggedIn;
  }
}
