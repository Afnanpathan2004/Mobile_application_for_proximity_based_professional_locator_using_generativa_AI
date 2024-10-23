import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart'; // Import your API service

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService(); // Initialize ApiService

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        setState(() {
          _isLoading = false;
        });
        // ignore: unused_local_variable
        final response = await _apiService.registerUser(
          username: _usernameController.text,
          password: _passwordController.text,
          dob: _dobController.text,
          profession: _professionController.text,
          address: _addressController.text,
          pincode: _pincodeController.text,
          contactNumber: _contactNumberController.text,
          email: _emailController.text,
        );
        // Handle success, show success message
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        // Handle error, show error message
        // ignore: use_build_context_synchronously
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Add form key for validation
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Create an Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField('User Name', controller: _usernameController),
            _buildTextField('Password', controller: _passwordController),
            _buildTextField('Date of Birth', controller: _dobController),
            _buildTextField('Profession', controller: _professionController),
            _buildTextField('Residential Address',
                controller: _addressController),
            _buildTextField('Pincode', controller: _pincodeController),
            _buildTextField('Contact Number',
                controller: _contactNumberController),
            _buildTextField('Email',
                isEmail: true, controller: _emailController),
            const SizedBox(height: 20), 
            _isLoading ? CircularProgressIndicator(): 
            ElevatedButton(
              onPressed: _registerUser, // Call the registration function
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Register',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                },
                  child: Text('Already have an account? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {bool isEmail = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller, // Use the controller
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
      validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
    ),
  );
}
}
