// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mycashbook/models/transaction.dart';
import 'package:mycashbook/services/data_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key, required this.dataService}) : super(key: key);
  static const String routeName = '/history';
  final DataService dataService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> loadTransactions() async {
    try {
      final loadedTransactions = await widget.dataService.getTransactions();
      setState(() {
        transactions = loadedTransactions;
      });
    } catch (e) {
      // Handle error loading transactions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          },
          icon: const Icon(Icons.home),
        ),
        title: const Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: transactions.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 100,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No transaction history',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];

                  final amount = NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp. ',
                    decimalDigits: 0,
                  ).format(transaction.amount);

                  return TransactionItem(
                    id: transaction.id,
                    date: DateFormat('dd MMM yyyy').format(transaction.date),
                    amount: amount,
                    description: transaction.description,
                    isIncome: transaction.type == 'Income',
                    dataService: widget.dataService,
                  );
                },
              ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final int id;
  final String date;
  final String amount;
  final String description;
  final bool isIncome;
  final DataService dataService;

  const TransactionItem({
    Key? key,
    required this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.isIncome,
    required this.dataService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Dismissible(
          key: Key(id.toString()),
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.red,
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Show delete confirmation dialog
              return await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text(
                      'Are you sure you want to delete this transaction?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await dataService.deleteTransaction(id);
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            } else if (direction == DismissDirection.endToStart) {
              // Handle edit action here
              // Return false to prevent immediate dismissal
              return false;
            }
            // Return false by default to prevent immediate dismissal
            return false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              // Handle edit action here after confirmation
            }
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green : Colors.red,
              child: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
            ),
            title:
                Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(date),
            trailing: Text(amount),
          ),
        ),
      ),
    );
  }
}
