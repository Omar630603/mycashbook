import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mycashbook/screens/history.dart';
import 'package:mycashbook/screens/home_screen.dart';
import 'package:mycashbook/screens/login_screen.dart';
import 'package:mycashbook/screens/add_transaction_screen.dart';
import 'package:mycashbook/screens/setting_screen.dart';
import 'package:mycashbook/services/authentication_service.dart';
import 'package:mycashbook/db/database.dart';
import 'package:mycashbook/services/data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load();

  final databaseHelper = HiveDatabaseHelper();
  await databaseHelper.initDatabase();

  final authService = AuthenticationService(databaseHelper);
  final dataService = DataService(databaseHelper);
  final isLoggedIn = await authService.isUserLoggedIn();
  runApp(
    MainApp(
        authService: authService,
        dataService: dataService,
        isLoggedIn: isLoggedIn),
  );
}

class MainApp extends StatelessWidget {
  const MainApp(
      {Key? key,
      required this.authService,
      required this.dataService,
      required this.isLoggedIn})
      : super(key: key);
  final AuthenticationService authService;
  final DataService dataService;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Cash Book',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(isLoggedIn: isLoggedIn),
        '/login': (context) => LoginScreen(authService: authService),
        '/home': (context) =>
            HomeScreen(authService: authService, dataService: dataService),
        '/add_transaction': (context) => AddTransactionScreen(
              transactionType: ModalRoute.of(context)!.settings.arguments,
              dataService: dataService,
            ),
        '/history': (context) => HistoryScreen(dataService: dataService),
        '/settings': (context) => SettingScreen(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key, required this.isLoggedIn}) : super(key: key);
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                if (isLoggedIn) {
                  Navigator.of(context).pushNamed('/home');
                } else {
                  Navigator.of(context).pushNamed('/login');
                }
              },
              child: Text(isLoggedIn ? 'Continue' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}
