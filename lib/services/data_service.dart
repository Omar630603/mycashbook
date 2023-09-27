import 'package:mycashbook/db/database.dart';
import 'package:mycashbook/models/transaction.dart';

class DataService {
  final HiveDatabaseHelper _databaseHelper;

  DataService(this._databaseHelper);

  Future<bool> addTransaction(
      DateTime date, int amount, String description, String type) async {
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
      date: date,
      amount: amount,
      description: description,
      type: type,
    );
    await _databaseHelper.addTransaction(transaction);
    return true;
  }

  Future<List<Transaction>> getTransactions() async {
    return await _databaseHelper.getTransactions();
  }
}
