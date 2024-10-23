import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import the Login screen
import 'screens/registration_screen.dart'; // Import the Registration screen
import 'screens/home_screen.dart'; // Import the Home screen
import 'screens/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Professional Locator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(
            title:
                'Welcome to Professional locator!!!'), // Set the HomePage as the home screen
        '/register': (context) => RegistrationScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/dashboard': (context) => Dashboard(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to the Professional Locator!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/register'); // Navigate to registration
              },
              child: const Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Navigate to login
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
