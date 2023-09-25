import 'package:flutter/material.dart';
import 'package:mycashbook/screens/history.dart';
import 'package:mycashbook/screens/home_screen.dart';
import 'package:mycashbook/screens/login_screen.dart';
import 'package:mycashbook/screens/add_transaction_screen.dart';
import 'package:mycashbook/screens/setting_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Cash Book',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      routes: {
        '/': (context) => welcomeScreen(context),
        '/login': (context) => LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_transaction': (context) => AddTransactionScreen(
            transactionType: ModalRoute.of(context)!.settings.arguments),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingScreen(),
        '/logout': (context) => welcomeScreen(context),
      },
    );
  }

  Scaffold welcomeScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'My Cash Book',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
