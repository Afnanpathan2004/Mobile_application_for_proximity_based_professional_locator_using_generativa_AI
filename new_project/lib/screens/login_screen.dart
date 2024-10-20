// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart'; // Import your API service

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); // Initialize ApiService

  Future<void> _loginUser() async {
    try {
      final response = await _apiService.loginUser(
        username: _usernamecontroller.text, // Assuming email is used as username
        password: _passwordController.text,
      );
      // Handle successful login, show message or navigate
      // ignore: use_build_context_synchronously
      if (response.containsKey('message') && response['message'] =='User logged in successfully!') {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successsful!')),
      );
      } else {
      // Handle failed login, e.g. show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response['detail'] ?? 'unexpected error'}')),
      );
    }
      // Here you can save the access token in secure storage if needed
    } catch (e) {
      // Handle error, show error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Welcome Back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField('Username', controller: _usernamecontroller),
            _buildTextField('Password', isPassword: true, controller: _passwordController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginUser, // Call the login function
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool isEmail = false, bool isPassword = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller, // Use the controller
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.blueAccent),
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}
