import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});// Include the key parameter
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to the Home Screen!'),
            ElevatedButton(
              onPressed: () {
                // Navigate to other parts of the app or log out
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
