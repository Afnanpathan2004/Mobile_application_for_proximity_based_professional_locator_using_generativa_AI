import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // Replace with your FastAPI URL

  // Registration endpoint
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String dob,
    required String profession,
    required String address,
    required String pincode,
    required String contactNumber,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'dob': dob,
        'profession': profession,
        'address': address,
        'pincode': pincode,
        'contact_number': contactNumber,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Login endpoint
  Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) ;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
}
