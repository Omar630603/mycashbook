import 'package:hive_flutter/hive_flutter.dart';
import 'package:mycashbook/models/user.dart';
import 'package:mycashbook/models/transaction.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HiveDatabaseHelper {
  static const String _userBoxName = 'userBox';
  static const String _transactionBoxName = 'transactionBox';

  Future<void> initDatabase() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(TransactionAdapter());

    final box = await Hive.openBox<User>(_userBoxName);
    if (box.isEmpty) {
      // Load user data from environment variables
      final usernameFromEnv = dotenv.env['USERNAME'] ?? 'defaultUser';
      final passwordFromEnv = dotenv.env['PASSWORD'] ?? 'defaultPassword';

      // const usernameFromEnv = 'user';
      // const passwordFromEnv = '123456789';

      // Encrypt the password
      final String passwordHashed = BCrypt.hashpw(
        passwordFromEnv,
        BCrypt.gensalt(),
      );

      // Create a User object and store it in the box
      final user = User(username: usernameFromEnv, password: passwordHashed);
      await box.add(user);
    }
  }

  Future<User?> getUser(String username) async {
    final box = await Hive.openBox<User>(_userBoxName);
    final users = box.values.where((user) => user.username == username);
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  Future<void> addTransaction(Transaction transaction) async {
    final box = await Hive.openBox<Transaction>(_transactionBoxName);
    await box.add(transaction);
  }

  Future<void> close() async {
    await Hive.close();
  }
}
