// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:new_project/services/api_service.dart'; // Import your API service
import 'package:geolocator/geolocator.dart';

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
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final ApiService _apiService = ApiService(); // Initialize ApiService

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Function to get the current location with updated settings
  Future<void> _getLocation() async {
    // Check if the location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If location services are not enabled, show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
      }
      return;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // If permission is denied, show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
      return;
    }

    // Create LocationSettings for Android and iOS with high accuracy
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, // Desired accuracy
      distanceFilter: 100, // Minimum distance (in meters) before an update is triggered
    );

    try {
      // Get the current position using the updated location settings
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // Update the controllers with the latitude and longitude
      if (mounted) {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await _apiService.registerUser(
          username: _usernameController.text,
          password: _passwordController.text,
          dob: _dobController.text,
          profession: _professionController.text,
          address: _addressController.text,
          pincode: _pincodeController.text,
          contactNumber: _contactNumberController.text,
          email: _emailController.text,
          latitude: _latitudeController.text, // Added latitude
          longitude: _longitudeController.text, // Added longitude
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Handle success, show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });

          // Handle error, show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Get the current location when the screen is initialized
    _getLocation();
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
              const Text(
                'Create an Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField('User Name', controller: _usernameController),
              _buildTextField('Password', controller: _passwordController),
              _buildTextField('Date of Birth', controller: _dobController),
              _buildTextField('Profession', controller: _professionController),
              _buildTextField('Residential Address', controller: _addressController),
              _buildTextField('Pincode', controller: _pincodeController),
              _buildTextField('Contact Number', controller: _contactNumberController),
              _buildTextField('Email', isEmail: true, controller: _emailController),
              _buildTextField('Latitude', controller: _latitudeController, isReadOnly: true),
              _buildTextField('Longitude', controller: _longitudeController, isReadOnly: true),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registerUser, // Call the registration function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
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
                child: const Text('Already have an account? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {bool isEmail = false, bool isReadOnly = false, TextEditingController? controller}) {
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
        readOnly: isReadOnly,
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
