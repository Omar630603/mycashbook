import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  static const String routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, dynamic>> transactions = [
    {
      'date': '2023-09-25',
      'amount': '100.00',
      'description': 'Groceries Groceries Groceries',
      'isIncome': false,
    },
    {
      'date': '2023-09-24',
      'amount': 'Rp. 200.000.000',
      'description': 'Salary Salary Salary Salary',
      'isIncome': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return TransactionItem(
              date: transaction['date'],
              amount: transaction['amount'],
              description: transaction['description'],
              isIncome: transaction['isIncome'],
            );
          },
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String date;
  final String amount;
  final String description;
  final bool isIncome;

  const TransactionItem({
    super.key,
    required this.date,
    required this.amount,
    required this.description,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2, // Add elevation for a shadow effect
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Dismissible(
          key: Key(description), // Unique key for each transaction
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // Handle delete action here
            } else if (direction == DismissDirection.endToStart) {
              // Handle edit action here
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
